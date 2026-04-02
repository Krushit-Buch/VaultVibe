import '../../core/utils/failures.dart';
import '../repositories/app_lock_repository.dart';

class SetupPinUseCase {
  final AppLockRepository _repository;

  const SetupPinUseCase(this._repository);

  Future<void> call(String pin) async {
    if (!_isValidPin(pin)) {
      throw const ValidationFailure('PIN must be exactly 4 digits.');
    }
    final hasPin = await _repository.hasPin();
    if (hasPin) {
      throw const ValidationFailure(
          'PIN is already set and cannot be changed.');
    }
    await _repository.setPin(pin);
  }

  bool _isValidPin(String pin) {
    return RegExp(r'^\d{4}$').hasMatch(pin);
  }
}
