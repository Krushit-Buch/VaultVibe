import '../../core/enums/payment_method.dart' as data;
import '../../core/enums/recurring_type.dart' as data;
import '../../core/enums/transaction_type.dart';
import '../../core/utils/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/recurring_type.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../models/expense_model.dart';

/// Concrete implementation of [ExpenseRepository] backed by Hive.
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _localDataSource;

  const ExpenseRepositoryImpl(this._localDataSource);

  @override
  Future<List<Expense>> getAllExpenses() async {
    final models = await _localDataSource.getAllExpenses();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    final model = await _localDataSource.getExpenseById(id);
    return model != null ? _modelToEntity(model) : null;
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final model = _entityToModel(expense);
    await _localDataSource.saveExpense(model);
  }

  @override
  Future<void> addExpenses(List<Expense> expenses) async {
    final models = expenses.map(_entityToModel).toList(growable: false);
    await _localDataSource.saveExpenses(models);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final existing = await _localDataSource.getExpenseById(expense.id);
    if (existing == null) throw const NotFoundFailure('Expense not found.');
    final model = _entityToModel(expense);
    await _localDataSource.saveExpense(model);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _localDataSource.deleteExpense(id);
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final all = await getAllExpenses();
    return all.where((e) {
      return !e.date.isBefore(from) && !e.date.isAfter(to);
    }).toList();
  }

  // ── Mappers ───────────────────────────────────────────────

  Expense _modelToEntity(ExpenseModel m) {
    final isExpense = m.amount.isNegative;
    return Expense(
      id: m.id,
      title: m.title,
      amount: m.amount.abs(),
      categoryId: m.categoryId,
      date: m.date,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      paymentMethod: PaymentMethod.values.byName(m.paymentMethod.name),
      isRecurring: m.isRecurring,
      recurringType: RecurringType.values.byName(m.recurringType.name),
      lastGeneratedDate: m.lastGeneratedDate,
      splitCount: m.splitCount,
      createdAt: m.createdAt,
    );
  }

  ExpenseModel _entityToModel(Expense e) {
    return ExpenseModel(
      id: e.id,
      title: e.title,
      amount: e.type.isExpense ? -e.amount.abs() : e.amount.abs(),
      categoryId: e.categoryId,
      date: e.date,
      paymentMethod: data.PaymentMethod.values.byName(e.paymentMethod.name),
      isRecurring: e.isRecurring,
      recurringType: data.RecurringType.values.byName(e.recurringType.name),
      lastGeneratedDate: e.lastGeneratedDate,
      splitCount: e.splitCount,
      createdAt: e.createdAt,
    );
  }
}
