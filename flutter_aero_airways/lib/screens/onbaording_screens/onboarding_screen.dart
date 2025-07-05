import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/core/utils/constants/image_strings.dart';
import 'package:flutter_aero_airways/core/utils/helpers/helper_functions.dart';
import 'package:flutter_aero_airways/features/authentication/presentation/login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF07120E),
                    const Color(0xFF2D5016), // Very dark green
                    const Color(0xFF40531B), // Forest green
                  ]
                : [
                    const Color(0xFFFFFDE7), // Light lemon
                    const Color(0xFFF9FBE7), // Very light green
                    const Color(0xFFE8F5E8), // Light mint
                  ],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      TImages.secondLogo, // Add your logo
                      height: 70,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 40,
                        width: 120,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.lime : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'AERO',
                            style: TextStyle(
                              color: isDarkMode ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to main app
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.lime
                              : Colors.green.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page view
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    _buildOnboardingPage(
                      context,
                      isDarkMode,
                      size,
                      icon: Icons.flight_takeoff,
                      title: 'Welcome to Aero Airways',
                      subtitle: 'Global\'s Premium Airline',
                      description:
                          'Experience the pride of flying with Nigeria\'s leading airline. Your journey to excellence begins here.',
                      nigerianElement: '🇳🇬',
                    ),
                    _buildOnboardingPage(
                      context,
                      isDarkMode,
                      size,
                      icon: Icons.schedule,
                      title: 'Always On Time',
                      subtitle: 'Punctuality is Our Promise',
                      description:
                          'We value your time as much as you do. Enjoy seamless scheduling and reliable departures across Nigeria.',
                      nigerianElement: '⏰',
                    ),
                    _buildOnboardingPage(
                      context,
                      isDarkMode,
                      size,
                      icon: Icons.star,
                      title: 'Premium Experience',
                      subtitle: 'First Class Service',
                      description:
                          'From Lagos to Abuja, Kano to Port Harcourt - enjoy world-class comfort and hospitality.',
                      nigerianElement: '✨',
                    ),
                  ],
                ),
              ),

              // Page indicator and navigation
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    // Page indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: 3,
                      effect: WormEffect(
                        dotHeight: 12,
                        dotWidth: 12,
                        spacing: 16,
                        radius: 8,
                        activeDotColor: isDarkMode
                            ? Colors.lime
                            : Colors.green.shade600,
                        dotColor: isDarkMode
                            ? Colors.lime.withOpacity(0.3)
                            : Colors.green.withOpacity(0.3),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous button
                        AnimatedOpacity(
                          opacity: _currentPage > 0 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: TextButton(
                            onPressed: _currentPage > 0
                                ? () {
                                    _pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios,
                                  color: isDarkMode
                                      ? Colors.lime
                                      : Colors.green.shade700,
                                  size: 16,
                                ),
                                Text(
                                  'Previous',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.lime
                                        : Colors.green.shade700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Next/Get Started button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage < 2) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                // Navigate to main app
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Login(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? Colors.lime
                                  : Colors.green.shade600,
                              foregroundColor: isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPage < 2 ? 'Next' : 'Get Started',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentPage < 2
                                      ? Icons.arrow_forward_ios
                                      : Icons.flight_takeoff,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildOnboardingPage(
    BuildContext context,
    bool isDarkMode,
    Size size, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required String nigerianElement,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isDarkMode
                        ? [
                            Colors.lime.withOpacity(0.3),
                            Colors.green.shade800.withOpacity(0.1),
                          ]
                        : [
                            Colors.green.shade100,
                            Colors.white.withOpacity(0.5),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.lime.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 80,
                        color: isDarkMode ? Colors.lime : Colors.green.shade700,
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Text(
                          nigerianElement,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.lime : Colors.green.shade800,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? Colors.lime.shade300
                      : Colors.green.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Description
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),

              // Decorative Nigerian pattern
              Container(
                height: 4,
                width: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.lime, Colors.green.shade300]
                        : [Colors.green.shade600, Colors.green.shade300],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
