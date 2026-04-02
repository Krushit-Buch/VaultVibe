/// Represents whether a transaction is an expense or income.
enum TransactionType {
  expense,
  income;

  String get label {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
    }
  }

  bool get isExpense => this == TransactionType.expense;
  bool get isIncome => this == TransactionType.income;
}
