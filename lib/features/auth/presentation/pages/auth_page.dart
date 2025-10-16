import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_form.dart';
import '../widgets/verify_wait_sheet.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AuthNeedsVerification) {
            _showVerificationSheet(context, state);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    _buildHeader(context, state),
                    const SizedBox(height: 40),
                    if (state is AuthIdle)
                      _buildSegmentedControl(context, state),
                    const SizedBox(height: 32),
                    _buildContent(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState state) {
    final isRegisterMode = state is AuthIdle ? state.isRegisterMode : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRegisterMode ? 'Create Account' : 'Welcome Back',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isRegisterMode
              ? 'Sign up to get started with Tuya Smart Home'
              : 'Sign in to access your Tuya Smart Home',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.neutral600),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl(BuildContext context, AuthIdle state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              context,
              title: 'Login',
              isSelected: !state.isRegisterMode,
              onTap: () {
                if (state.isRegisterMode) {
                  context.read<AuthCubit>().toggleMode();
                }
              },
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              context,
              title: 'Register',
              isSelected: state.isRegisterMode,
              onTap: () {
                if (!state.isRegisterMode) {
                  context.read<AuthCubit>().toggleMode();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.neutral700,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            state.message ?? 'Loading...',
            style: const TextStyle(color: AppColors.neutral700),
          ),
        ],
      );
    } else if (state is AuthIdle) {
      return AuthForm(isRegisterMode: state.isRegisterMode);
    }

    // Default empty container for other states
    return Container();
  }

  void _showVerificationSheet(
    BuildContext context,
    AuthNeedsVerification state,
  ) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          VerifyWaitSheet(email: state.email, lastChecked: state.lastChecked),
    );
  }
}
