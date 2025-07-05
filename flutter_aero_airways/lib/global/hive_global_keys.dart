import 'package:flutter/material.dart';

/// Global keys for app-wide access
/// This file should be imported wherever global navigation or messaging is needed
class GlobalKeys {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}

/// Utility class for global navigation and messaging
class GlobalUtils {
  /// Get the current context from the navigator
  static BuildContext? get currentContext =>
      GlobalKeys.navigatorKey.currentContext;

  /// Show a snackbar globally
  static void showSnackBar(String message, {Color? backgroundColor}) {
    final messenger = GlobalKeys.scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor),
      );
    }
  }

  /// Show a global dialog
  static Future<T?> showGlobalDialog<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    final context = currentContext;
    if (context != null) {
      return showDialog<T>(
        context: context,
        builder: builder,
        barrierDismissible: barrierDismissible,
      );
    }
    return Future.value(null);
  }

  /// Navigate to a named route globally
  static Future<T?> navigateToNamed<T>(String routeName, {Object? arguments}) {
    final navigator = GlobalKeys.navigatorKey.currentState;
    if (navigator != null) {
      return navigator.pushNamed<T>(routeName, arguments: arguments);
    }
    return Future.value(null);
  }

  /// Navigate and replace current route globally
  static Future<T?> navigateAndReplace<T>(
    String routeName, {
    Object? arguments,
  }) {
    final navigator = GlobalKeys.navigatorKey.currentState;
    if (navigator != null) {
      return navigator.pushReplacementNamed<T, dynamic>(
        routeName,
        arguments: arguments,
      );
    }
    return Future.value(null);
  }

  /// Pop the current route globally
  static void pop<T>([T? result]) {
    final navigator = GlobalKeys.navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop<T>(result);
    }
  }
}
