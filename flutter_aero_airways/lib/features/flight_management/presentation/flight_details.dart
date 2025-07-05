import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../global/flight_provider.dart';

class FlightDetailsScreen extends ConsumerStatefulWidget {
  final String flightIata;
  const FlightDetailsScreen({super.key, required this.flightIata});

  @override
  ConsumerState<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends ConsumerState<FlightDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(flightProvider.notifier).fetchFlightById(widget.flightIata);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flightProvider);
    // The API returns a list under 'data', so selectedFlight should be a List and we take the first item
    final flight = state.selectedFlight is List
        ? (state.selectedFlight as List).isNotEmpty
            ? (state.selectedFlight as List).first
            : null
        : state.selectedFlight;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color cardBg = isDarkMode ? const Color(0xFF232323) : Colors.white;
    Color accent = isDarkMode ? Colors.lime : Colors.green.shade600;
    Color textPrimary = isDarkMode ? Colors.lime : Colors.green.shade800;
    Color textSecondary = isDarkMode ? Colors.white70 : Colors.grey.shade700;

    return Scaffold(
      // --- Gradient background to match HomeScreen ---
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF112712),
                    const Color(0xFF181818),
                    const Color(0xFF000000),
                  ]
                : [
                    const Color(0xFFFFFDE7),
                    const Color(0xFFF9FBE7),
                    const Color(0xFFE8F5E8),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- AppBar with matching theme ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: accent),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Flight Details',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.error != null
                        ? Center(child: Text('Error: ${state.error}', style: TextStyle(color: accent)))
                        : flight == null
                            ? Center(child: Text('No flight details found.', style: TextStyle(color: accent)))
                            : ListView(
                                padding: const EdgeInsets.all(20),
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDarkMode
                                              ? Colors.black.withOpacity(0.18)
                                              : Colors.green.withOpacity(0.08),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: accent.withOpacity(0.18),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.flight, color: accent, size: 28),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                '${flight['airline']?['name'] ?? ''} (${flight['flight']?['iata'] ?? ''})',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                  color: textPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text('Flight Date: ${flight['flight_date'] ?? ''}', style: TextStyle(color: textSecondary)),
                                        Text('Status: ${flight['flight_status'] ?? ''}', style: TextStyle(color: accent)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _sectionCard(
                                    context,
                                    title: 'Departure',
                                    accent: accent,
                                    cardBg: cardBg,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    children: [
                                      _infoRow('Airport', flight['departure']?['airport']),
                                      _infoRow('Timezone', flight['departure']?['timezone']),
                                      _infoRow('IATA', flight['departure']?['iata']),
                                      _infoRow('ICAO', flight['departure']?['icao']),
                                      _infoRow('Scheduled', flight['departure']?['scheduled']),
                                      _infoRow('Estimated', flight['departure']?['estimated']),
                                      _infoRow('Actual', flight['departure']?['actual']),
                                      _infoRow('Terminal', flight['departure']?['terminal']),
                                      _infoRow('Gate', flight['departure']?['gate']),
                                      _infoRow('Delay', flight['departure']?['delay']),
                                      _infoRow('Estimated Runway', flight['departure']?['estimated_runway']),
                                      _infoRow('Actual Runway', flight['departure']?['actual_runway']),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _sectionCard(
                                    context,
                                    title: 'Arrival',
                                    accent: accent,
                                    cardBg: cardBg,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    children: [
                                      _infoRow('Airport', flight['arrival']?['airport']),
                                      _infoRow('Timezone', flight['arrival']?['timezone']),
                                      _infoRow('IATA', flight['arrival']?['iata']),
                                      _infoRow('ICAO', flight['arrival']?['icao']),
                                      _infoRow('Scheduled', flight['arrival']?['scheduled']),
                                      _infoRow('Estimated', flight['arrival']?['estimated']),
                                      _infoRow('Actual', flight['arrival']?['actual']),
                                      _infoRow('Terminal', flight['arrival']?['terminal']),
                                      _infoRow('Gate', flight['arrival']?['gate']),
                                      _infoRow('Baggage', flight['arrival']?['baggage']),
                                      _infoRow('Delay', flight['arrival']?['delay']),
                                      _infoRow('Estimated Runway', flight['arrival']?['estimated_runway']),
                                      _infoRow('Actual Runway', flight['arrival']?['actual_runway']),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _sectionCard(
                                    context,
                                    title: 'Flight Info',
                                    accent: accent,
                                    cardBg: cardBg,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    children: [
                                      _infoRow('Flight Number', flight['flight']?['number']),
                                      _infoRow('IATA', flight['flight']?['iata']),
                                      _infoRow('ICAO', flight['flight']?['icao']),
                                      _infoRow('Codeshared', flight['flight']?['codeshared']),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _sectionCard(
                                    context,
                                    title: 'Airline',
                                    accent: accent,
                                    cardBg: cardBg,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    children: [
                                      _infoRow('Name', flight['airline']?['name']),
                                      _infoRow('IATA', flight['airline']?['iata']),
                                      _infoRow('ICAO', flight['airline']?['icao']),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _sectionCard(
                                    context,
                                    title: 'Aircraft',
                                    accent: accent,
                                    cardBg: cardBg,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    children: [
                                      _infoRow('Registration', flight['aircraft']?['registration']),
                                      _infoRow('Type', flight['aircraft']?['iata']),
                                      _infoRow('ICAO', flight['aircraft']?['icao']),
                                      _infoRow('ICAO24', flight['aircraft']?['icao24']),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _sectionCard(
                                    context,
                                    title: 'Live Data',
                                    accent: accent,
                                    cardBg: cardBg,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    children: [
                                      _infoRow('Updated', flight['live']?['updated']),
                                      _infoRow('Latitude', flight['live']?['latitude']),
                                      _infoRow('Longitude', flight['live']?['longitude']),
                                      _infoRow('Altitude', flight['live']?['altitude']),
                                      _infoRow('Direction', flight['live']?['direction']),
                                      _infoRow('Speed Horizontal', flight['live']?['speed_horizontal']),
                                      _infoRow('Speed Vertical', flight['live']?['speed_vertical']),
                                      _infoRow('Is Ground', flight['live']?['is_ground']),
                                    ],
                                  ),
                                ],
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Color accent,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: accent.withOpacity(0.13),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '',
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
