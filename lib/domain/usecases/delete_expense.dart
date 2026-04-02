import '../repositories/expense_repository.dart';

/// Deletes an expense by its ID.
class DeleteExpenseUseCase {
  final ExpenseRepository _repository;
  const DeleteExpenseUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteExpense(id);
}
