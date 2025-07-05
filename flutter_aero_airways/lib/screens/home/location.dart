import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_aero_airways/features/maps/search_location.dart';

class LocationSection extends StatefulWidget {
  final String fromCity;
  final String toCity;
  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;
  final bool isDarkMode;

  const LocationSection({
    super.key,
    required this.fromCity,
    required this.toCity,
    required this.onFromChanged,
    required this.onToChanged,
    required this.isDarkMode,
  });

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  Future<void> _pickLocation(String label, ValueChanged<String> onChanged, String? initialValue) async {
    final picked = await LocationPickerService.pickLocation(context, initialValue: initialValue);
    if (picked != null && picked.isNotEmpty) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickLocation('From', widget.onFromChanged, widget.fromCity),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.airplane,
                        size: 16,
                        color: widget.isDarkMode ? Colors.lime : Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'From',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDarkMode ? Colors.lime : Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.fromCity,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {
              widget.onFromChanged(widget.toCity);
              widget.onToChanged(widget.fromCity);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.lime : Colors.green.shade600,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.arrow_swap_horizontal,
                color: widget.isDarkMode ? Colors.black : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickLocation('To', widget.onToChanged, widget.toCity),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        size: 16,
                        color: widget.isDarkMode ? Colors.lime : Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'To',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDarkMode ? Colors.lime : Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.toCity,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}