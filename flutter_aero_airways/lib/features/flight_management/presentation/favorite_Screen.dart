import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/global/favorite_flight_provider.dart';
import 'package:flutter_aero_airways/global/hive_global_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_aero_airways/features/flight_management/domain/hive_model.dart';
import 'package:flutter_aero_airways/core/utils/helpers/helper_functions.dart';
import 'package:intl/intl.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    final favoriteFlightsState = ref.watch(favoriteFlightsProvider);
    final favoriteFlightsNotifier = ref.read(favoriteFlightsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Flights',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode
            ? Colors.grey.shade900
            : Colors.grey.shade50,
        foregroundColor: isDarkMode ? Colors.lime : Colors.green.shade600,
        elevation: 0,
        actions: [
          if (favoriteFlightsState.favoriteFlights.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () =>
                  _showClearAllDialog(context, favoriteFlightsNotifier),
              tooltip: 'Clear All Favorites',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Colors.grey.shade900,
                    Colors.grey.shade800,
                    Colors.grey.shade900,
                  ]
                : [Colors.grey.shade50, Colors.white, Colors.grey.shade50],
          ),
        ),
        child: favoriteFlightsState.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? Colors.lime : Colors.green.shade600,
                  ),
                ),
              )
            : favoriteFlightsState.error != null
            ? _buildErrorWidget(favoriteFlightsState.error!, isDarkMode)
            : favoriteFlightsState.favoriteFlights.isEmpty
            ? _buildEmptyState(isDarkMode)
            : _buildFlightsList(
                favoriteFlightsState.favoriteFlights,
                favoriteFlightsNotifier,
                isDarkMode,
              ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorite Flights',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding flights to your favorites\nto see them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: isDarkMode ? Colors.red.shade400 : Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.red.shade400 : Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.red.shade300 : Colors.red.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightsList(
    List<FavoriteFlight> flights,
    FavoriteFlightsNotifier notifier,
    bool isDarkMode,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final flight = flights[index];
        return _buildFlightCard(flight, notifier, isDarkMode);
      },
    );
  }

  Widget _buildFlightCard(
    FavoriteFlight flight,
    FavoriteFlightsNotifier notifier,
    bool isDarkMode,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with airline and flight number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.airline,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        flight.flightNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStatusChip(flight.status, isDarkMode),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: isDarkMode ? Colors.red.shade400 : Colors.red,
                        ),
                        onPressed: () => _showRemoveDialog(flight, notifier),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Flight route
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.departureIata,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          flight.departureAirport,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          flight.departureTime,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.flight_takeoff,
                        color: isDarkMode ? Colors.lime : Colors.green.shade600,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 60,
                        height: 2,
                        color: isDarkMode ? Colors.lime : Colors.green.shade600,
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.flight_land,
                        color: isDarkMode ? Colors.lime : Colors.green.shade600,
                        size: 24,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          flight.arrivalIata,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          flight.arrivalAirport,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          flight.arrivalTime,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Flight date and saved date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isDarkMode ? Colors.lime : Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Flight Date: ${flight.flightDate}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.lime
                              : Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        size: 16,
                        color: isDarkMode ? Colors.lime : Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Saved: ${DateFormat('MMM dd, yyyy').format(flight.savedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.lime
                              : Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDarkMode) {
    Color chipColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'on time':
      case 'scheduled':
        chipColor = isDarkMode ? Colors.green.shade800 : Colors.green.shade100;
        textColor = isDarkMode ? Colors.green.shade300 : Colors.green.shade800;
        break;
      case 'delayed':
        chipColor = isDarkMode
            ? Colors.orange.shade800
            : Colors.orange.shade100;
        textColor = isDarkMode
            ? Colors.orange.shade300
            : Colors.orange.shade800;
        break;
      case 'cancelled':
        chipColor = isDarkMode ? Colors.red.shade800 : Colors.red.shade100;
        textColor = isDarkMode ? Colors.red.shade300 : Colors.red.shade800;
        break;
      case 'boarding':
        chipColor = isDarkMode ? Colors.blue.shade800 : Colors.blue.shade100;
        textColor = isDarkMode ? Colors.blue.shade300 : Colors.blue.shade800;
        break;
      default:
        chipColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
        textColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _showRemoveDialog(
    FavoriteFlight flight,
    FavoriteFlightsNotifier notifier,
  ) {
    // Use the global context safely
    final context = GlobalKeys.navigatorKey.currentContext;
    if (context == null) return;

    final isDarkMode = THelperFunctions.isDarkMode(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        title: Text(
          'Remove Favorite',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to remove ${flight.airline} ${flight.flightNumber} from your favorites?',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              notifier.removeFavoriteFlight(flight.id);
              Navigator.of(dialogContext).pop();

              // Use GlobalUtils for cleaner global messaging
              GlobalUtils.showSnackBar(
                'Flight removed from favorites',
                backgroundColor: isDarkMode
                    ? Colors.lime
                    : Colors.green.shade600,
              );
            },
            child: Text(
              'Remove',
              style: TextStyle(
                color: isDarkMode ? Colors.red.shade400 : Colors.red.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    FavoriteFlightsNotifier notifier,
  ) {
    final isDarkMode = THelperFunctions.isDarkMode(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        title: Text(
          'Clear All Favorites',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to remove all flights from your favorites? This action cannot be undone.',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              notifier.clearAllFavorites();
              Navigator.of(dialogContext).pop();

              // Use context-based SnackBar since we have access to it
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All favorites cleared'),
                  backgroundColor: isDarkMode
                      ? Colors.lime
                      : Colors.green.shade600,
                ),
              );
            },
            child: Text(
              'Clear All',
              style: TextStyle(
                color: isDarkMode ? Colors.red.shade400 : Colors.red.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
