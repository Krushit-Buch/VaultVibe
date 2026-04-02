/// Pure domain entity representing the app's monthly budget limit.
class Budget {
  final double monthlyLimit;

  const Budget({
    required this.monthlyLimit,
  });

  Budget copyWith({
    double? monthlyLimit,
  }) {
    return Budget(
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget && other.monthlyLimit == monthlyLimit);

  @override
  int get hashCode => monthlyLimit.hashCode;

  @override
  String toString() => 'Budget(monthlyLimit: $monthlyLimit)';
}
