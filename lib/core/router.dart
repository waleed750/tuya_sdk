import 'dart:async';

import 'package:example/features/devices/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/devices/presentation/pages/devices_list_page.dart';

final appRouter = AppRouter();

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/auth',
    debugLogDiagnostics: true,
    // refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      // final currentState = authCubit.state;
      // final isAuthenticated = currentState is AuthAuthenticated;
      // final isAuthRoute = state.name == '/';

      // // If user is authenticated and trying to access auth page, redirect to devices
      // if (isAuthenticated && isAuthRoute) {
      //   return '/devices';
      // }

      // // If user is not authenticated and trying to access protected routes, redirect to auth
      // if (!isAuthenticated && !isAuthRoute) {
      //   return '/';
      // }

      return null;
    },
    routes: [
      GoRoute(
        name: 'auth',
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: 'devices',
        path: '/devices',
        builder: (context, state) => const DevicesListPage(),
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
