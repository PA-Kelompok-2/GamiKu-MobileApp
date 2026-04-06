import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class StartupMiddleware extends GetMiddleware {
  static bool _handledInitialRoute = false;

  @override
  RouteSettings? redirect(String? route) {
    if (_handledInitialRoute) return null;

    _handledInitialRoute = true;

    if (route == Routes.splash) return null;

    return const RouteSettings(name: Routes.splash);
  }
}