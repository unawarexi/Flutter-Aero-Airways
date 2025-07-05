import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/common/shared/custom_bottom_navigation.dart';
import 'package:flutter_aero_airways/core/services/auth_service.dart';
import 'package:flutter_aero_airways/global/authentication_provider.dart';
import 'package:flutter_aero_airways/common/widgets/status_modal.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Sign In with Email and Password
Future<void> signInWithEmailAndPassword(
  BuildContext context,
  WidgetRef ref,
  String email,
  String password,
) async {
  ref.read(authProvider.notifier).setLoading(true);
  try {
    final userCredential = await AuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      final userModel = UserModel.fromFirebaseUser(user);
      ref.read(authProvider.notifier).setUser(userModel);

      await StatusModal.showSuccess(
        context: context,
        title: 'Sign In Successful',
        message: 'Welcome back!',
        actionText: 'Continue',
        showLogo: true,
        autoDismiss: true,
        autoDismissDelay: 1500,
      );
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigationBarWidget()),
        );
      }
    }
  } catch (e) {
    final errorMessage = e.toString().replaceFirst('Exception: ', '');
    ref.read(authProvider.notifier).setError(errorMessage);
    await StatusModal.showError(
      context: context,
      title: 'Sign In Failed',
      message: errorMessage,
      actionText: 'Try Again',
      showLogo: true,
    );
  } finally {
    ref.read(authProvider.notifier).setLoading(false);
  }
}



// Sign Up with Email and Password
Future<void> signUpWithEmailAndPassword(
  BuildContext context,
  WidgetRef ref,
  String email,
  String password,
) async {
  ref.read(authProvider.notifier).setLoading(true);
  try {
    final userCredential = await AuthService.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      // Handle sign-up success with proper data fetching
      await ref.read(authProvider.notifier).handleSignUpSuccess(user);

      await StatusModal.showSuccess(
        context: context,
        title: 'Account Created',
        message: 'Your account has been created successfully!',
        actionText: 'Continue',
        showLogo: true,
        autoDismiss: true,
        autoDismissDelay: 1500,
      );
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BottomNavigationBarWidget(), // Fix: Use consistent navigation
          ),
        );
      }
    }
  } catch (e) {
    final errorMessage = e.toString().replaceFirst('Exception: ', '');
    ref.read(authProvider.notifier).setError(errorMessage);
    await StatusModal.showError(
      context: context,
      title: 'Sign Up Failed',
      message: errorMessage,
      actionText: 'Try Again',
      showLogo: true,
    );
  } finally {
    ref.read(authProvider.notifier).setLoading(false);
  }
}

// Forgot Password
Future<void> sendPasswordResetEmail(String email) async {
  await AuthService.sendPasswordResetEmail(email);
}

// // Show Auth Confirmation Dialog
// Future<void> showAuthConfirmation(
//   BuildContext context, {
//   required AuthConfirmationStatus status,
//   required String message,
//   required String actionLabel,
// }) async {
//   await AuthConfirmationScreen.show(
//     context,
//     status: status,
//     message: message,
//     actionLabel: actionLabel,
//   );
// }

// // Navigate to Home
// Future<void> navigateToHome(
//   BuildContext context,
//   User user,
//   WidgetRef ref,
// ) async {
//   try {
//     // Set Firebase user in provider
//     final firebaseUser = UserModel(
//       uid: user.uid,
//       displayName: user.displayName ?? 'User',
//       email: user.email ?? '',
//       photoURL: user.photoURL ?? '',
//       phoneNumber: user.phoneNumber ?? '',
//     );
//     ref.read(userProvider.notifier).setFirebaseUser(firebaseUser);

//     // Fetch and set user info from custom API
//     await ref.read(userProvider.notifier).fetchUserInfo();

//     if (context.mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const CustomBottomNavigation(),
//         ),
//       );
//     }
//   } catch (e) {
//     debugPrint('Navigation error: $e');
//     if (context.mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const CustomBottomNavigation(),
//         ),
//       );
//     }
//   }
// }
