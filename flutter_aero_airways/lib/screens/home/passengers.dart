import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PassengersSection extends StatelessWidget {
  final String passengers;
  final ValueChanged<String> onChanged;
  final bool isDarkMode;

  const PassengersSection({
    super.key,
    required this.passengers,
    required this.onChanged,
    required this.isDarkMode,
  });

  void _showSelector(BuildContext context) {
    final options = [
      'Adults',
      'Children',
      'Family trip',
      'Business trip',
      'Group trip',
      'Custom',
      'Other',
      'No passengers',
      'cargo freight',
      'economy class',
      'business class',
      'first class',
      'VIP',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final themeColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    'Select Passengers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.lime : Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (context, idx) {
                        final option = options[idx];
                        return ListTile(
                          leading: Icon(
                            Iconsax.people,
                            color: isDarkMode ? Colors.lime : Colors.green.shade600,
                          ),
                          title: Text(option),
                          onTap: () {
                            onChanged(option);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSelector(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.people,
                  size: 16,
                  color: isDarkMode ? Colors.lime : Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Passengers',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.lime : Colors.green.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              passengers,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
