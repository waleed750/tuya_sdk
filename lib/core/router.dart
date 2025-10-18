import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/devices/devices_page.dart';
import '../features/devices/presentation/pages/home_page.dart';
import '../features/devices/wifi_onboarding_page.dart';
import '../features/devices/ble_onboarding_page.dart';

final appRouter = AppRouter();

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/auth',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthPage = state.fullPath == '/auth';
      final authCubit = context.read<AuthCubit>();
      final isAuthenticated = authCubit.state is AuthAuthenticated;

      // If authenticated and on auth page, go to home
      if (isAuthenticated && isAuthPage) {
        return '/home';
      }

      // If not authenticated and not on auth page, go to auth
      if (!isAuthenticated && !isAuthPage) {
        return '/auth';
      }

      // No redirection needed
      return null;
    },
    routes: [
      GoRoute(
        name: 'auth',
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        name: 'home',
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: 'devices',
        path: '/devices',
        builder: (context, state) => const DevicesPage(),
      ),
      GoRoute(
        name: 'onboarding_wifi',
        path: '/onboarding/wifi',
        builder: (context, state) => const WifiOnboardingPage(),
      ),
      GoRoute(
        name: 'onboarding_ble',
        path: '/onboarding/ble',
        builder: (context, state) => const BleOnboardingPage(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}

// Helper class to convert Cubit stream to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final Stream<dynamic> _stream;
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) : _stream = stream {
    _subscription = _stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
