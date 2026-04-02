import '../../core/utils/failures.dart';
import '../entities/budget.dart';
import '../repositories/settings_repository.dart';

/// Stores the user's monthly budget limit.
class SetBudgetUseCase {
  final SettingsRepository _repository;

  const SetBudgetUseCase(this._repository);

  Future<void> call(double monthlyLimit) async {
    if (monthlyLimit < 0) {
      throw const ValidationFailure('Monthly budget cannot be negative.');
    }
    await _repository.saveBudget(Budget(monthlyLimit: monthlyLimit));
  }
}
