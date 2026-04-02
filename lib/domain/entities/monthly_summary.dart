/// Aggregated monthly totals used by dashboards and reports.
class MonthlySummary {
  final DateTime month;
  final double income;
  final double expense;
  final double balance;
  final double? monthlyBudget;
  final double budgetRemaining;
  final double budgetUsedPercentage;
  final int transactionCount;

  const MonthlySummary({
    required this.month,
    required this.income,
    required this.expense,
    required this.balance,
    required this.monthlyBudget,
    required this.budgetRemaining,
    required this.budgetUsedPercentage,
    required this.transactionCount,
  });
}
