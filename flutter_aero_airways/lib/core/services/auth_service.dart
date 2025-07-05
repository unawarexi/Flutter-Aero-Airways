import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_aero_airways/features/authentication/data/authentication_api.dart';

class AuthService {
  // Stream to listen to auth state changes
  static Stream<User?> get authStateChanges =>
      AuthenticationApi.authStateChanges;

  // Current user
  static User? get currentUser => AuthenticationApi.currentUser;

  // Initialize authentication state
  static Future<void> initializeAuth() async =>
      AuthenticationApi.initializeAuth();

  // Google Sign In
  static Future<UserCredential> signInWithGoogle() =>
      AuthenticationApi.signInWithGoogle();

  // Email & Password Sign In
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => AuthenticationApi.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  // Email & Password Sign Up with Firestore integration
  static Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
  }) => AuthenticationApi.signUpWithEmailAndPassword(
    email: email,
    password: password,
    displayName: displayName,
    phoneNumber: phoneNumber,
  );

  // Password Reset
  static Future<void> sendPasswordResetEmail(String email) =>
      AuthenticationApi.sendPasswordResetEmail(email);

  // Update Password
  static Future<void> updatePassword(String newPassword) =>
      AuthenticationApi.updatePassword(newPassword);

  // Update Profile
  static Future<void> updateProfile({String? displayName, String? photoURL}) =>
      AuthenticationApi.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

  // Sign Out
  static Future<void> signOut() => AuthenticationApi.signOut();

  // Delete Account
  static Future<void> deleteAccount() => AuthenticationApi.deleteAccount();

  // Re-authenticate user
  static Future<void> reauthenticateWithCredential(AuthCredential credential) =>
      AuthenticationApi.reauthenticateWithCredential(credential);

  // Get fresh authentication token
  static Future<String?> getAuthToken() => AuthenticationApi.getAuthToken();

  // Check if user is authenticated
  static Future<bool> isAuthenticated() => AuthenticationApi.isAuthenticated();

  // NEW: Fetch user by ID
  static Future<Map<String, dynamic>?> getUserById(String userId) =>
      AuthenticationApi.getUserById(userId);

  // NEW: Fetch all users
  static Future<List<Map<String, dynamic>>> getAllUsers({
    int? limit,
    String? orderBy,
    bool descending = false,
  }) => AuthenticationApi.getAllUsers(
    limit: limit,
    orderBy: orderBy,
    descending: descending,
  );

  // NEW: Search users
  static Future<List<Map<String, dynamic>>> searchUsers(String searchTerm) =>
      AuthenticationApi.searchUsers(searchTerm);

  // NEW: Get current user's full data
  static Future<Map<String, dynamic>?> getCurrentUserData() =>
      AuthenticationApi.getCurrentUserData();
}
