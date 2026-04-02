import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/transaction_type.dart';
import '../../core/utils/failures.dart';
import '../../domain/entities/category.dart';
import 'dependency_providers.dart';
import 'expense_provider.dart';

/// Fetches and caches all categories (seeds defaults on first run).
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = ref.watch(getAllCategoriesUseCaseProvider);
  return useCase.call();
});

/// Lookup map of categoryId → Category for O(1) access in lists.
final categoryMapProvider = Provider<AsyncValue<Map<String, Category>>>((ref) {
  return ref.watch(categoriesProvider).whenData(
        (list) => {for (final c in list) c.id: c},
      );
});

final categoriesByTypeProvider =
    Provider.family<AsyncValue<List<Category>>, TransactionType>((ref, type) {
  return ref.watch(categoriesProvider).whenData(
        (list) => list.where((category) => category.supports(type)).toList(),
      );
});

final categoryActionControllerProvider =
    AsyncNotifierProvider<CategoryActionController, void>(
  CategoryActionController.new,
);

class CategoryActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveCategory({
    required String name,
    Category? existingCategory,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) {
        throw const ValidationFailure('Category name cannot be empty.');
      }

      final uuid = ref.read(uuidProvider);
      final category = Category(
        id: existingCategory?.id ?? uuid.v4(),
        name: trimmedName,
        icon: existingCategory?.icon ?? '📁',
        colorValue: existingCategory?.colorValue ?? 0xFF6C63FF,
        transactionType: existingCategory?.transactionType,
        isDefault: false,
        createdAt: existingCategory?.createdAt ?? DateTime.now(),
      );

      final useCase = ref.read(manageCategoriesUseCaseProvider);
      if (existingCategory == null) {
        await useCase.add(category);
      } else {
        await useCase.update(category);
      }
      _invalidate();
    });
  }

  Future<void> deleteCategory({
    required Category category,
    String? reassignmentCategoryId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final expenses = await ref.read(getAllExpensesUseCaseProvider).call();
      final linkedExpenses = expenses
          .where((expense) => expense.categoryId == category.id)
          .toList(growable: false);

      if (linkedExpenses.isNotEmpty && reassignmentCategoryId == null) {
        throw const ValidationFailure(
          'This category is in use. Reassign expenses before deleting it.',
        );
      }

      if (linkedExpenses.isNotEmpty && reassignmentCategoryId != null) {
        for (final expense in linkedExpenses) {
          await ref.read(updateExpenseUseCaseProvider).call(
                expense.copyWith(categoryId: reassignmentCategoryId),
              );
        }
      }

      await ref.read(manageCategoriesUseCaseProvider).delete(category.id);
      _invalidate();
    });
  }

  void _invalidate() {
    ref.invalidate(categoriesProvider);
    ref.invalidate(categoryMapProvider);
    ref.invalidate(expensesProvider);
    ref.invalidate(allExpensesProvider);
  }
}
