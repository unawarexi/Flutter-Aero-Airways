import 'package:hive/hive.dart';

part 'hive_model.g.dart';

@HiveType(typeId: 0)
class FavoriteFlight extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String airline;

  @HiveField(2)
  String flightNumber;

  @HiveField(3)
  String departureAirport;

  @HiveField(4)
  String arrivalAirport;

  @HiveField(5)
  String departureTime;

  @HiveField(6)
  String arrivalTime;

  @HiveField(7)
  String status;

  @HiveField(8)
  DateTime savedAt;

  @HiveField(9)
  String flightDate;

  @HiveField(10)
  String departureIata;

  @HiveField(11)
  String arrivalIata;

  @HiveField(12)
  String? departureTerminal;

  @HiveField(13)
  String? departureGate;

  @HiveField(14)
  String? arrivalTerminal;

  @HiveField(15)
  String? arrivalGate;

  @HiveField(16)
  int? departureDelay;

  @HiveField(17)
  int? arrivalDelay;

  @HiveField(18)
  Map<String, dynamic> rawData;

  FavoriteFlight({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.status,
    required this.savedAt,
    required this.flightDate,
    required this.departureIata,
    required this.arrivalIata,
    this.departureTerminal,
    this.departureGate,
    this.arrivalTerminal,
    this.arrivalGate,
    this.departureDelay,
    this.arrivalDelay,
    required this.rawData,
  });

  factory FavoriteFlight.fromFlightData(Map<String, dynamic> flightData) {
    final departure = flightData['departure'] ?? {};
    final arrival = flightData['arrival'] ?? {};
    final airline = flightData['airline'] ?? {};
    final flight = flightData['flight'] ?? {};

    // Create a unique ID for the flight
    final flightId =
        '${flight['iata'] ?? ''}_${flightData['flight_date'] ?? ''}';

    return FavoriteFlight(
      id: flightId,
      airline: airline['name'] ?? '',
      flightNumber: flight['iata'] ?? '',
      departureAirport: departure['airport'] ?? '',
      arrivalAirport: arrival['airport'] ?? '',
      departureTime: departure['scheduled'] ?? '',
      arrivalTime: arrival['scheduled'] ?? '',
      status: flightData['flight_status'] ?? '',
      savedAt: DateTime.now(),
      flightDate: flightData['flight_date'] ?? '',
      departureIata: departure['iata'] ?? '',
      arrivalIata: arrival['iata'] ?? '',
      departureTerminal: departure['terminal'],
      departureGate: departure['gate'],
      arrivalTerminal: arrival['terminal'],
      arrivalGate: arrival['gate'],
      departureDelay: departure['delay'],
      arrivalDelay: arrival['delay'],
      rawData: flightData,
    );
  }

  // Helper method to format departure time
  String get formattedDepartureTime {
    if (departureTime.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(departureTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return departureTime;
    }
  }

  // Helper method to format arrival time
  String get formattedArrivalTime {
    if (arrivalTime.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(arrivalTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return arrivalTime;
    }
  }

  // Helper method to get delay status
  String get delayStatus {
    if (departureDelay != null && departureDelay! > 0) {
      return 'Delayed ${departureDelay}min';
    }
    return 'On Time';
  }

  @override
  String toString() {
    return 'FavoriteFlight(id: $id, airline: $airline, flightNumber: $flightNumber, '
        'from: $departureAirport to: $arrivalAirport, status: $status)';
  }
}
