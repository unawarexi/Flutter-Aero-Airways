import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class JourneySection extends StatelessWidget {
  final String tripType;
  final ValueChanged<String> onTripTypeChanged;

  const JourneySection({
    super.key,
    required this.tripType,
    required this.onTripTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: _TripTypeOption(
            value: 'one-way',
            label: 'One Way',
            isSelected: tripType == 'one-way',
            isDarkMode: isDarkMode,
            onTap: () => onTripTypeChanged('one-way'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TripTypeOption(
            value: 'round-trip',
            label: 'Round Trip',
            isSelected: tripType == 'round-trip',
            isDarkMode: isDarkMode,
            onTap: () => onTripTypeChanged('round-trip'),
          ),
        ),
      ],
    );
  }
}

class _TripTypeOption extends StatelessWidget {
  final String value;
  final String label;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _TripTypeOption({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.lime : Colors.green.shade600)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDarkMode ? Colors.lime : Colors.green.shade600)
                : (isDarkMode ? Colors.lime.shade300 : Colors.green.shade300),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? (isDarkMode ? Colors.black : Colors.white)
                : (isDarkMode ? Colors.lime : Colors.green.shade700),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class JourneyDateSection extends StatelessWidget {
  final String tripType;
  final DateTime departureDate;
  final DateTime returnDate;
  final ValueChanged<DateTime> onDepartureChanged;
  final ValueChanged<DateTime> onReturnChanged;
  final bool isDarkMode;

  const JourneyDateSection({
    super.key,
    required this.tripType,
    required this.departureDate,
    required this.returnDate,
    required this.onDepartureChanged,
    required this.onReturnChanged,
    required this.isDarkMode,
  });

  Future<void> _selectDate(BuildContext context, String label, DateTime initialDate, ValueChanged<DateTime> onChanged) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(context, 'Departure', departureDate, onDepartureChanged),
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
                        Iconsax.calendar,
                        size: 16,
                        color: isDarkMode ? Colors.lime : Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Departure',
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
                    '${departureDate.day}/${departureDate.month}/${departureDate.year}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (tripType == 'round-trip') ...[
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context, 'Return', returnDate, onReturnChanged),
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
                          Iconsax.calendar,
                          size: 16,
                          color: isDarkMode ? Colors.lime : Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Return',
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
                      '${returnDate.day}/${returnDate.month}/${returnDate.year}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
