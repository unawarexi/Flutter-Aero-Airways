import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/flight_management/data/flight_api.dart';


class FlightState {
  final List<dynamic> flights;
  final Map<String, dynamic>? selectedFlight;
  final bool isLoading;
  final String? error;

  FlightState({
    this.flights = const [],
    this.selectedFlight,
    this.isLoading = false,
    this.error,
  });

  FlightState copyWith({
    List<dynamic>? flights,
    Map<String, dynamic>? selectedFlight,
    bool? isLoading,
    String? error,
  }) {
    return FlightState(
      flights: flights ?? this.flights,
      selectedFlight: selectedFlight ?? this.selectedFlight,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FlightNotifier extends StateNotifier<FlightState> {
  final FlightApi _flightApi = FlightApi();

  FlightNotifier() : super(FlightState());

  Future<void> fetchAllFlights({int limit = 100, int offset = 0}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _flightApi.fetchAllFlights(limit: limit, offset: offset);
      state = state.copyWith(flights: data['data'] ?? [], isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> fetchFlightById(String flightIata) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _flightApi.fetchFlightById(flightIata);
      state = state.copyWith(
        selectedFlight: (data['data'] as List?)?.first,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> searchFlights(Map<String, dynamic> searchParams) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _flightApi.searchFlights(searchParams);
      state = state.copyWith(flights: data['data'] ?? [], isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> searchFlightsByDetails({
    required String fromCity,
    required String toCity,
    required DateTime departureDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _flightApi.searchFlightsByDetails(
        fromCity: fromCity,
        toCity: toCity,
        departureDate: departureDate,
      );
      state = state.copyWith(flights: data['data'] ?? [], isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final flightProvider = StateNotifierProvider<FlightNotifier, FlightState>(
  (ref) => FlightNotifier(),
);
