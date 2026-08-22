import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/app_colors.dart';
import '../cubit/auth_cubit.dart';

class VerifyWaitSheet extends StatelessWidget {
  final String email;
  final DateTime lastChecked;

  const VerifyWaitSheet({
    super.key,
    required this.email,
    required this.lastChecked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
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
            'We\'ve sent a verification link to $email. Please check your inbox and click the link to verify your email.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildVerificationStatus(context),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<AuthCubit>().checkNow(email);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'I Verified My Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
                            email,
                          ),
                    child: secondsLeft > 0
                        ? Text('Resend in ${secondsLeft}s')
                        : const Text('Resend'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(lastChecked);
    final secondsAgo = difference.inSeconds;

    String timeText;
    if (secondsAgo < 60) {
      timeText = 'Last checked: $secondsAgo seconds ago';
    } else {
      timeText = 'Last checked: ${difference.inMinutes} minutes ago';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.clock,
                size: 18,
                color: AppColors.neutral700,
              ),
              const SizedBox(width: 8),
              Text(
                timeText,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const LinearProgressIndicator(
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Checking automatically every 5 seconds',
            style: TextStyle(fontSize: 12, color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }
}
