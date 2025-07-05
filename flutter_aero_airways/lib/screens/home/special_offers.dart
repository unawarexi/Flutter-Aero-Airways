import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SpecialOffersSection extends StatelessWidget {
  final bool isDarkMode;
  const SpecialOffersSection({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final offers = [
      {
        'title': 'Lagos to Abuja',
        'subtitle': 'Weekend Special',
        'price': '₦45,000',
        'discount': '30% OFF',
        'color': Colors.orange,
      },
      {
        'title': 'Kano to Port Harcourt',
        'subtitle': 'Summer Deal',
        'price': '₦55,000',
        'discount': '25% OFF',
        'color': Colors.blue,
      },
      {
        'title': 'Abuja to Enugu',
        'subtitle': 'Early Bird',
        'price': '₦35,000',
        'discount': '40% OFF',
        'color': Colors.purple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Special Offers',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.lime : Colors.green.shade800,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: isDarkMode ? Colors.lime : Colors.green.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      offer['color'] as Color,
                      (offer['color'] as Color).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              offer['discount'] as String,
                              style: TextStyle(
                                color: offer['color'] as Color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Icon(Iconsax.airplane, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        offer['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer['subtitle'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'From ${offer['price']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Iconsax.arrow_right_3,
                              color: offer['color'] as Color,
                              size: 16,
                            ),
                          ),
                        ],
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
