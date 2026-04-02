import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/monthly_summary.dart';
import 'category_provider.dart';
import 'dependency_providers.dart';

class CategorySpending {
  final Category? category;
  final double amount;
  final int transactionCount;

  const CategorySpending({
    required this.category,
    required this.amount,
    required this.transactionCount,
  });
}

enum BudgetHealth {
  safe,
  warning,
  danger;
}

final monthlySummaryProvider = FutureProvider<MonthlySummary>((ref) async {
  final useCase = ref.watch(getMonthlySummaryUseCaseProvider);
  return useCase.call(DateTime.now());
});

final monthlyDashboardExpensesProvider = FutureProvider((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
  return ref.watch(getExpensesUseCaseProvider).call(from: start, to: end);
});

final monthlyExpenseBreakdownProvider =
    Provider<AsyncValue<List<CategorySpending>>>((ref) {
  final expensesAsync = ref.watch(monthlyDashboardExpensesProvider);
  final categoriesAsync = ref.watch(categoryMapProvider);

  return expensesAsync.whenData((expenses) {
    final categoryMap = categoriesAsync.valueOrNull ?? <String, Category>{};
    final expenseOnly = expenses.where((expense) => expense.isExpense).toList();
    final totals = <String, double>{};
    final counts = <String, int>{};

    for (final expense in expenseOnly) {
      totals.update(
        expense.categoryId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
      counts.update(
        expense.categoryId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    final list = totals.entries
        .map(
          (entry) => CategorySpending(
            category: categoryMap[entry.key],
            amount: entry.value,
            transactionCount: counts[entry.key] ?? 0,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return list;
  });
});

final topSpendingCategoriesProvider =
    Provider<AsyncValue<List<CategorySpending>>>((ref) {
  return ref.watch(monthlyExpenseBreakdownProvider).whenData(
        (list) => list.take(3).toList(growable: false),
      );
});

final dailyAverageSpendingProvider = Provider<AsyncValue<double>>((ref) {
  final summaryAsync = ref.watch(monthlySummaryProvider);
  return summaryAsync.whenData((summary) {
    final now = DateTime.now();
    final daysElapsed = now.day.clamp(1, 31);
    return summary.expense / daysElapsed;
  });
});

final budgetHealthProvider = Provider<AsyncValue<BudgetHealth>>((ref) {
  final summaryAsync = ref.watch(monthlySummaryProvider);
  return summaryAsync.whenData((summary) {
    final percent = summary.budgetUsedPercentage;
    if (percent < 0.7) return BudgetHealth.safe;
    if (percent <= 0.9) return BudgetHealth.warning;
    return BudgetHealth.danger;
  });
});

final budgetActionControllerProvider =
    AsyncNotifierProvider<BudgetActionController, void>(
  BudgetActionController.new,
);

class BudgetActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> setMonthlyBudget(double amount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(setBudgetUseCaseProvider).call(amount);
      ref.invalidate(monthlySummaryProvider);
      ref.invalidate(budgetHealthProvider);
      ref.invalidate(dailyAverageSpendingProvider);
    });
  }
}
