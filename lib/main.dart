import 'package:example/core/cache/app_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_flutter_ha_sdk/tuya_flutter_ha_sdk.dart';

import 'app_bloc_observer.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/devices/presentation/cubit/devices_cubit.dart';
import 'tuya_configuration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  // Initialize Tuya SDK
  try {
    await TuyaFlutterHaSdk.tuyaSdkInit(
      androidKey: TuyaConfig.androidAppKey,
      androidSecret: TuyaConfig.androidAppSecret,
      iosKey: TuyaConfig.iosAppKey,
      iosSecret: TuyaConfig.iosAppSecret,
      isDebug: true, // Set to false for production
    );
    debugPrint('✅ Tuya SDK initialization succeeded');
  } catch (e, stack) {
    debugPrint('⛔ Tuya SDK initialization failed: $e');
    debugPrint(stack.toString());
  }
  AppPreferences().init();
  // Initialize dependency injection

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()..automateLogin()),
        BlocProvider(create: (context) => DevicesCubit()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Tuya Smart Home',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: appRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
