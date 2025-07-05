import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../global/flight_provider.dart';
import '../features/flight_management/presentation/flight_details.dart';

class FlightScreen extends ConsumerStatefulWidget {
  const FlightScreen({super.key});

  @override
  ConsumerState<FlightScreen> createState() => _FlightScreenState();
}

class _FlightScreenState extends ConsumerState<FlightScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(flightProvider.notifier).fetchAllFlights(limit: 5);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    if (_searchController.text.trim().isEmpty) {
      // If search is empty, fetch all flights
      ref.read(flightProvider.notifier).fetchAllFlights(limit: 1);
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Create search parameters based on the search input
      // You can customize this logic based on your needs
      final searchParams = {
        'flight_iata': _searchController.text.trim(),
        'limit': 1,
      };

      await ref.read(flightProvider.notifier).searchFlights(searchParams);
    } catch (e) {
      // Handle search error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flightProvider);
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: accent),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Flights',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Search Input Field ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.25)
                            : Colors.green.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: accent.withOpacity(0.18),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search flights (e.g., AA1234)',
                            hintStyle: TextStyle(color: textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: accent,
                              size: 20,
                            ),
                          ),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          onPressed: _isSearching ? null : _performSearch,
                          icon: _isSearching
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      accent,
                                    ),
                                  ),
                                )
                              : Icon(Icons.search, color: accent, size: 24),
                          style: IconButton.styleFrom(
                            backgroundColor: accent.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.error != null) {
                      return Center(
                        child: Text(
                          'Error: ${state.error}',
                          style: TextStyle(color: accent),
                        ),
                      );
                    }
                    if (state.flights.isEmpty) {
                      return Center(
                        child: Text(
                          'No flights found.',
                          style: TextStyle(color: accent),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        itemCount: state.flights.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 18,
                              crossAxisSpacing: 18,
                              childAspectRatio: 0.95,
                            ),
                        itemBuilder: (context, index) {
                          final flight = state.flights[index];
                          final airline =
                              flight['airline']?['name'] ?? 'Unknown';
                          final aircraft = flight['aircraft']?['iata'] ?? 'N/A';
                          final flightNum = flight['flight']?['iata'] ?? '';
                          final dep = flight['departure']?['airport'] ?? '';
                          final arr = flight['arrival']?['airport'] ?? '';
                          final status = flight['flight_status'] ?? '';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FlightDetailsScreen(
                                    flightIata: flightNum,
                                  ),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode
                                        ? Colors.black.withOpacity(0.25)
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
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.flight,
                                        color: accent,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          airline,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Aircraft: $aircraft',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Flight: $flightNum',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: accent,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          dep,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.flag, color: accent, size: 15),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          arr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: status == 'active'
                                          ? accent.withOpacity(0.18)
                                          : Colors.orange.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Status: $status',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: status == 'active'
                                            ? accent
                                            : Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
