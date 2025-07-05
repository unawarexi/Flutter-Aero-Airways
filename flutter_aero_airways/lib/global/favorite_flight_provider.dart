import 'package:flutter_aero_airways/features/flight_management/domain/hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';


class FavoriteFlightsState {
  final List<FavoriteFlight> favoriteFlights;
  final bool isLoading;
  final String? error;

  FavoriteFlightsState({
    this.favoriteFlights = const [],
    this.isLoading = false,
    this.error,
  });

  FavoriteFlightsState copyWith({
    List<FavoriteFlight>? favoriteFlights,
    bool? isLoading,
    String? error,
  }) {
    return FavoriteFlightsState(
      favoriteFlights: favoriteFlights ?? this.favoriteFlights,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FavoriteFlightsNotifier extends StateNotifier<FavoriteFlightsState> {
  static const String _boxName = 'favorite_flights';
  Box<FavoriteFlight>? _box;

  FavoriteFlightsNotifier() : super(FavoriteFlightsState()) {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      _box = await Hive.openBox<FavoriteFlight>(_boxName);
      _loadFavoriteFlights();
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize storage: $e');
    }
  }

  void _loadFavoriteFlights() {
    if (_box != null) {
      final favoriteFlights = _box!.values.toList();
      // Sort by saved date (newest first)
      favoriteFlights.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      state = state.copyWith(favoriteFlights: favoriteFlights);
    }
  }

  Future<void> addFavoriteFlight(Map<String, dynamic> flightData) async {
    if (_box == null) {
      state = state.copyWith(error: 'Storage not initialized');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final favoriteFlight = FavoriteFlight.fromFlightData(flightData);

      // Check if flight already exists
      final existingFlight = _box!.values.firstWhere(
        (flight) => flight.id == favoriteFlight.id,
        orElse: () => FavoriteFlight(
          id: '',
          airline: '',
          flightNumber: '',
          departureAirport: '',
          arrivalAirport: '',
          departureTime: '',
          arrivalTime: '',
          status: '',
          savedAt: DateTime.now(),
          rawData: {}, flightDate: '', departureIata: '', arrivalIata: '',
        ),
      );

      if (existingFlight.id.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Flight already in favorites',
        );
        return;
      }

      await _box!.add(favoriteFlight);
      _loadFavoriteFlights();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add favorite flight: $e',
      );
    }
  }

  Future<void> removeFavoriteFlight(String flightId) async {
    if (_box == null) {
      state = state.copyWith(error: 'Storage not initialized');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final flightToRemove = _box!.values.firstWhere(
        (flight) => flight.id == flightId,
        orElse: () => FavoriteFlight(
          id: '',
          airline: '',
          flightNumber: '',
          departureAirport: '',
          arrivalAirport: '',
          departureTime: '',
          arrivalTime: '',
          status: '',
          savedAt: DateTime.now(),
          rawData: {}, flightDate: '', departureIata: '', arrivalIata: '',
        ),
      );

      if (flightToRemove.id.isNotEmpty) {
        await flightToRemove.delete();
        _loadFavoriteFlights();
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to remove favorite flight: $e',
      );
    }
  }

  bool isFlightFavorite(String flightId) {
    return state.favoriteFlights.any((flight) => flight.id == flightId);
  }

  Future<void> clearAllFavorites() async {
    if (_box == null) return;

    try {
      await _box!.clear();
      state = state.copyWith(favoriteFlights: []);
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear favorites: $e');
    }
  }
}

final favoriteFlightsProvider =
    StateNotifierProvider<FavoriteFlightsNotifier, FavoriteFlightsState>(
      (ref) => FavoriteFlightsNotifier(),
    );
