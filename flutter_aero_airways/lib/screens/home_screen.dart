import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/core/utils/constants/image_strings.dart';
import 'package:flutter_aero_airways/core/utils/helpers/helper_functions.dart';
import 'package:flutter_aero_airways/screens/home/class.dart';
import 'package:flutter_aero_airways/screens/home/journey.dart';
import 'package:flutter_aero_airways/screens/home/location.dart';
import 'package:flutter_aero_airways/screens/home/passengers.dart';
import 'package:flutter_aero_airways/screens/home/quick_actions.dart';
import 'package:flutter_aero_airways/screens/home/special_offers.dart';
import 'package:flutter_aero_airways/features/flight_management/presentation/search_result_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_aero_airways/global/authentication_provider.dart';
import 'package:flutter_aero_airways/core/network/pull_referesh.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _tripType = 'round-trip';
  String _passengers = '1 Adult';
  String _class = 'Economy';
  String _fromCity = 'Lagos';
  String _toCity = 'Abuja';
  DateTime _departureDate = DateTime.now().add(const Duration(days: 1));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 7));
  // String _citySearchQuery = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeController.forward();
    _slideController.forward();

    // Fetch current user data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCurrentUserData();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Fetch current user data
  void _fetchCurrentUserData() {
    final authNotifier = ref.read(authProvider.notifier);
    authNotifier.refreshCurrentUser();
  }

  // Add this method to handle pull-to-refresh logic
  Future<void> _refreshData() async {
    // Refresh user data
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.refreshCurrentUser();

    // Simulate additional data fetching
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      // Optionally reset or reload state variables if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    // final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF112712), // dark shade
                    const Color(0xFF181818), // darker shade
                    const Color(0xFF000000), // almost black
                  ]
                : [
                    const Color(0xFFFFFDE7),
                    const Color(0xFFF9FBE7),
                    const Color(0xFFE8F5E8),
                  ],
          ),
        ),
        child: SafeArea(
          child: AdvancedPullRefresh(
            primaryColor: isDarkMode ? Colors.lime : Colors.green.shade600,
            refreshText: 'Pull down to refresh',
            loadingText: 'Loading...',
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with user data
                  Consumer(
                    builder: (context, ref, _) {
                      final authState = ref.watch(authProvider);
                      final user = authState.user;
                      return _buildHeader(isDarkMode, user);
                    },
                  ),
                  const SizedBox(height: 10),
                  // Welcome section with user data
                  Consumer(
                    builder: (context, ref, _) {
                      final authState = ref.watch(authProvider);
                      final user = authState.user;
                      final isLoading = authState.isLoading;
                      final error = authState.error;

                      // Show loading indicator if user data is being fetched
                      if (isLoading && user == null) {
                        return _buildLoadingWelcome(isDarkMode);
                      }

                      // Show error message if there's an error
                      if (error != null) {
                        return _buildErrorWelcome(isDarkMode, error);
                      }

                      // Show welcome section with user data
                      return _buildWelcomeSection(isDarkMode, user);
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildFlightSearchCard(isDarkMode),
                  const SizedBox(height: 30),
                  QuickActionsSection(isDarkMode: isDarkMode),
                  const SizedBox(height: 30),
                  SpecialOffersSection(isDarkMode: isDarkMode),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, UserModel? user) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF112712)
                        : const Color(0xFF112712),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(TImages.secondLogo, width: 40, height: 40),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AERO',
                      style: TextStyle(
                        color: isDarkMode ? Colors.lime : Colors.green.shade700,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Iconsax.notification,
                    color: isDarkMode ? Colors.lime : Colors.green.shade700,
                  ),
                ),
               CircleAvatar(
                  radius: 20,
                  backgroundColor: isDarkMode
                      ? Colors.grey.shade900
                      : Colors.green.shade600,
                  backgroundImage: (user?.photoURL.isNotEmpty ?? false)
                      ? NetworkImage(user!.photoURL)
                      : const NetworkImage(TImages.profile),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDarkMode, UserModel? user) {
    final displayName = user?.displayName ?? "User";
    final firstName = displayName.split(' ').first;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, $firstName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.lime : Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'guest@example.com',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Where would you like to fly today?',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWelcome(bool isDarkMode) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 28,
                width: 200,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 16,
                width: 150,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 20,
                width: 250,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWelcome(bool isDarkMode, String error) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.lime : Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to load user data',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.red.shade400 : Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Where would you like to fly today?',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightSearchCard(bool isDarkMode) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black26 : Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              JourneySection(
                tripType: _tripType,
                onTripTypeChanged: (type) => setState(() => _tripType = type),
              ),
              const SizedBox(height: 24),
              LocationSection(
                fromCity: _fromCity,
                toCity: _toCity,
                onFromChanged: (city) => setState(() => _fromCity = city),
                onToChanged: (city) => setState(() => _toCity = city),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),
              JourneyDateSection(
                tripType: _tripType,
                departureDate: _departureDate,
                returnDate: _returnDate,
                onDepartureChanged: (date) =>
                    setState(() => _departureDate = date),
                onReturnChanged: (date) => setState(() => _returnDate = date),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PassengersSection(
                      passengers: _passengers,
                      onChanged: (val) => setState(() => _passengers = val),
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClassSection(
                      flightClass: _class,
                      onChanged: (val) => setState(() => _class = val),
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSearchButton(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          print('[HomeScreen] Search pressed with:');
          print('  fromCity: $_fromCity');
          print('  toCity: $_toCity');
          print('  departureDate: $_departureDate');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchResultScreen(
                fromCity: _fromCity,
                toCity: _toCity,
                departureDate: _departureDate,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.lime : Colors.green.shade600,
          foregroundColor: isDarkMode ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.search_normal, size: 20),
            SizedBox(width: 12),
            Text(
              'Search Flights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
