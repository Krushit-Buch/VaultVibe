import '../entities/expense.dart';
import '../repositories/expense_repository.dart';
import '../../core/enums/time_filter.dart';
import '../../core/utils/date_helper.dart';

/// Fetches expenses filtered by a [TimeFilter].
class GetExpensesByFilterUseCase {
  final ExpenseRepository _repository;
  const GetExpensesByFilterUseCase(this._repository);

  Future<List<Expense>> call(TimeFilter filter) async {
    final now = DateTime.now();

    switch (filter) {
      case TimeFilter.today:
        return _repository.getExpensesByDateRange(
          DateHelper.startOfToday,
          now,
        );
      case TimeFilter.thisWeek:
        return _repository.getExpensesByDateRange(
          DateHelper.startOfThisWeek,
          now,
        );
      case TimeFilter.thisMonth:
        return _repository.getExpensesByDateRange(
          DateHelper.startOfThisMonth,
          now,
        );
      case TimeFilter.lastMonth:
        return _repository.getExpensesByDateRange(
          DateHelper.startOfLastMonth,
          DateHelper.endOfLastMonth,
        );
      case TimeFilter.last3Months:
        return _repository.getExpensesByDateRange(
          DateTime(now.year, now.month - 2, 1),
          now,
        );
      case TimeFilter.thisYear:
        return _repository.getExpensesByDateRange(
          DateHelper.startOfThisYear,
          now,
        );
      case TimeFilter.all:
        return _repository.getAllExpenses();
    }
  }
}
