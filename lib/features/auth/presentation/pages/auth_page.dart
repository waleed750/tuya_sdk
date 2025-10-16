import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
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
            // _showVerificationSheet(context, state);
          } else if (state is AuthAuthenticated) {
            // Navigate to the main app page or home screen
            final user = context.read<AuthCubit>().user;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: Center(
                    child: Text('User Data : \n ${user.toString()}'),
                  ),
                ),
              ),
            );
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
                    if (state is! AuthLoading) _buildCupertinoSegment(context),
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

  Widget _buildCupertinoSegment(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AuthCubit>().isRegisterMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(150.0),
      child: CupertinoSegmentedControl<bool>(
        groupValue: state,
        selectedColor: AppColors.primary,
        unselectedColor: CupertinoColors.systemGrey,
        borderColor: CupertinoColors.systemGrey,
        children: {
          false: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Login',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          true: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Register',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        },
        onValueChanged: (isRegister) {
          final cubit = context.read<AuthCubit>();
          final current = cubit.state;
          if (current is AuthIdle && current.isRegisterMode != isRegister) {
            cubit.toggleMode();
          }
        },
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
    } else {
      return context.read<AuthCubit>().isRegisterMode
          ? const RegisterForm()
          : const LoginForm();
    }
  }

  // void _showVerificationSheet(
  //   BuildContext context,
  //   AuthNeedsVerification state,
  // ) {
  //   showModalBottomSheet(
  //     context: context,
  //     isDismissible: false,
  //     enableDrag: false,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) =>
  //         VerifyWaitSheet(email: state.email, lastChecked: state.lastChecked),
  //   );
  // }
}
