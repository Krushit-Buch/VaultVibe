import '../entities/expense.dart';
import '../entities/recurring_type.dart';
import '../repositories/expense_repository.dart';
import '../repositories/settings_repository.dart';

typedef DateTimeProvider = DateTime Function();

/// Generates due recurring expenses and persists them.
class GenerateRecurringExpensesUseCase {
  final ExpenseRepository _expenseRepository;
  final SettingsRepository _settingsRepository;
  final DateTimeProvider _now;

  const GenerateRecurringExpensesUseCase(
    this._expenseRepository,
    this._settingsRepository, {
    DateTimeProvider? now,
  }) : _now = now ?? DateTime.now;

  Future<List<Expense>> call({DateTime? until}) async {
    final cutoff = until ?? _now();
    final settings = await _settingsRepository.getSettings();
    final lastRecurringCheck = settings.lastRecurringCheck;

    if (lastRecurringCheck != null &&
        !_startOfDay(lastRecurringCheck).isBefore(_startOfDay(cutoff))) {
      return const [];
    }

    final expenses = await _expenseRepository.getAllExpenses();
    final existingIds = expenses.map((expense) => expense.id).toSet();
    final generated = <Expense>[];

    for (final expense in expenses) {
      if (!expense.isRecurring || expense.recurringType == RecurringType.none) {
        continue;
      }

      final seedDate = expense.lastGeneratedDate ?? expense.date;
      var nextDate = _nextOccurrence(seedDate, expense.recurringType);
      var latestGeneratedDate = expense.lastGeneratedDate;

      while (!nextDate.isAfter(cutoff)) {
        if (lastRecurringCheck == null ||
            nextDate.isAfter(lastRecurringCheck)) {
          final candidate = expense.copyWith(
            id: _generatedExpenseId(expense, nextDate),
            date: nextDate,
            isRecurring: false,
            recurringType: RecurringType.none,
            lastGeneratedDate: null,
            createdAt: cutoff,
          );
          if (!existingIds.contains(candidate.id)) {
            generated.add(candidate);
            existingIds.add(candidate.id);
          }
        }
        latestGeneratedDate = nextDate;
        nextDate = _nextOccurrence(nextDate, expense.recurringType);
      }

      if (latestGeneratedDate != null &&
          latestGeneratedDate != expense.lastGeneratedDate) {
        await _expenseRepository.updateExpense(
          expense.copyWith(lastGeneratedDate: latestGeneratedDate),
        );
      }
    }

    if (generated.isNotEmpty) {
      await _expenseRepository.addExpenses(generated);
    }
    await _settingsRepository.updateLastRecurringCheck(cutoff);
    return generated;
  }

  DateTime _nextOccurrence(DateTime base, RecurringType recurringType) {
    switch (recurringType) {
      case RecurringType.none:
        return base;
      case RecurringType.daily:
        return base.add(const Duration(days: 1));
      case RecurringType.weekly:
        return base.add(const Duration(days: 7));
      case RecurringType.monthly:
        return DateTime(
          base.year,
          base.month + 1,
          base.day,
          base.hour,
          base.minute,
          base.second,
          base.millisecond,
          base.microsecond,
        );
      case RecurringType.yearly:
        return DateTime(
          base.year + 1,
          base.month,
          base.day,
          base.hour,
          base.minute,
          base.second,
          base.millisecond,
          base.microsecond,
        );
    }
  }

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _generatedExpenseId(Expense expense, DateTime date) {
    return [
      'recurring',
      expense.id,
      expense.date.year.toString(),
      date.year.toString(),
      date.month.toString().padLeft(2, '0'),
      date.day.toString().padLeft(2, '0'),
    ].join('_');
  }
}
