import 'package:dio/dio.dart';
import 'package:flutter_aero_airways/core/config/environment.dart';

class FlightApi {
  final Dio _dio;
  FlightApi({Dio? dio}) : _dio = dio ?? Dio();

  String get _baseUrl => Environment
      .baseUrl; // Should be like https://api.aviationstack.com/v1/flights
  String get _apiKey => Environment.apiKey;

  Future<Map<String, dynamic>> fetchAllFlights({
    int limit = 5,
    int offset = 0,
  }) async {
    final url = _baseUrl;
    final params = {'access_key': _apiKey, 'limit': limit, 'offset': offset};
    print('[FlightApi] fetchAllFlights - URL: $url');
    print('[FlightApi] fetchAllFlights - Params: $params');
    final response = await _dio.get(url, queryParameters: params);
    print('[FlightApi] fetchAllFlights - Response: ${response.data}');
    return response.data;
  }

  Future<Map<String, dynamic>> fetchFlightById(String flightIata) async {
    final url = _baseUrl;
    final params = {'access_key': _apiKey, 'flight_iata': flightIata};
    print('[FlightApi] fetchFlightById - URL: $url');
    print('[FlightApi] fetchFlightById - Params: $params');
    final response = await _dio.get(url, queryParameters: params);
    print('[FlightApi] fetchFlightById - Response: ${response.data}');
    return response.data;
  }

  Future<Map<String, dynamic>> searchFlights(
    Map<String, dynamic> searchParams,
  ) async {
    final url = _baseUrl;
    final params = {
      'access_key': _apiKey,
      'limit': 5,
      ...searchParams,
    }; // Added limit: 5
    print('[FlightApi] searchFlights - URL: $url');
    print('[FlightApi] searchFlights - Params: $params');
    final response = await _dio.get(url, queryParameters: params);
    print('[FlightApi] searchFlights - Response: ${response.data}');
    return response.data;
  }

  // Helper: Map city name to IATA code
  static const Map<String, String> cityToIata = {
    'Lagos': 'LOS',
    'Abuja': 'ABV',
    'Kano': 'KAN',
    'Port Harcourt': 'PHC',
    'Ibadan': 'IBA',
    'Kaduna': 'KAD',
    'Enugu': 'ENU',
    'Calabar': 'CBQ',
  };

  // Search flights by from and to cities only (no date filter)
  Future<Map<String, dynamic>> searchFlightsByLocation({
    required String fromCity,
    required String toCity,
  }) async {
    final url = _baseUrl;
    final params = {
      'access_key': _apiKey,
      'dep_iata': fromCity,
      'arr_iata': toCity,
      'limit': 5, // Added limit: 5
    };
    print('[FlightApi] searchFlightsByLocation - URL: $url');
    print('[FlightApi] searchFlightsByLocation - Params: $params');
    final response = await _dio.get(url, queryParameters: params);
    print('[FlightApi] searchFlightsByLocation - Response: ${response.data}');
    return response.data;
  }

  // Search flights by departure date only (no location filter)
  Future<Map<String, dynamic>> searchFlightsByDate({
    required DateTime departureDate,
  }) async {
    final url = _baseUrl;
    final params = {
      'access_key': _apiKey,
      'flight_date': departureDate.toIso8601String().split('T').first,
      'limit': 5, // Added limit: 5
    };
    print('[FlightApi] searchFlightsByDate - URL: $url');
    print('[FlightApi] searchFlightsByDate - Params: $params');
    final response = await _dio.get(url, queryParameters: params);
    print('[FlightApi] searchFlightsByDate - Response: ${response.data}');
    return response.data;
  }

  // Updated method that tries location-based search first, then falls back to date-based search
  Future<Map<String, dynamic>> searchFlightsByDetails({
    required String fromCity,
    required String toCity,
    required DateTime departureDate,
  }) async {
    try {
      print('[FlightApi] Attempting location-based search first...');
      // Try searching by location first
      final locationResults = await searchFlightsByLocation(
        fromCity: fromCity,
        toCity: toCity,
      );

      // If we get results, return them
      if (locationResults['data'] != null &&
          locationResults['data'].isNotEmpty) {
        print('[FlightApi] Location-based search successful');
        return locationResults;
      }

      print(
        '[FlightApi] Location-based search returned no results, trying date-based search...',
      );
      // If no results from location search, try date-based search
      final dateResults = await searchFlightsByDate(
        departureDate: departureDate,
      );

      print('[FlightApi] Date-based search completed');
      return dateResults;
    } catch (e) {
      print('[FlightApi] Location-based search failed: $e');
      print('[FlightApi] Falling back to date-based search...');

      try {
        // If location search fails, try date-based search
        final dateResults = await searchFlightsByDate(
          departureDate: departureDate,
        );

        print('[FlightApi] Date-based search completed');
        return dateResults;
      } catch (dateError) {
        print('[FlightApi] Date-based search also failed: $dateError');
        // If both fail, try a basic search with no filters
        return await fetchAllFlights(limit: 5); // Changed from 50 to 5
      }
    }
  }
}
