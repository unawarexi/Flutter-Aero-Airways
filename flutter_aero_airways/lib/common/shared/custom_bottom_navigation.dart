import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aero_airways/core/utils/helpers/helper_functions.dart';
import 'package:flutter_aero_airways/screens/flight_screen.dart';
import 'package:flutter_aero_airways/screens/home_screen.dart';
import 'package:flutter_aero_airways/screens/profile_screen.dart';
import 'package:iconsax/iconsax.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _hoveredIndex = -1;

  late AnimationController _animationController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _itemAnimations;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FlightScreen(),
    const ProfileScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Iconsax.home,
      selectedIcon: Iconsax.home_25,
      label: 'Home',
      color: Colors.lime, // Use lime for Home
    ),
    NavigationItem(
      icon: Iconsax.airplane,
      selectedIcon: Iconsax.airplane,
      label: 'Flights',
      color: Colors.green, // Use green for Flights
    ),
    NavigationItem(
      icon: Iconsax.user,
      selectedIcon: Iconsax.user,
      label: 'Profile',
      color: Colors.lime, // Use lime for Profile
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Individual item animations
    _itemControllers = List.generate(
      _navigationItems.length, // <-- fix: use the correct length
      (index) => AnimationController(
        duration: Duration(milliseconds: 200 + (index * 50)),
        vsync: this,
      ),
    );

    _itemAnimations = _itemControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
          ),
        )
        .toList();

    _animationController.forward();

    // Stagger item animations
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        _itemControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rippleController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      setState(() {
        _selectedIndex = index;
      });

      // Trigger ripple animation
      _rippleController.reset();
      _rippleController.forward();

      // Scale animation for selected item
      _itemControllers[index].reset();
      _itemControllers[index].forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);

    return 
      Scaffold(
        backgroundColor: isDarkMode
            ? const Color(0xFF000000)
            : const Color(0xFFE8F5E8),
        body: _screens[_selectedIndex],
        bottomNavigationBar: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - _fadeAnimation.value) * 100),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Flexible(
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade900 : Colors.green.shade100,
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(_navigationItems.length, (index) {
                            return _buildNavigationItem(index, isDarkMode);
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
    
    );
  }

  Widget _buildNavigationItem(int index, bool isDarkMode) {
    final item = _navigationItems[index];
    final isSelected = _selectedIndex == index;
    final isMiddle = index == 1;

    Color iconColor = isSelected
        ? (isDarkMode ? Colors.black : Colors.white)
        : (isDarkMode ? Colors.lime : Colors.green.shade700);

    Color bgColor = isMiddle
        ? (isDarkMode ? Colors.lime : Colors.green)
        : Colors.transparent;

    double iconSize = isMiddle ? 36 : (isSelected ? 28 : 24);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: isMiddle ? 64 : 52,
            height: isMiddle ? 64 : 52,
            decoration: BoxDecoration(
              color: isMiddle
                  ? bgColor
                  : (isSelected
                        ? (isDarkMode
                              ? Colors.lime.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2))
                        : Colors.transparent),
              shape: BoxShape.circle,
              boxShadow: isMiddle
                  ? [
                      BoxShadow(
                        color: bgColor.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: isMiddle
                      ? (isDarkMode ? Colors.black : Colors.white)
                      : iconColor,
                  size: iconSize,
                ),
                if (!isMiddle && isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.lime : Colors.green.shade700,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color color;
  final bool hasNotification;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.color,
    this.hasNotification = false,
  });
}
