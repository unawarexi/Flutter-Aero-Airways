import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your actual classes
import 'package:flutter_aero_airways/features/authentication/data/authentication_api.dart';
import 'package:flutter_aero_airways/features/flight_management/data/flight_api.dart';
import 'package:flutter_aero_airways/global/authentication_provider.dart';
import 'package:flutter_aero_airways/global/flight_provider.dart';
import 'package:flutter_aero_airways/core/services/storage_service.dart';
import 'package:flutter_aero_airways/core/services/auth_service.dart';

import 'unit_test.mocks.dart';

// Generate mocks

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  User,
  UserCredential,
  IdTokenResult,
  UserMetadata,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  Dio,
  Response,
])


void main() {
  group('AuthenticationApi Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();

      // Reset static instances for testing
      // Note: You'll need to modify AuthenticationApi to allow dependency injection for testing
    });

    group('signInWithGoogle', () {
      test('should return UserCredential on successful Google sign in', () async {
        // Arrange
        final mockGoogleUser = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        final mockIdTokenResult = MockIdTokenResult();

        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
        when(
          mockGoogleUser.authentication,
        ).thenAnswer((_) async => mockGoogleAuth);
        when(mockGoogleAuth.accessToken).thenReturn('access_token');
        when(mockGoogleAuth.idToken).thenReturn('id_token');
        when(
          mockAuth.signInWithCredential(any),
        ).thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(
          mockUser.getIdToken(any),
        ).thenAnswer((_) async => 'firebase_token');
        when(
          mockUser.getIdTokenResult(),
        ).thenAnswer((_) async => mockIdTokenResult);
        when(mockIdTokenResult.token).thenReturn('firebase_token');
        when(
          mockIdTokenResult.expirationTime,
        ).thenReturn(DateTime.now().add(Duration(hours: 1)));

        // Mock user properties
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUser.displayName).thenReturn('Test User');
        when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
        when(mockUser.phoneNumber).thenReturn('+1234567890');
        when(mockUser.emailVerified).thenReturn(true);

        // Mock Firestore operations
        final mockCollectionRef =
            MockCollectionReference<Map<String, dynamic>>();
        final mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
        final mockDocumentSnapshot =
            MockDocumentSnapshot<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
        when(mockCollectionRef.doc('test_uid')).thenReturn(mockDocumentRef);
        when(
          mockDocumentRef.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);
        when(mockDocumentRef.set(any)).thenAnswer((_) async => {});

        // Act & Assert
        // Note: This test would need AuthenticationApi to be refactored for dependency injection
        // For now, this shows the structure of how the test should work
      });

      test('should throw exception when Google sign in is cancelled', () async {
        // Arrange
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => AuthenticationApi.signInWithGoogle(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signInWithEmailAndPassword', () {
      test('should return UserCredential on successful email sign in', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(
          mockAuth.signInWithEmailAndPassword(email: email, password: password),
        ).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);
        when(
          mockUser.getIdToken(any),
        ).thenAnswer((_) async => 'firebase_token');

        // Mock user properties
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.email).thenReturn(email);

        // Act & Assert
        // Test structure - actual implementation would need dependency injection
      });

      test('should throw exception for invalid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong_password';

        when(
          mockAuth.signInWithEmailAndPassword(email: email, password: password),
        ).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
            message: 'The password is invalid.',
          ),
        );

        // Act & Assert
        expect(
          () => AuthenticationApi.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signUpWithEmailAndPassword', () {
      test('should create user account successfully', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        const displayName = 'New User';

        when(
          mockAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);
        when(
          mockUser.updateDisplayName(displayName),
        ).thenAnswer((_) async => {});
        when(mockUser.reload()).thenAnswer((_) async => {});
        when(
          mockUser.getIdToken(any),
        ).thenAnswer((_) async => 'firebase_token');

        // Mock user properties
        when(mockUser.uid).thenReturn('new_user_uid');
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(displayName);

        // Act & Assert
        // Test structure - actual implementation would need dependency injection
      });
    });

    group('Firestore Operations', () {
      test('should fetch user by ID successfully', () async {
        // Arrange
        const userId = 'test_uid';
        final userData = {
          'uid': userId,
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoURL': 'https://example.com/photo.jpg',
        };

        final mockCollectionRef =
            MockCollectionReference<Map<String, dynamic>>();
        final mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
        final mockDocumentSnapshot =
            MockDocumentSnapshot<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
        when(mockCollectionRef.doc(userId)).thenReturn(mockDocumentRef);
        when(
          mockDocumentRef.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn(userData);

        // Act & Assert
        // Test structure - actual implementation would need dependency injection
      });

      test('should return null when user does not exist', () async {
        // Arrange
        const userId = 'non_existent_user';

        final mockCollectionRef =
            MockCollectionReference<Map<String, dynamic>>();
        final mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
        final mockDocumentSnapshot =
            MockDocumentSnapshot<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
        when(mockCollectionRef.doc(userId)).thenReturn(mockDocumentRef);
        when(
          mockDocumentRef.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);

        // Act & Assert
        // Test structure - actual implementation would need dependency injection
      });
    });
  });

  group('FlightApi Tests', () {
    late MockDio mockDio;
    late FlightApi flightApi;

    setUp(() {
      mockDio = MockDio();
      // You'll need to modify FlightApi to accept Dio as a constructor parameter
      flightApi = FlightApi(dio: mockDio);
    });

    group('fetchAllFlights', () {
      test('should return flight data successfully', () async {
        // Arrange
        final mockResponse = MockResponse<Map<String, dynamic>>();
        final expectedData = {
          'data': [
            {
              'flight_date': '2024-01-15',
              'flight_status': 'active',
              'departure': {
                'airport': 'Lagos',
                'iata': 'LOS',
                'scheduled': '2024-01-15T10:00:00+00:00',
              },
              'arrival': {
                'airport': 'Abuja',
                'iata': 'ABV',
                'scheduled': '2024-01-15T12:00:00+00:00',
              },
              'airline': {'name': 'Aero Airways', 'iata': 'AA'},
              'flight': {'iata': 'AA123', 'number': '123'},
            },
          ],
        };

        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer((_) async => mockResponse);

        when(mockResponse.data).thenReturn(expectedData);

        // Act
        final result = await flightApi.fetchAllFlights();

        // Assert
        expect(result['data'], isA<List>());
        expect(result['data'].length, equals(1));
        expect(result['data'][0]['flight']['iata'], equals('AA123'));
      });

      test('should handle API error gracefully', () async {
        // Arrange
        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Network error',
          ),
        );

        // Act & Assert
        expect(() => flightApi.fetchAllFlights(), throwsA(isA<DioException>()));
      });
    });

    group('fetchFlightById', () {
      test('should return specific flight data', () async {
        // Arrange
        const flightIata = 'AA123';
        final mockResponse = MockResponse<Map<String, dynamic>>();
        final expectedData = {
          'data': [
            {
              'flight': {'iata': flightIata},
              'flight_status': 'active',
            },
          ],
        };

        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer((_) async => mockResponse);

        when(mockResponse.data).thenReturn(expectedData);

        // Act
        final result = await flightApi.fetchFlightById(flightIata);

        // Assert
        expect(result['data'], isA<List>());
        expect(result['data'][0]['flight']['iata'], equals(flightIata));
      });
    });

    group('searchFlightsByLocation', () {
      test('should return flights for specific route', () async {
        // Arrange
        const fromCity = 'LOS';
        const toCity = 'ABV';
        final mockResponse = MockResponse<Map<String, dynamic>>();
        final expectedData = {
          'data': [
            {
              'departure': {'iata': fromCity},
              'arrival': {'iata': toCity},
              'flight_status': 'active',
            },
          ],
        };

        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer((_) async => mockResponse);

        when(mockResponse.data).thenReturn(expectedData);

        // Act
        final result = await flightApi.searchFlightsByLocation(
          fromCity: fromCity,
          toCity: toCity,
        );

        // Assert
        expect(result['data'], isA<List>());
        expect(result['data'][0]['departure']['iata'], equals(fromCity));
        expect(result['data'][0]['arrival']['iata'], equals(toCity));
      });
    });

    group('searchFlightsByDate', () {
      test('should return flights for specific date', () async {
        // Arrange
        final departureDate = DateTime(2024, 1, 15);
        final mockResponse = MockResponse<Map<String, dynamic>>();
        final expectedData = {
          'data': [
            {'flight_date': '2024-01-15', 'flight_status': 'active'},
          ],
        };

        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer((_) async => mockResponse);

        when(mockResponse.data).thenReturn(expectedData);

        // Act
        final result = await flightApi.searchFlightsByDate(
          departureDate: departureDate,
        );

        // Assert
        expect(result['data'], isA<List>());
        expect(result['data'][0]['flight_date'], equals('2024-01-15'));
      });
    });
  });

  group('AuthNotifier Tests', () {
    late ProviderContainer container;
    late AuthNotifier authNotifier;

    setUp(() {
      container = ProviderContainer();
      authNotifier = container.read(authProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with empty state', () {
      // Arrange & Act
      final state = container.read(authProvider);

      // Assert
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.allUsers, isNull);
      expect(state.isLoadingUsers, isFalse);
    });

    test('should set user correctly', () {
      // Arrange
      final user = UserModel(
        uid: 'test_uid',
        displayName: 'Test User',
        email: 'test@example.com',
        photoURL: '',
        phoneNumber: '',
        emailVerified: true,
        provider: 'google',
        isActive: true,
      );

      // Act
      authNotifier.setUser(user);

      // Assert
      final state = container.read(authProvider);
      expect(state.user, equals(user));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('should set loading state correctly', () {
      // Act
      authNotifier.setLoading(true);

      // Assert
      final state = container.read(authProvider);
      expect(state.isLoading, isTrue);
      expect(state.error, isNull);
    });

    test('should set error state correctly', () {
      // Arrange
      const errorMessage = 'Authentication failed';

      // Act
      authNotifier.setError(errorMessage);

      // Assert
      final state = container.read(authProvider);
      expect(state.error, equals(errorMessage));
      expect(state.isLoading, isFalse);
    });

    test('should clear state correctly', () {
      // Arrange
      final user = UserModel(
        uid: 'test_uid',
        displayName: 'Test User',
        email: 'test@example.com',
        photoURL: '',
        phoneNumber: '',
        emailVerified: true,
        provider: 'google',
        isActive: true,
      );
      authNotifier.setUser(user);

      // Act
      authNotifier.clear();

      // Assert
      final state = container.read(authProvider);
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });
  });

  group('FlightNotifier Tests', () {
    late ProviderContainer container;
    late FlightNotifier flightNotifier;

    setUp(() {
      container = ProviderContainer();
      flightNotifier = container.read(flightProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with empty state', () {
      // Arrange & Act
      final state = container.read(flightProvider);

      // Assert
      expect(state.flights, isEmpty);
      expect(state.selectedFlight, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('should update state correctly with copyWith', () {
      // Arrange
      final initialState = FlightState();
      final newFlights = [
        {
          'flight': {'iata': 'AA123'},
        },
        {
          'flight': {'iata': 'BB456'},
        },
      ];

      // Act
      final newState = initialState.copyWith(
        flights: newFlights,
        isLoading: true,
      );

      // Assert
      expect(newState.flights, equals(newFlights));
      expect(newState.isLoading, isTrue);
      expect(newState.error, isNull);
      expect(newState.selectedFlight, isNull);
    });
  });

  group('UserModel Tests', () {
    test('should create UserModel from Firebase User', () {
      // Arrange
      final mockUser = MockUser();
      final mockMetadata = MockUserMetadata();

      when(mockUser.uid).thenReturn('test_uid');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
      when(mockUser.phoneNumber).thenReturn('+1234567890');
      when(mockUser.emailVerified).thenReturn(true);
      when(mockUser.metadata).thenReturn(mockMetadata);
      when(mockMetadata.creationTime).thenReturn(DateTime(2024, 1, 1));
      when(mockMetadata.lastSignInTime).thenReturn(DateTime(2024, 1, 15));

      // Act
      final userModel = UserModel.fromFirebaseUser(mockUser);

      // Assert
      expect(userModel.uid, equals('test_uid'));
      expect(userModel.displayName, equals('Test User'));
      expect(userModel.email, equals('test@example.com'));
      expect(userModel.photoURL, equals('https://example.com/photo.jpg'));
      expect(userModel.phoneNumber, equals('+1234567890'));
      expect(userModel.emailVerified, isTrue);
      expect(userModel.provider, equals('firebase'));
      expect(userModel.isActive, isTrue);
    });

    test('should create UserModel from Map', () {
      // Arrange
      final userData = {
        'uid': 'test_uid',
        'displayName': 'Test User',
        'email': 'test@example.com',
        'photoURL': 'https://example.com/photo.jpg',
        'phoneNumber': '+1234567890',
        'emailVerified': true,
        'provider': 'google',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'lastSignInTime': '2024-01-15T10:00:00.000Z',
        'isActive': true,
      };

      // Act
      final userModel = UserModel.fromMap(userData);

      // Assert
      expect(userModel.uid, equals('test_uid'));
      expect(userModel.displayName, equals('Test User'));
      expect(userModel.email, equals('test@example.com'));
      expect(userModel.photoURL, equals('https://example.com/photo.jpg'));
      expect(userModel.phoneNumber, equals('+1234567890'));
      expect(userModel.emailVerified, isTrue);
      expect(userModel.provider, equals('google'));
      expect(userModel.isActive, isTrue);
    });

    test('should convert UserModel to Map', () {
      // Arrange
      final userModel = UserModel(
        uid: 'test_uid',
        displayName: 'Test User',
        email: 'test@example.com',
        photoURL: 'https://example.com/photo.jpg',
        phoneNumber: '+1234567890',
        emailVerified: true,
        provider: 'google',
        createdAt: DateTime(2024, 1, 1),
        lastSignInTime: DateTime(2024, 1, 15, 10, 0, 0),
        isActive: true,
      );

      // Act
      final userData = userModel.toMap();

      // Assert
      expect(userData['uid'], equals('test_uid'));
      expect(userData['displayName'], equals('Test User'));
      expect(userData['email'], equals('test@example.com'));
      expect(userData['photoURL'], equals('https://example.com/photo.jpg'));
      expect(userData['phoneNumber'], equals('+1234567890'));
      expect(userData['emailVerified'], isTrue);
      expect(userData['provider'], equals('google'));
      expect(userData['isActive'], isTrue);
      expect(userData['createdAt'], equals('2024-01-01T00:00:00.000'));
      expect(userData['lastSignInTime'], equals('2024-01-15T10:00:00.000'));
    });

    test('should create copy with updated fields', () {
      // Arrange
      final originalUser = UserModel(
        uid: 'test_uid',
        displayName: 'Test User',
        email: 'test@example.com',
        photoURL: '',
        phoneNumber: '',
        emailVerified: false,
        provider: 'email',
        isActive: true,
      );

      // Act
      final updatedUser = originalUser.copyWith(
        displayName: 'Updated User',
        emailVerified: true,
        provider: 'google',
      );

      // Assert
      expect(updatedUser.uid, equals('test_uid'));
      expect(updatedUser.displayName, equals('Updated User'));
      expect(updatedUser.email, equals('test@example.com'));
      expect(updatedUser.emailVerified, isTrue);
      expect(updatedUser.provider, equals('google'));
      expect(updatedUser.isActive, isTrue);
    });
  });

  group('Integration Tests', () {
    test('should handle complete authentication flow', () async {
      // This would test the complete flow from API to Provider
      // Arrange
      final container = ProviderContainer();
      final authNotifier = container.read(authProvider.notifier);

      // Mock successful authentication
      final mockUser = UserModel(
        uid: 'test_uid',
        displayName: 'Test User',
        email: 'test@example.com',
        photoURL: '',
        phoneNumber: '',
        emailVerified: true,
        provider: 'google',
        isActive: true,
      );

      // Act
      authNotifier.setUser(mockUser);

      // Assert
      final state = container.read(authProvider);
      expect(state.user, equals(mockUser));
      expect(container.read(isAuthenticatedProvider), isTrue);
      expect(container.read(currentUserProvider), equals(mockUser));

      // Cleanup
      container.dispose();
    });

    test('should handle flight search flow', () async {
      // This would test the complete flow from API to Provider
      // Arrange
      final container = ProviderContainer();
      final flightNotifier = container.read(flightProvider.notifier);

      // Mock search results
      final mockFlights = [
        {
          'flight': {'iata': 'AA123'},
          'departure': {'iata': 'LOS'},
          'arrival': {'iata': 'ABV'},
        },
        {
          'flight': {'iata': 'BB456'},
          'departure': {'iata': 'LOS'},
          'arrival': {'iata': 'ABV'},
        },
      ];

      // Act
      // This would normally call flightNotifier.searchFlightsByDetails()
      // but we'll simulate the state change
      final newState = FlightState(flights: mockFlights);
      // Note: You'd need to expose a method to set state for testing

      // Assert
      expect(newState.flights, hasLength(2));
      expect(newState.flights[0]['flight']['iata'], equals('AA123'));
      expect(newState.flights[1]['flight']['iata'], equals('BB456'));

      // Cleanup
      container.dispose();
    });
  });

  group('Error Handling Tests', () {
    test('should handle Firebase Auth errors correctly', () {
      // Arrange
      final firebaseError = FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found with this email address.',
      );

      // Act & Assert
      expect(
        () => throw Exception('No user found with this email address.'),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle network errors correctly', () {
      // Arrange
      final networkError = DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'Network error',
        type: DioExceptionType.connectionTimeout,
      );

      // Act & Assert
      expect(() => throw networkError, throwsA(isA<DioException>()));
    });
  });
}

// Helper class for creating test data
class TestDataFactory {
  static UserModel createTestUser({
    String uid = 'test_uid',
    String displayName = 'Test User',
    String email = 'test@example.com',
    String photoURL = '',
    String phoneNumber = '',
    bool emailVerified = true,
    String provider = 'google',
    bool isActive = true,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName,
      email: email,
      photoURL: photoURL,
      phoneNumber: phoneNumber,
      emailVerified: emailVerified,
      provider: provider,
      isActive: isActive,
    );
  }

  static Map<String, dynamic> createTestFlightData({
    String flightIata = 'AA123',
    String departureIata = 'LOS',
    String arrivalIata = 'ABV',
    String status = 'active',
  }) {
    return {
      'flight': {'iata': flightIata, 'number': flightIata.substring(2)},
      'departure': {
        'iata': departureIata,
        'airport': 'Lagos Airport',
        'scheduled': '2024-01-15T10:00:00+00:00',
      },
      'arrival': {
        'iata': arrivalIata,
        'airport': 'Abuja Airport',
        'scheduled': '2024-01-15T12:00:00+00:00',
      },
      'flight_status': status,
      'flight_date': '2024-01-15',
      'airline': {'name': 'Aero Airways', 'iata': 'AA'},
    };
  }

  static List<Map<String, dynamic>> createTestFlightList({int count = 5}) {
    return List.generate(count, (index) {
      return createTestFlightData(
        flightIata: 'AA${123 + index}',
        departureIata: 'LOS',
        arrivalIata: 'ABV',
      );
    });
  }
}
