import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../presentation/providers/app_lock_provider.dart';
import '../widgets/app_loading_indicator.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lockAsync = ref.watch(appLockControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: lockAsync.when(
                    loading: () =>
                        const AppLoadingIndicator(message: 'Securing app...'),
                    error: (error, _) => _LockContent(
                      title: 'App Lock',
                      subtitle: error.toString(),
                      pinController: _pinController,
                      confirmPinController: _confirmPinController,
                      isSetup: false,
                      onSubmit: _unlock,
                    ),
                    data: (state) => _LockContent(
                      title: state.stage == AppLockStage.setup
                          ? 'Create PIN'
                          : 'Unlock App',
                      subtitle: state.stage == AppLockStage.setup
                          ? 'Set a 4-digit PIN to protect your expense data.'
                          : (state.errorMessage ??
                              'Enter your 4-digit PIN to continue.'),
                      pinController: _pinController,
                      confirmPinController: _confirmPinController,
                      isSetup: state.stage == AppLockStage.setup,
                      onSubmit: state.stage == AppLockStage.setup
                          ? _setupPin
                          : _unlock,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setupPin() async {
    await ref.read(appLockControllerProvider.notifier).setupPin(
          _pinController.text.trim(),
          _confirmPinController.text.trim(),
        );
    _clearInputs();
  }

  Future<void> _unlock() async {
    await ref
        .read(appLockControllerProvider.notifier)
        .unlock(_pinController.text.trim());
    _clearInputs();
  }

  void _clearInputs() {
    _pinController.clear();
    _confirmPinController.clear();
  }
}

class _LockContent extends StatelessWidget {
  const _LockContent({
    required this.title,
    required this.subtitle,
    required this.pinController,
    required this.confirmPinController,
    required this.isSetup,
    required this.onSubmit,
  });

  final String title;
  final String subtitle;
  final TextEditingController pinController;
  final TextEditingController confirmPinController;
  final bool isSetup;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          size: 48,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(
            labelText: 'PIN',
            counterText: '',
          ),
        ),
        if (isSetup) ...[
          const SizedBox(height: 16),
          TextField(
            controller: confirmPinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: 'Confirm PIN',
              counterText: '',
            ),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onSubmit,
          child: Text(isSetup ? 'Save PIN' : 'Unlock'),
        ),
      ],
    );
  }
}
