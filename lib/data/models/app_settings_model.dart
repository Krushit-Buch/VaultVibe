import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: AppConstants.appSettingsModelTypeId)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  final String? pinHash;

  @HiveField(1)
  final bool isPinSet;

  @HiveField(2)
  final DateTime? lastRecurringCheck;

  AppSettingsModel({
    this.pinHash,
    required this.isPinSet,
    this.lastRecurringCheck,
  });

  AppSettingsModel copyWith({
    String? pinHash,
    bool? isPinSet,
    DateTime? lastRecurringCheck,
  }) {
    return AppSettingsModel(
      pinHash: pinHash ?? this.pinHash,
      isPinSet: isPinSet ?? this.isPinSet,
      lastRecurringCheck: lastRecurringCheck ?? this.lastRecurringCheck,
    );
  }
}
