import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/common/widgets/toast_alerts.dart';
import 'package:flutter_aero_airways/global/favorite_flight_provider.dart';
import 'package:flutter_aero_airways/global/flight_provider.dart';
import 'package:flutter_aero_airways/core/utils/helpers/helper_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class SearchResultScreen extends ConsumerStatefulWidget {
  final String fromCity;
  final String toCity;
  final DateTime departureDate;

  const SearchResultScreen({
    super.key,
    required this.fromCity,
    required this.toCity,
    required this.departureDate,
  });

  @override
  ConsumerState<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends ConsumerState<SearchResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Search for flights
    Future.microtask(() {
      ref.read(flightProvider.notifier).searchFlightsByDetails(
            fromCity: widget.fromCity,
            toCity: widget.toCity,
            departureDate: widget.departureDate,
          );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(timeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString;
    }
  }

  String _getDelayStatus(Map<String, dynamic> departure) {
    final delay = departure['delay'];
    if (delay != null && delay > 0) {
      return 'Delayed ${delay}min';
    }
    return 'On Time';
  }

  void _toggleFavorite(Map<String, dynamic> flight) async {
    final favoriteNotifier = ref.read(favoriteFlightsProvider.notifier);
    final flightId = '${flight['flight']?['iata'] ?? ''}_${flight['flight_date'] ?? ''}';
    final isFavorite = favoriteNotifier.isFlightFavorite(flightId);

    if (isFavorite) {
      await favoriteNotifier.removeFavoriteFlight(flightId);
      if (mounted) {
        context.showToast('Flight removed from favorites', type: ToastType.success);
      }
    } else {
      await favoriteNotifier.addFavoriteFlight(flight);
      if (mounted) {
        final error = ref.read(favoriteFlightsProvider).error;
        if (error != null) {
          context.showToast(error, type: ToastType.error);
        } else {
          context.showToast('Flight added to favorites', type: ToastType.success);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    final flightState = ref.watch(flightProvider);
    final favoriteState = ref.watch(favoriteFlightsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF000000),
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
              // Custom App Bar
              _buildCustomAppBar(isDarkMode),
              
              // Search Summary Card
              _buildSearchSummaryCard(isDarkMode, flightState.flights.length),
              
              // Content based on state
              Expanded(
                child: _buildContent(isDarkMode, flightState, favoriteState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade900.withOpacity(0.7) : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Iconsax.arrow_left,
                  color: isDarkMode ? Colors.lime : Colors.green.shade700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Flight Results',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.lime : Colors.green.shade800,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade900.withOpacity(0.7) : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pushNamed(context, '/favorites'),
                icon: Icon(
                  Iconsax.heart,
                  color: isDarkMode ? Colors.lime : Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSummaryCard(bool isDarkMode, int flightCount) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900.withOpacity(0.8) : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.lime.withOpacity(0.2) : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Iconsax.airplane,
                      color: isDarkMode ? Colors.lime : Colors.green.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.fromCity} → ${widget.toCity}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          'Departure: ${widget.departureDate.day}/${widget.departureDate.month}/${widget.departureDate.year}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.lime.withOpacity(0.2) : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$flightCount flights found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.lime : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode, flightState, favoriteState) {
    if (flightState.isLoading) {
      return _buildLoadingState(isDarkMode);
    }

    if (flightState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showToast(flightState.error!, type: ToastType.error);
      });
      return _buildErrorState(isDarkMode, flightState.error!);
    }

    if (flightState.flights.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return _buildFlightList(isDarkMode, flightState, favoriteState);
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade900.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? Colors.lime : Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Searching for flights...',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode, String error) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900.withOpacity(0.8) : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Iconsax.warning_2,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref.read(flightProvider.notifier).searchFlightsByDetails(
                        fromCity: widget.fromCity,
                        toCity: widget.toCity,
                        departureDate: widget.departureDate,
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.lime : Colors.green.shade600,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900.withOpacity(0.8) : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.lime.withOpacity(0.2) : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Iconsax.airplane,
                  size: 48,
                  color: isDarkMode ? Colors.lime : Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No flights found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search criteria\nto find more flight options',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightList(bool isDarkMode, flightState, favoriteState) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: flightState.flights.length,
          itemBuilder: (context, index) {
            final flight = flightState.flights[index];
            return _buildFlightCard(isDarkMode, flight, favoriteState, index);
          },
        ),
      ),
    );
  }

  Widget _buildFlightCard(bool isDarkMode, Map<String, dynamic> flight, favoriteState, int index) {
    final airline = flight['airline']?['name'] ?? 'Unknown Airline';
    final flightNum = flight['flight']?['iata'] ?? '';
    final departure = flight['departure'] ?? {};
    final arrival = flight['arrival'] ?? {};
    final depTime = departure['scheduled'] ?? '';
    final arrTime = arrival['scheduled'] ?? '';
    final status = flight['flight_status'] ?? 'Unknown';
    final flightDate = flight['flight_date'] ?? '';

    final flightId = '${flightNum}_$flightDate';
    final isFavorite = favoriteState.favoriteFlights.any((f) => f.id == flightId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900.withOpacity(0.8) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showDialog(
            context: context,
            builder: (context) => _FlightDetailsDialog(flight: flight, isDarkMode: isDarkMode),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Airline and Favorite
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.lime.withOpacity(0.2) : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Iconsax.airplane,
                              color: isDarkMode ? Colors.lime : Colors.green.shade600,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  airline,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  flightNum,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isFavorite 
                            ? Colors.red.withOpacity(0.1)
                            : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: favoriteState.isLoading ? null : () => _toggleFavorite(flight),
                        icon: Icon(
                          isFavorite ? Iconsax.heart5 : Iconsax.heart,
                          color: isFavorite ? Colors.red : (isDarkMode ? Colors.white54 : Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Flight Route
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            departure['iata'] ?? '',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.lime : Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(depTime),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.grey.shade800,
                            ),
                          ),
                          if (departure['gate'] != null)
                            Text(
                              'Gate: ${departure['gate']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.lime.withOpacity(0.2) : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.lime : Colors.green.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.lime : Colors.green.shade600,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          Icon(
                            Iconsax.airplane,
                            size: 16,
                            color: isDarkMode ? Colors.lime : Colors.green.shade600,
                          ),
                          Container(
                            width: 40,
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.lime : Colors.green.shade600,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.lime : Colors.green.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            arrival['iata'] ?? '',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.lime : Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(arrTime),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.grey.shade800,
                            ),
                          ),
                          if (arrival['gate'] != null)
                            Text(
                              'Gate: ${arrival['gate']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Status and Delay
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status == 'active'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: status == 'active' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: departure['delay'] != null && departure['delay'] > 0
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getDelayStatus(departure),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: departure['delay'] != null && departure['delay'] > 0
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlightDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> flight;
  final bool isDarkMode;

  const _FlightDetailsDialog({required this.flight, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final airline = flight['airline'] ?? {};
    final flightInfo = flight['flight'] ?? {};
    final departure = flight['departure'] ?? {};
    final arrival = flight['arrival'] ?? {};
    final aircraft = flight['aircraft'] ?? {};

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Flight Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.lime : Colors.green.shade700,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Iconsax.close_circle,
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Airline', airline['name']),
            _buildDetailRow('Flight Number', flightInfo['iata']),
            _buildDetailRow('Date', flight['flight_date']),
            _buildDetailRow('Status', flight['flight_status']),
            const SizedBox(height: 16),
            Text(
              'Departure',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.lime : Colors.green.shade700,
              ),
            ),
          const SizedBox(height: 8),
            _buildDetailRow('Airport', departure['airport']),
            _buildDetailRow('Terminal', departure['terminal']),
            _buildDetailRow('Gate', departure['gate']),
            _buildDetailRow('Scheduled', departure['scheduled']),
            const SizedBox(height: 16),
            const Text(
              'Arrival',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildDetailRow('Airport', arrival['airport']),
            _buildDetailRow('Terminal', arrival['terminal']),
            _buildDetailRow('Gate', arrival['gate']),
            _buildDetailRow('Scheduled', arrival['scheduled']),
            if (aircraft.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Aircraft',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildDetailRow('Model', aircraft['iata']),
              _buildDetailRow('Registration', aircraft['registration']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }
}
