import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/core/utils/helpers/helper_functions.dart';

class ConfirmationModal extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? iconColor;
  final bool showLogo;
  final bool isDestructive;
  final Widget? customContent;

  const ConfirmationModal({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.icon = Icons.help_outline,
    this.onConfirm,
    this.onCancel,
    this.iconColor,
    this.showLogo = false,
    this.isDestructive = false,
    this.customContent,
  });

  @override
  State<ConfirmationModal> createState() => _ConfirmationModalState();

  // Static method to show the modal
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData icon = Icons.help_outline,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? iconColor,
    bool showLogo = false,
    bool isDestructive = false,
    Widget? customContent,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => ConfirmationModal(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        onConfirm: onConfirm,
        onCancel: onCancel,
        iconColor: iconColor,
        showLogo: showLogo,
        isDestructive: isDestructive,
        customContent: customContent,
      ),
    );
  }
}

class _ConfirmationModalState extends State<ConfirmationModal>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (widget.onConfirm != null) {
      widget.onConfirm!();
    }
    Navigator.of(context).pop(true);
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: size.width * 0.85,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                              const Color(0xFF1B4332), // Dark green
                              const Color(0xFF2D5016), // Darker green
                              const Color(0xFF40531B), // Forest green
                            ]
                          : [
                              const Color(0xFFFFFDE7), // Light lemon
                              const Color(0xFFF9FBE7), // Very light green
                              const Color(0xFFE8F5E8), // Light mint
                            ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.lime.withOpacity(0.1)
                            : Colors.green.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with logo (optional)
                      if (widget.showLogo) _buildHeader(isDarkMode),

                      // Icon and content
                      _buildContent(isDarkMode),

                      // Action buttons
                      _buildActionButtons(isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  Colors.lime.withOpacity(0.1),
                  Colors.green.shade800.withOpacity(0.05),
                ]
              : [Colors.green.shade50, Colors.white.withOpacity(0.8)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/aero_logo.png',
            height: 32,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 32,
              width: 96,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.lime : Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'AERO',
                  style: TextStyle(
                    color: isDarkMode ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: widget.isDestructive
                          ? [
                              Colors.red.withOpacity(0.2),
                              Colors.redAccent.withOpacity(0.1),
                            ]
                          : isDarkMode
                          ? [
                              Colors.lime.withOpacity(0.2),
                              Colors.green.shade800.withOpacity(0.1),
                            ]
                          : [
                              Colors.green.shade100,
                              Colors.white.withOpacity(0.5),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isDestructive
                            ? Colors.red.withOpacity(0.3)
                            : isDarkMode
                            ? Colors.lime.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    size: 40,
                    color:
                        widget.iconColor ??
                        (widget.isDestructive
                            ? Colors.red
                            : isDarkMode
                            ? Colors.lime
                            : Colors.green.shade700),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: widget.isDestructive
                  ? Colors.red
                  : isDarkMode
                  ? Colors.lime
                  : Colors.green.shade800,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Message
          Text(
            widget.message,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.8)
                  : Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),

          // Custom content
          if (widget.customContent != null) ...[
            const SizedBox(height: 20),
            widget.customContent!,
          ],

          const SizedBox(height: 24),

          // Decorative line
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDestructive
                    ? [Colors.red, Colors.redAccent]
                    : isDarkMode
                    ? [Colors.lime, Colors.green.shade300]
                    : [Colors.green.shade600, Colors.green.shade300],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.black.withOpacity(0.1), Colors.transparent]
              : [Colors.grey.shade50, Colors.white.withOpacity(0.8)],
        ),
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: TextButton(
              onPressed: _handleCancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDarkMode
                        ? Colors.lime.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                widget.cancelText,
                style: TextStyle(
                  color: isDarkMode ? Colors.lime : Colors.green.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Confirm button
          Expanded(
            child: ElevatedButton(
              onPressed: _handleConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isDestructive
                    ? Colors.red
                    : isDarkMode
                    ? Colors.lime
                    : Colors.green.shade600,
                foregroundColor: widget.isDestructive
                    ? Colors.white
                    : isDarkMode
                    ? Colors.black
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: widget.isDestructive
                    ? Colors.red.withOpacity(0.3)
                    : isDarkMode
                    ? Colors.lime.withOpacity(0.3)
                    : Colors.green.withOpacity(0.3),
              ),
              child: Text(
                widget.confirmText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Usage Examples:
class ConfirmationModalExamples {
  // Basic confirmation
  static void showBasicConfirmation(BuildContext context) {
    ConfirmationModal.show(
      context: context,
      title: 'Confirm Booking',
      message: 'Are you sure you want to proceed with this flight booking?',
      icon: Icons.flight_takeoff,
      confirmText: 'Book Now',
      cancelText: 'Cancel',
      onConfirm: () {
        // Handle booking confirmation
        print('Booking confirmed!');
      },
    );
  }

  // Destructive action
  static void showDeleteConfirmation(BuildContext context) {
    ConfirmationModal.show(
      context: context,
      title: 'Cancel Booking',
      message:
          'This action cannot be undone. Your booking will be permanently cancelled.',
      icon: Icons.warning,
      confirmText: 'Cancel Booking',
      cancelText: 'Keep Booking',
      isDestructive: true,
      onConfirm: () {
        // Handle cancellation
        print('Booking cancelled!');
      },
    );
  }

  // With logo
  static void showWithLogo(BuildContext context) {
    ConfirmationModal.show(
      context: context,
      title: 'Welcome to Aero Airways',
      message:
          'Thank you for choosing Nigeria\'s premium airline. Ready to start your journey?',
      icon: Icons.celebration,
      confirmText: 'Let\'s Go',
      cancelText: 'Maybe Later',
      showLogo: true,
      onConfirm: () {
        // Handle welcome confirmation
        print('Welcome confirmed!');
      },
    );
  }

  // With custom content
  static void showWithCustomContent(BuildContext context) {
    ConfirmationModal.show(
      context: context,
      title: 'Flight Details',
      message: 'Please review your flight information before proceeding.',
      icon: Icons.info_outline,
      confirmText: 'Proceed',
      cancelText: 'Edit',
      customContent: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('Lagos (LOS) → Abuja (ABV)'),
            Text('Flight AE123 • Today 14:30'),
            Text('Economy Class • 1 Passenger'),
          ],
        ),
      ),
      onConfirm: () {
        // Handle flight confirmation
        print('Flight confirmed!');
      },
    );
  }
}
