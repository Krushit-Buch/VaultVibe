import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Retrieves all expenses from the repository.
class GetAllExpensesUseCase {
  final ExpenseRepository _repository;
  const GetAllExpensesUseCase(this._repository);

  Future<List<Expense>> call() => _repository.getAllExpenses();
}
