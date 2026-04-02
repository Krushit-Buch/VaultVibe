import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/failures.dart';
import 'dependency_providers.dart';

enum AppLockStage {
  loading,
  setup,
  locked,
  unlocked,
}

class AppLockState {
  final AppLockStage stage;
  final bool hasPin;
  final String? errorMessage;

  const AppLockState({
    required this.stage,
    required this.hasPin,
    this.errorMessage,
  });

  const AppLockState.loading()
      : stage = AppLockStage.loading,
        hasPin = false,
        errorMessage = null;

  AppLockState copyWith({
    AppLockStage? stage,
    bool? hasPin,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppLockState(
      stage: stage ?? this.stage,
      hasPin: hasPin ?? this.hasPin,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final appLockControllerProvider =
    AsyncNotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);

class AppLockController extends AsyncNotifier<AppLockState> {
  @override
  Future<AppLockState> build() async {
    return _bootstrap();
  }

  Future<AppLockState> _bootstrap() async {
    final hasPin = await ref.read(hasPinUseCaseProvider).call();
    return AppLockState(
      stage: hasPin ? AppLockStage.locked : AppLockStage.setup,
      hasPin: hasPin,
    );
  }

  Future<void> refreshLockState() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_bootstrap);
  }

  Future<void> setupPin(String pin, String confirmPin) async {
    final current = state.valueOrNull ??
        const AppLockState(stage: AppLockStage.setup, hasPin: false);
    state = const AsyncLoading();
    try {
      if (pin != confirmPin) {
        throw const ValidationFailure('PIN entries do not match.');
      }
      await ref.read(setupPinUseCaseProvider).call(pin);
      state = const AsyncData(
        AppLockState(
          stage: AppLockStage.unlocked,
          hasPin: true,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          stage: AppLockStage.setup,
          hasPin: false,
          errorMessage: error is Failure ? error.message : error.toString(),
        ),
      );
    }
  }

  Future<void> unlock(String pin) async {
    final current = state.valueOrNull ??
        const AppLockState(stage: AppLockStage.locked, hasPin: true);
    state = const AsyncLoading();
    try {
      final isValid = await ref.read(verifyPinUseCaseProvider).call(pin);
      if (!isValid) {
        throw const ValidationFailure('Incorrect PIN. Please try again.');
      }
      state = const AsyncData(
        AppLockState(
          stage: AppLockStage.unlocked,
          hasPin: true,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          stage: AppLockStage.locked,
          hasPin: true,
          errorMessage: error is Failure ? error.message : error.toString(),
        ),
      );
    }
  }

  Future<void> lockOnResume() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasPin) return;
    if (current.stage == AppLockStage.unlocked) {
      state = AsyncData(
        current.copyWith(
          stage: AppLockStage.locked,
          clearError: true,
        ),
      );
    }
  }
}
