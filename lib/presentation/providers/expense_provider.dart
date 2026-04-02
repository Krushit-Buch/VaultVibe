import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/time_filter.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/recurring_type.dart';
import '../../domain/usecases/add_expense.dart';
import 'dependency_providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ExpenseDateRangeFilter {
  final DateTime start;
  final DateTime end;

  const ExpenseDateRangeFilter({
    required this.start,
    required this.end,
  });
}

/// Currently selected time filter for the expenses list.
final selectedTimeFilterProvider = StateProvider<TimeFilter>((ref) {
  return TimeFilter.thisMonth;
});

final selectedDateRangeProvider =
    StateProvider<ExpenseDateRangeFilter?>((ref) => null);

final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

// ── Async Data ────────────────────────────────────────────────────────────────

final baseExpensesProvider =
    FutureProvider.autoDispose<List<Expense>>((ref) async {
  final filter = ref.watch(selectedTimeFilterProvider);
  if (filter == TimeFilter.all) {
    return ref.watch(getAllExpensesUseCaseProvider).call();
  }
  return ref.watch(getExpensesByFilterUseCaseProvider).call(filter);
});

/// All expenses (unfiltered) — useful for statistics.
final allExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final useCase = ref.watch(getAllExpensesUseCaseProvider);
  return useCase.call();
});

/// Filtered expenses for the current list view.
final expensesProvider = Provider.autoDispose<AsyncValue<List<Expense>>>((ref) {
  final baseExpensesAsync = ref.watch(baseExpensesProvider);
  final customDateRange = ref.watch(selectedDateRangeProvider);
  final selectedCategoryId = ref.watch(selectedCategoryFilterProvider);

  return baseExpensesAsync.whenData((expenses) {
    final baseFiltered = expenses.where((expense) {
      final inDateRange = customDateRange == null
          ? true
          : !expense.date.isBefore(
                DateTime(
                  customDateRange.start.year,
                  customDateRange.start.month,
                  customDateRange.start.day,
                ),
              ) &&
              !expense.date.isAfter(
                DateTime(
                  customDateRange.end.year,
                  customDateRange.end.month,
                  customDateRange.end.day,
                  23,
                  59,
                  59,
                  999,
                ),
              );
      final inCategory = selectedCategoryId == null
          ? true
          : expense.categoryId == selectedCategoryId;
      return inDateRange && inCategory;
    }).toList(growable: false)
      ..sort((a, b) => b.date.compareTo(a.date));

    return baseFiltered;
  });
});

// ── Derived Summaries ─────────────────────────────────────────────────────────

/// Total income for the current filter period.
final totalIncomeProvider = Provider.autoDispose<AsyncValue<double>>((ref) {
  return ref.watch(expensesProvider).whenData(
        (list) =>
            list.where((e) => e.isIncome).fold(0.0, (sum, e) => sum + e.amount),
      );
});

/// Total expense for the current filter period.
final totalExpenseProvider = Provider.autoDispose<AsyncValue<double>>((ref) {
  return ref.watch(expensesProvider).whenData(
        (list) => list
            .where((e) => e.isExpense)
            .fold(0.0, (sum, e) => sum + e.amount),
      );
});

/// Net balance (income − expense) for the current filter period.
final netBalanceProvider = Provider.autoDispose<AsyncValue<double>>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);
  return income.whenData((inc) {
    return expense.when(
      data: (exp) => inc - exp,
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );
  });
});

// ── Actions ───────────────────────────────────────────────────────────────────

final expenseActionControllerProvider =
    AsyncNotifierProvider<ExpenseActionController, void>(
  ExpenseActionController.new,
);

class ExpenseActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveExpense(
    SaveExpenseParams params, {
    Expense? existingExpense,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uuid = ref.read(uuidProvider);
      final createdAt = existingExpense?.createdAt ?? DateTime.now();
      final expense = Expense(
        id: existingExpense?.id ?? (params.id.isEmpty ? uuid.v4() : params.id),
        title: params.title.trim(),
        amount: params.amount,
        date: params.date,
        categoryId: params.categoryId,
        type: params.type,
        paymentMethod: params.paymentMethod,
        isRecurring: params.isRecurring,
        recurringType:
            params.isRecurring ? params.recurringType : RecurringType.none,
        lastGeneratedDate: params.isRecurring ? params.lastGeneratedDate : null,
        splitCount: params.splitCount,
        createdAt: createdAt,
      );

      if (existingExpense == null) {
        await ref.read(addExpenseUseCaseProvider).call(expense);
      } else {
        await ref.read(updateExpenseUseCaseProvider).call(expense);
      }

      _invalidateExpenseState();
    });
  }

  Future<void> deleteExpense(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteExpenseUseCaseProvider).call(id);
      _invalidateExpenseState();
    });
  }

  void _invalidateExpenseState() {
    ref.invalidate(baseExpensesProvider);
    ref.invalidate(expensesProvider);
    ref.invalidate(allExpensesProvider);
  }
}
