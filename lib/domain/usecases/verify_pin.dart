import '../../core/utils/failures.dart';
import '../repositories/app_lock_repository.dart';

class VerifyPinUseCase {
  final AppLockRepository _repository;

  const VerifyPinUseCase(this._repository);

  Future<bool> call(String pin) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const ValidationFailure('PIN must be exactly 4 digits.');
    }
    return _repository.verifyPin(pin);
  }
}
