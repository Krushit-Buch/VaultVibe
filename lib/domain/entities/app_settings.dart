/// User-configurable application settings.
class AppSettings {
  final String? pinHash;
  final bool isPinSet;
  final DateTime? lastRecurringCheck;

  const AppSettings({
    this.pinHash,
    required this.isPinSet,
    this.lastRecurringCheck,
  });

  AppSettings copyWith({
    String? pinHash,
    bool? isPinSet,
    DateTime? lastRecurringCheck,
  }) {
    return AppSettings(
      pinHash: pinHash ?? this.pinHash,
      isPinSet: isPinSet ?? this.isPinSet,
      lastRecurringCheck: lastRecurringCheck ?? this.lastRecurringCheck,
    );
  }
}
