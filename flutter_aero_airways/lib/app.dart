import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/core/services/storage_service.dart';
import 'package:flutter_aero_airways/core/themes/app_theme.dart';
import 'package:flutter_aero_airways/features/authentication/presentation/login.dart';
import 'package:flutter_aero_airways/global/hive_global_keys.dart';
import 'package:flutter_aero_airways/screens/onbaording_screens/onboarding_screen.dart';
import 'package:flutter_aero_airways/common/shared/custom_bottom_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,

        // Register the global keys here
        navigatorKey: GlobalKeys.navigatorKey,
        scaffoldMessengerKey: GlobalKeys.scaffoldMessengerKey,

        // builder: (context, child) {
        //   final Brightness brightness = MediaQuery.of(
        //     context,
        //   ).platformBrightness;

        //   SystemChrome.setSystemUIOverlayStyle(
        //     SystemUiOverlayStyle(
        //       statusBarColor: brightness == Brightness.dark
        //           ? TColors.backgroundDarkAlt
        //           : TColors.backgroundLight,
        //       statusBarIconBrightness: brightness == Brightness.dark
        //           ? Brightness.light
        //           : Brightness.dark,
        //       statusBarBrightness: brightness == Brightness.dark
        //           ? Brightness.dark
        //           : Brightness.light,
        //     ),
        //   );
        //   return child!;
        // },
        home: FutureBuilder<bool>(
          future: StorageService.isAuthenticated(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show splash/loading
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.data == true) {
              // User is authenticated, go to main app
              return BottomNavigationBarWidget();
            }
            // Not authenticated, show onboarding
            return const OnboardingScreen();
          },
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/onboarding':
              return MaterialPageRoute(
                builder: (context) => const OnboardingScreen(),
              );
            case '/login':
              return MaterialPageRoute(builder: (context) => const Login());
            case '/home':
              return MaterialPageRoute(
                builder: (context) => BottomNavigationBarWidget(),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const OnboardingScreen(),
              );
          }
        },
      ),
    );
  }
}
