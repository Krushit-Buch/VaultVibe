import '../entities/expense.dart';
import '../entities/payment_method.dart';
import '../entities/recurring_type.dart';
import '../repositories/expense_repository.dart';
import '../../core/enums/transaction_type.dart';
import '../../core/utils/failures.dart';

/// Params required to add or update an expense.
class SaveExpenseParams {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionType type;
  final PaymentMethod paymentMethod;
  final bool isRecurring;
  final RecurringType recurringType;
  final DateTime? lastGeneratedDate;
  final int splitCount;

  const SaveExpenseParams({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    this.paymentMethod = PaymentMethod.cash,
    this.isRecurring = false,
    this.recurringType = RecurringType.none,
    this.lastGeneratedDate,
    this.splitCount = 0,
  });
}

/// Adds a new expense or updates an existing one.
class AddExpenseUseCase {
  final ExpenseRepository _repository;
  const AddExpenseUseCase(this._repository);

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
    await _repository.addExpense(expense);
  }
}
