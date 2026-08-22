import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/app_colors.dart';
import '../cubit/auth_cubit.dart';

class RegisterVerifySheet extends StatefulWidget {
  final String email;
  final String password;

  const RegisterVerifySheet({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterVerifySheet> createState() => _RegisterVerifySheetState();
}

class _RegisterVerifySheetState extends State<RegisterVerifySheet> {
  late final TextEditingController _codeController;
  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: 150,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Icon(LucideIcons.mail, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Verify your email',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ve sent a verification code to ${widget.email}. Please check your inbox and enter the code below.',

              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                hintText: 'Enter verification code',
                prefixIcon: const Icon(Icons.pin_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<AuthCubit>().register(
                                email: widget.email,
                                password: widget.password,
                                countryCode: '+1',
                                code: _codeController.text.trim(),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Complete Registration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    context.read<AuthCubit>().cancelVerification();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    int secondsLeft = 0;
                    if (state is AuthNeedsVerification) {
                      secondsLeft = state.resendSecondsLeft;
                    }
                    return TextButton(
                      onPressed: secondsLeft > 0
                          ? null
                          : () => context.read<AuthCubit>().resendVerification(
                              widget.email,
                            ),
                      child: secondsLeft > 0
                          ? Text('Resend in ${secondsLeft}s')
                          : const Text('Resend Code'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
