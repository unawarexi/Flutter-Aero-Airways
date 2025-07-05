import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_aero_airways/core/services/storage_service.dart';

class AuthenticationApi {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;

  static Future<void> initializeAuth() async {
    try {
      final user = currentUser;
      if (user != null) {
        await _saveUserTokensAndData(user, LocalAuthProvider.unknown);
      }
    } catch (e) {
      debugPrint('Failed to initialize auth: $e');
    }
  }

  static Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled by user');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      await userCredential.user?.getIdToken(true);
      await _saveUserTokensAndData(
        userCredential.user!,
        LocalAuthProvider.google,
      );

      // Check if user exists in Firestore, create if not
      await _createOrUpdateUserInFirestore(userCredential.user!);

      return userCredential;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      await userCredential.user?.getIdToken(true);
      await _saveUserTokensAndData(
        userCredential.user!,
        LocalAuthProvider.emailPassword,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Email sign in failed: $e');
    }
  }

  static Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      // Update the user's display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
        await userCredential.user?.reload();
      }

      await userCredential.user?.getIdToken(true);
      await _saveUserTokensAndData(
        userCredential.user!,
        LocalAuthProvider.emailPassword,
      );

      // Create user document in Firestore
      await _createUserInFirestore(
        userCredential.user!,
        phoneNumber: phoneNumber,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Email sign up failed: $e');
    }
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  static Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user is currently signed in');
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  static Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user is currently signed in');
      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoURL != null) await user.updatePhotoURL(photoURL);
      await user.reload();
      final updatedUser = _auth.currentUser!;
      await _saveUserData(updatedUser);

      // Update Firestore user document
      await _updateUserInFirestore(updatedUser);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await StorageService.clearAllData();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  static Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user is currently signed in');

      // Delete user document from Firestore
      await _deleteUserFromFirestore(user.uid);

      await user.delete();
      await StorageService.clearAllData();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Please sign in again before deleting your account');
      }
      throw Exception(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  static Future<void> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user is currently signed in');
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception('Re-authentication failed: $e');
    }
  }

  static Future<String?> getAuthToken() async {
    try {
      return await StorageService.getValidToken();
    } catch (e) {
      debugPrint('Failed to get auth token: $e');
      return null;
    }
  }

  static Future<bool> isAuthenticated() async {
    return await StorageService.isAuthenticated();
  }

  // NEW: Fetch user by ID from Firestore
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch user by ID: $e');
      throw Exception('Failed to fetch user: $e');
    }
  }

  // NEW: Fetch all users from Firestore
  static Future<List<Map<String, dynamic>>> getAllUsers({
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = _firestore.collection('users');

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      debugPrint('Failed to fetch all users: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  // NEW: Search users by email or display name
  static Future<List<Map<String, dynamic>>> searchUsers(
    String searchTerm,
  ) async {
    try {
      final searchTermLower = searchTerm.toLowerCase();

      // Search by email
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: searchTermLower)
          .where('email', isLessThan: '$searchTermLower\uf8ff')
          .get();

      // Search by display name
      final nameQuery = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: searchTermLower)
          .where('displayName', isLessThan: '$searchTermLower\uf8ff')
          .get();

      // Combine results and remove duplicates
      final Set<String> seenIds = {};
      final List<Map<String, dynamic>> results = [];

      for (final doc in [...emailQuery.docs, ...nameQuery.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add({'id': doc.id, ...doc.data()});
        }
      }

      return results;
    } catch (e) {
      debugPrint('Failed to search users: $e');
      throw Exception('Failed to search users: $e');
    }
  }

  // NEW: Get current user's full data from Firestore
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      return await getUserById(user.uid);
    } catch (e) {
      debugPrint('Failed to get current user data: $e');
      return null;
    }
  }

  // Firestore Methods
  static Future<void> _createUserInFirestore(
    User user, {
    String? phoneNumber,
  }) async {
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'phoneNumber': phoneNumber ?? user.phoneNumber ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'provider': 'email',
        'emailVerified': user.emailVerified,
        'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
        'creationTime': user.metadata.creationTime?.toIso8601String(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
      debugPrint('User created in Firestore: ${user.uid}');
    } catch (e) {
      debugPrint('Failed to create user in Firestore: $e');
      // Don't throw here to avoid breaking the signup flow
    }
  }

  static Future<void> _createOrUpdateUserInFirestore(User user) async {
    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        // Create new user document
        await _createUserInFirestore(user);
      } else {
        // Update existing user document
        await userDocRef.update({
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'emailVerified': user.emailVerified,
          'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Failed to create or update user in Firestore: $e');
    }
  }

  static Future<void> _updateUserInFirestore(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'emailVerified': user.emailVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to update user in Firestore: $e');
    }
  }

  static Future<void> _deleteUserFromFirestore(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      debugPrint('User deleted from Firestore: $uid');
    } catch (e) {
      debugPrint('Failed to delete user from Firestore: $e');
    }
  }

  // Private helpers
  static Future<void> _saveUserTokensAndData(
    User user,
    LocalAuthProvider provider,
  ) async {
    try {
      final idTokenResult = await user.getIdTokenResult();
      await StorageService.saveAuthTokens(
        accessToken: idTokenResult.token,
        idToken: idTokenResult.token,
        expiryTime: idTokenResult.expirationTime,
      );
      await _saveUserData(user);
      await StorageService.saveAuthProvider(provider);
    } catch (e) {
      debugPrint('Failed to save user tokens and data: $e');
    }
  }

  static Future<void> _saveUserData(User user) async {
    // Get additional user data from Firestore
    final firestoreData = await getUserById(user.uid);

    await StorageService.saveUserData(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? firestoreData?['displayName'] ?? '',
      photoURL: user.photoURL ?? firestoreData?['photoURL'] ?? '',
      phoneNumber: user.phoneNumber ?? firestoreData?['phoneNumber'] ?? '',
      emailVerified: user.emailVerified,
      provider: firestoreData?['provider'] ?? 'unknown',
      createdAt: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
      isActive: firestoreData?['isActive'] ?? true,
    );
  }

  static String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Invalid password.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
