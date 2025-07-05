import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/core/services/auth_service.dart';
import 'package:flutter_aero_airways/common/shared/custom_bottom_navigation.dart';
import 'package:flutter_aero_airways/global/authentication_provider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_aero_airways/common/widgets/status_modal.dart';

class GoogleAuthentication extends StatefulWidget {
  final VoidCallback? onAuthSuccess;
  final Function(String)? onAuthError;

  const GoogleAuthentication({super.key, this.onAuthSuccess, this.onAuthError});

  @override
  State<GoogleAuthentication> createState() => _GoogleAuthenticationState();
}

class _GoogleAuthenticationState extends State<GoogleAuthentication> {
  bool _isLoading = false;

  // Use Consumer to access Riverpod providers
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final authState = ref.watch(authProvider);

        return Container(
          padding: const EdgeInsets.only(top: 10),
          height: 60,
          child: Stack(
            children: [
              SignInButton(
                buttonType: ButtonType.google,
                onPressed: _isLoading ? null : () => _handleGoogleSignIn(ref),
              ),
              if (_isLoading || authState.isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn(WidgetRef ref) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });
    ref.read(authProvider.notifier).setLoading(true);

    try {
      // Sign in with Google
      final UserCredential userCredential =
          await AuthService.signInWithGoogle();

      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel.fromFirebaseUser(user);
        ref.read(authProvider.notifier).setUser(userModel);

        if (mounted) {
          await StatusModal.showSuccess(
            context: context,
            title: 'Success',
            message: 'Successfully signed in with Google!',
            actionText: "Continue",
            showLogo: true,
            autoDismiss: true,
            autoDismissDelay: 1500,
          );
          // Navigate to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavigationBarWidget(
               
              ),
            ),
          );
        }
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      ref.read(authProvider.notifier).setError(errorMessage);

      if (mounted) {
        await StatusModal.showError(
          context: context,
          title: 'Sign In Failed',
          message: errorMessage,
          actionText: "Try Again",
          showLogo: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ref.read(authProvider.notifier).setLoading(false);
      }
    }
  }
}
   

//   Future<void> _navigateToHome(WidgetRef ref, User user) async {
//     try {
//       // Set Firebase user in provider
//       ref
//           .read(userProvider.notifier)
//           .setFirebaseUser(
//             UserModel(
//               uid: user.uid,
//               displayName: user.displayName ?? 'User',
//               email: user.email ?? '',
//               photoURL: user.photoURL ?? '',
//               phoneNumber: user.phoneNumber ?? '',
//             ),
//           );
//       // Fetch and set user info from custom API
//       await ref.read(userProvider.notifier).fetchUserInfo();

//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const CustomBottomNavigation(),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Navigation error: $e');
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const CustomBottomNavigation(),
//           ),
//         );
//       }
//     }
//   }
// }
