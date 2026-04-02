import '../entities/expense.dart';
import '../repositories/expense_repository.dart';
import '../../core/utils/failures.dart';

/// Updates an existing expense.
class UpdateExpenseUseCase {
  final ExpenseRepository _repository;
  const UpdateExpenseUseCase(this._repository);

  Future<void> call(Expense expense) async {
    if (expense.title.trim().isEmpty) {
      throw const ValidationFailure('Title cannot be empty.');
    }
    if (expense.amount <= 0) {
      throw const ValidationFailure('Amount must be greater than zero.');
    }
    if (expense.splitCount < 0) {
      throw const ValidationFailure('Split count cannot be negative.');
    }
    if (expense.splitCount == 1) {
      throw const ValidationFailure(
        'Split count must be 0 or at least 2.',
      );
    }
    await _repository.updateExpense(expense);
  }
}
