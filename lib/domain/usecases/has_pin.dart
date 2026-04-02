import '../repositories/app_lock_repository.dart';

class HasPinUseCase {
  final AppLockRepository _repository;

  const HasPinUseCase(this._repository);

  Future<bool> call() => _repository.hasPin();
}
