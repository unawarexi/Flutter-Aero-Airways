import 'package:flutter_aero_airways/core/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_aero_airways/core/services/storage_service.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final String phoneNumber;
  final bool emailVerified;
  final String provider;
  final DateTime? createdAt;
  final DateTime? lastSignInTime;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoURL,
    required this.phoneNumber,
    required this.emailVerified,
    required this.provider,
    this.createdAt,
    this.lastSignInTime,
    required this.isActive,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      displayName: user.displayName ?? 'User',
      email: user.email ?? '',
      photoURL: user.photoURL ?? '',
      phoneNumber: user.phoneNumber ?? '',
      emailVerified: user.emailVerified,
      provider: 'firebase',
      createdAt: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
      isActive: true,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? 'User',
      email: map['email'] ?? '',
      photoURL: map['photoURL'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
      provider: map['provider'] ?? 'unknown',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      lastSignInTime: map['lastSignInTime'] != null
          ? DateTime.tryParse(map['lastSignInTime'])
          : null,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'provider': provider,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInTime': lastSignInTime?.toIso8601String(),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
    String? phoneNumber,
    bool? emailVerified,
    String? provider,
    DateTime? createdAt,
    DateTime? lastSignInTime,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      isActive: isActive ?? this.isActive,
    );
  }
}

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final List<UserModel>? allUsers;
  final bool isLoadingUsers;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.allUsers,
    this.isLoadingUsers = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    List<UserModel>? allUsers,
    bool? isLoadingUsers,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      allUsers: allUsers ?? this.allUsers,
      isLoadingUsers: isLoadingUsers ?? this.isLoadingUsers,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _initializeAuth();
  }

  // Initialize authentication and load user data
  Future<void> _initializeAuth() async {
    try {
      setLoading(true);

      // Check if user is authenticated
      final isAuth = await AuthService.isAuthenticated();
      if (isAuth) {
        await _loadUserFromStorage();
      }
    } catch (e) {
      setError('Failed to initialize authentication: $e');
    } finally {
      setLoading(false);
    }
  }

  // Load user data from storage
  Future<void> _loadUserFromStorage() async {
    try {
      final userData = await StorageService.getUserData();
      if (userData != null) {
        final user = UserModel.fromMap(userData);
        setUser(user);
      }
    } catch (e) {
      setError('Failed to load user data: $e');
    }
  }

  // Set user and update storage
  void setUser(UserModel user) {
    state = state.copyWith(user: user, isLoading: false, error: null);
    _saveUserToStorage(user);
  }

  // Save user data to storage
  Future<void> _saveUserToStorage(UserModel user) async {
    try {
      await StorageService.saveUserData(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        phoneNumber: user.phoneNumber,
        emailVerified: user.emailVerified,
        provider: user.provider,
        createdAt: user.createdAt,
        lastSignInTime: user.lastSignInTime,
        isActive: user.isActive,
      );
    } catch (e) {
      setError('Failed to save user data: $e');
    }
  }

  // Update user data
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      setUser(updatedUser);

      // Update in Firestore via AuthService
      await AuthService.updateProfile(
        displayName: updatedUser.displayName,
        photoURL: updatedUser.photoURL,
      );
    } catch (e) {
      setError('Failed to update user: $e');
    }
  }

  // Refresh current user data
  Future<void> refreshCurrentUser() async {
    try {
      setLoading(true);

      final currentUserData = await AuthService.getCurrentUserData();
      if (currentUserData != null) {
        final user = UserModel.fromMap(currentUserData);
        setUser(user);
      }
    } catch (e) {
      setError('Failed to refresh user data: $e');
    } finally {
      setLoading(false);
    }
  }

  // Load all users
  Future<void> loadAllUsers({
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      state = state.copyWith(isLoadingUsers: true);

      final usersData = await AuthService.getAllUsers(
        limit: limit,
        orderBy: orderBy,
        descending: descending,
      );

      final users = usersData
          .map((userData) => UserModel.fromMap(userData))
          .toList();

      state = state.copyWith(allUsers: users, isLoadingUsers: false);
    } catch (e) {
      state = state.copyWith(isLoadingUsers: false);
      setError('Failed to load users: $e');
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String searchTerm) async {
    try {
      final usersData = await AuthService.searchUsers(searchTerm);
      return usersData.map((userData) => UserModel.fromMap(userData)).toList();
    } catch (e) {
      setError('Failed to search users: $e');
      return [];
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final userData = await AuthService.getUserById(userId);
      if (userData != null) {
        return UserModel.fromMap(userData);
      }
      return null;
    } catch (e) {
      setError('Failed to get user: $e');
      return null;
    }
  }

  // Handle authentication success (for both Google and Email)
  Future<void> handleAuthSuccess(User firebaseUser) async {
    try {
      setLoading(true);

      // Get complete user data from Firestore
      final firestoreData = await AuthService.getCurrentUserData();

      UserModel user;
      if (firestoreData != null) {
        // Use Firestore data if available
        user = UserModel.fromMap(firestoreData);
      } else {
        // Fallback to Firebase Auth data
        user = UserModel.fromFirebaseUser(firebaseUser);
      }

      setUser(user);
    } catch (e) {
      setError('Failed to handle authentication: $e');
    } finally {
      setLoading(false);
    }
  }

// Add this method to your AuthNotifier class
  Future<void> handleSignUpSuccess(User firebaseUser) async {
    try {
      setLoading(true);

      // Wait for Firestore document creation to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Retry fetching user data from Firestore
      Map<String, dynamic>? firestoreData;
      int retryCount = 0;
      const maxRetries = 3;

      while (firestoreData == null && retryCount < maxRetries) {
        firestoreData = await AuthService.getCurrentUserData();
        if (firestoreData == null) {
          retryCount++;
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      }

      UserModel user;
      if (firestoreData != null) {
        user = UserModel.fromMap(firestoreData);
      } else {
        // Fallback to Firebase Auth data
        user = UserModel.fromFirebaseUser(firebaseUser);
      }

      setUser(user);
    } catch (e) {
      setError('Failed to complete sign up: $e');
    } finally {
      setLoading(false);
    }
  }


  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading, error: null);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void clear() {
    state = AuthState();
  }
}

// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user != null;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final allUsersProvider = Provider<List<UserModel>?>((ref) {
  return ref.watch(authProvider).allUsers;
});

final isLoadingUsersProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoadingUsers;
});
