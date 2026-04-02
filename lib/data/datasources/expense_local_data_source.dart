import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/failures.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getAllExpenses();
  Future<ExpenseModel?> getExpenseById(String id);
  Future<void> saveExpense(ExpenseModel expense);
  Future<void> saveExpenses(Iterable<ExpenseModel> expenses);
  Future<void> deleteExpense(String id);
}

class HiveExpenseLocalDataSource implements ExpenseLocalDataSource {
  Box<ExpenseModel> get _box =>
      Hive.box<ExpenseModel>(AppConstants.expenseBoxName);

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    try {
      final expenses = _box.values.toList(growable: false);
      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    } catch (e) {
      throw LocalFailure('Failed to fetch expenses: $e');
    }
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      throw LocalFailure('Failed to fetch expense by id: $e');
    }
  }

  @override
  Future<void> saveExpense(ExpenseModel expense) async {
    try {
      await _box.put(expense.id, expense);
    } catch (e) {
      throw LocalFailure('Failed to save expense: $e');
    }
  }

  @override
  Future<void> saveExpenses(Iterable<ExpenseModel> expenses) async {
    try {
      final payload = {for (final expense in expenses) expense.id: expense};
      if (payload.isEmpty) return;
      await _box.putAll(payload);
    } catch (e) {
      throw LocalFailure('Failed to save expenses: $e');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw LocalFailure('Failed to delete expense: $e');
    }
  }
}
