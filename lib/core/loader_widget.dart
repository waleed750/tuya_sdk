// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'app_colors.dart';
export 'package:loader_overlay/loader_overlay.dart';

class LoaderWidget {
  // static Future<dynamic> showByKey(Future Function() waitingFor) async {
  //   // final context = rootNavigatorKey.currentContext;
  //   if (context != null && context.mounted) {
  //     await show(context, waitingFor);
  //   } else {
  //     await waitingFor();
  //   }
  // }

  static Widget showLoaderWidget() {
    return CircularProgressIndicator(
      color: AppColors.primary,
      strokeCap: StrokeCap.round,
      backgroundColor: AppColors.textSecondary.withAlpha(70),
    );
  }

  static dynamic show(
    BuildContext context,
    Future Function() waitingFor,
  ) async {
    try {
      context.loaderOverlay.show(
        widgetBuilder: (progress) => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            // size: 50.0,
          ),
        ),
      );
      await Future.delayed(Duration.zero);
      await waitingFor();
      context.loaderOverlay.hide();
    } catch (e) {
      log('LoaderWidget.show error is $e');

      context.loaderOverlay.hide();
    }
  }

  static void showLoader(BuildContext context) => context.loaderOverlay.show();

  static void closeLoader(BuildContext context) => context.loaderOverlay.hide();
  static dynamic circleProgressIndicator({double size = 50.0}) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: size,
      ),
    );
  }
}
