import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/features/flight_management/presentation/favorite_Screen.dart';
import 'package:iconsax/iconsax.dart';

class QuickActionsSection extends StatelessWidget {
  final bool isDarkMode;
  const QuickActionsSection({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> quickActions = [
      {
        'title': 'Favorites',
        'icon': Iconsax.bookmark,
        'color': Colors.green,
        'screen': () => FavoriteScreen(),
      },
      {
        'title': 'Check-in',
        'icon': Iconsax.airplane_square,
        'color': Colors.blue,
        'screen': () => CheckInScreen(),
      },
      {
        'title': 'Flight Status',
        'icon': Iconsax.clock,
        'color': Colors.orange,
        'screen': () => FlightStatusScreen(),
      },
      {
        'title': 'My Trips',
        'icon': Iconsax.bag_2,
        'color': Colors.purple,
        'screen': () => MyTripsScreen(),
      },
      {
        'title': 'Offers',
        'icon': Iconsax.gift,
        'color': Colors.red,
        'screen': () => OffersScreen(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.lime : Colors.green.shade800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: quickActions.length,
            itemBuilder: (context, index) {
              final action = quickActions[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => action['screen'](),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade900
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black45
                                  : Colors.grey.shade200,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          action['icon'],
                          size: 32,
                          color: action['color'],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['title'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}



class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-in'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text('Check-in Screen')),
    );
  }
}

class FlightStatusScreen extends StatelessWidget {
  const FlightStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Status'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text('Flight Status Screen')),
    );
  }
}

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Trips'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text('My Trips Screen')),
    );
  }
}

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offers'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text('Offers Screen')),
    );
  }
}
