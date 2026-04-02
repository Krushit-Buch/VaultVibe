/// Time range filter options for transaction queries.
enum TimeFilter {
  today,
  thisWeek,
  thisMonth,
  lastMonth,
  last3Months,
  thisYear,
  all;

  String get label {
    switch (this) {
      case TimeFilter.today:
        return 'Today';
      case TimeFilter.thisWeek:
        return 'This Week';
      case TimeFilter.thisMonth:
        return 'This Month';
      case TimeFilter.lastMonth:
        return 'Last Month';
      case TimeFilter.last3Months:
        return 'Last 3 Months';
      case TimeFilter.thisYear:
        return 'This Year';
      case TimeFilter.all:
        return 'All Time';
    }
  }
}
