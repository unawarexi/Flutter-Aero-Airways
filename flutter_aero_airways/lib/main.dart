import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/core/errors/initialization_error_screen.dart';
import 'package:flutter_aero_airways/core/network/pull_referesh.dart';
import 'package:flutter_aero_airways/features/flight_management/domain/hive_init.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'app.dart';

// refresh wrapper providing refresh functionality to entire app
class GlobalRefreshWrapper extends StatefulWidget {
  final Widget child;

  const GlobalRefreshWrapper({super.key, required this.child});

  @override
  State<GlobalRefreshWrapper> createState() => _GlobalRefreshWrapperState();
}

class _GlobalRefreshWrapperState extends State<GlobalRefreshWrapper> {
  final GlobalRefreshController _globalController = GlobalRefreshController();

  @override
  void dispose() {
    _globalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshProvider(controller: _globalController, child: widget.child);
  }
}

// Provider for sharing refresh functionality
class RefreshProvider extends InheritedWidget {
  final GlobalRefreshController controller;

  const RefreshProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  static RefreshProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RefreshProvider>();
  }

  @override
  bool updateShouldNotify(RefreshProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Initialize Hive and register adapters
Future<void> initializeHive() async {
  try {
    await HiveInitializer.initialize();
    debugPrint('Hive initialized successfully');
    debugPrint(HiveInitializer.storageInfo);
  } catch (e) {
    debugPrint('Error initializing Hive: $e');
    rethrow;
  }
}

Future<void> main() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    // Load environment variables and firebase
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await initializeHive();

    FlutterNativeSplash.remove();

    // Wrap the app with GlobalRefreshWrapper for app-wide pull-to-refresh
    runApp(const GlobalRefreshWrapper(child: App()));
     

  } catch (e) {
    debugPrint('Error during app initialization: $e');

    // Show a more user-friendly error screen
    runApp(
      MaterialApp(
        title: 'Aero Airways',
        theme: ThemeData(primarySwatch: Colors.green),
        home: InitializationErrorScreen(error: e.toString()),
      ),
    );
  }
}



