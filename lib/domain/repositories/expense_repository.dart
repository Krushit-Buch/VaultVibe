import '../entities/expense.dart';

/// Abstract contract for expense data operations (domain layer).
abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<Expense?> getExpenseById(String id);
  Future<void> addExpense(Expense expense);
  Future<void> addExpenses(List<Expense> expenses);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);

  /// Returns expenses filtered by a date range.
  Future<List<Expense>> getExpensesByDateRange(
    DateTime from,
    DateTime to,
  );
}
