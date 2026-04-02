import '../entities/monthly_summary.dart';
import '../repositories/expense_repository.dart';
import '../repositories/settings_repository.dart';

/// Builds a monthly financial snapshot from persisted transactions.
class GetMonthlySummaryUseCase {
  final ExpenseRepository _expenseRepository;
  final SettingsRepository _settingsRepository;

  const GetMonthlySummaryUseCase(
    this._expenseRepository,
    this._settingsRepository,
  );

  Future<MonthlySummary> call(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);
    final expenses =
        await _expenseRepository.getExpensesByDateRange(start, end);
    final budget = await _settingsRepository.getBudget();

    final income = expenses
        .where((expense) => expense.isIncome)
        .fold<double>(0, (sum, expense) => sum + expense.amount);
    final totalExpense = expenses
        .where((expense) => expense.isExpense)
        .fold<double>(0, (sum, expense) => sum + expense.amount);
    final monthlyBudget = budget?.monthlyLimit;
    final remaining =
        monthlyBudget == null ? 0.0 : monthlyBudget - totalExpense;
    final usedPercent = monthlyBudget == null || monthlyBudget == 0
        ? 0.0
        : (totalExpense / monthlyBudget).toDouble().clamp(0.0, double.infinity);

    return MonthlySummary(
      month: start,
      income: income,
      expense: totalExpense,
      balance: income - totalExpense,
      monthlyBudget: monthlyBudget,
      budgetRemaining: remaining,
      budgetUsedPercentage: usedPercent,
      transactionCount: expenses.length,
    );
  }
}
