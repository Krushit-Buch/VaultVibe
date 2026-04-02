import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Retrieves expenses with optional date-range filtering.
class GetExpensesUseCase {
  final ExpenseRepository _repository;

  const GetExpensesUseCase(this._repository);

  Future<List<Expense>> call({
    DateTime? from,
    DateTime? to,
  }) {
    if (from != null && to != null) {
      return _repository.getExpensesByDateRange(from, to);
    }
    return _repository.getAllExpenses();
  }
}
