import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/core/utils/helpers/helper_functions.dart';

enum StatusType { success, error, warning, info, loading }

class StatusModal extends StatefulWidget {
  final String title;
  final String message;
  final String actionText;
  final StatusType type;
  final VoidCallback? onAction;
  final VoidCallback? onClose;
  final bool showLogo;
  final bool autoDismiss;
  final int autoDismissDelay;
  final Widget? customContent;
  final IconData? customIcon;
  final Color? customColor;

  const StatusModal({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.actionText = 'OK',
    this.onAction,
    this.onClose,
    this.showLogo = false,
    this.autoDismiss = false,
    this.autoDismissDelay = 3000,
    this.customContent,
    this.customIcon,
    this.customColor,
  });

  @override
  State<StatusModal> createState() => _StatusModalState();

  // Static method to show success modal
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String actionText = 'Continue',
    VoidCallback? onAction,
    VoidCallback? onClose,
    bool showLogo = false,
    bool autoDismiss = false,
    int autoDismissDelay = 3000,
    Widget? customContent,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !autoDismiss,
      barrierColor: Colors.black54,
      builder: (context) => StatusModal(
        title: title,
        message: message,
        type: StatusType.success,
        actionText: actionText,
        onAction: onAction,
        onClose: onClose,
        showLogo: showLogo,
        autoDismiss: autoDismiss,
        autoDismissDelay: autoDismissDelay,
        customContent: customContent,
      ),
    );
  }

  // Static method to show error modal
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String actionText = 'Try Again',
    VoidCallback? onAction,
    VoidCallback? onClose,
    bool showLogo = false,
    Widget? customContent,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => StatusModal(
        title: title,
        message: message,
        type: StatusType.error,
        actionText: actionText,
        onAction: onAction,
        onClose: onClose,
        showLogo: showLogo,
        customContent: customContent,
      ),
    );
  }

  // Static method to show warning modal
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String actionText = 'Understood',
    VoidCallback? onAction,
    VoidCallback? onClose,
    bool showLogo = false,
    Widget? customContent,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => StatusModal(
        title: title,
        message: message,
        type: StatusType.warning,
        actionText: actionText,
        onAction: onAction,
        onClose: onClose,
        showLogo: showLogo,
        customContent: customContent,
      ),
    );
  }

  // Static method to show info modal
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String actionText = 'Got it',
    VoidCallback? onAction,
    VoidCallback? onClose,
    bool showLogo = false,
    Widget? customContent,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => StatusModal(
        title: title,
        message: message,
        type: StatusType.info,
        actionText: actionText,
        onAction: onAction,
        onClose: onClose,
        showLogo: showLogo,
        customContent: customContent,
      ),
    );
  }

  // Static method to show loading modal
  static Future<void> showLoading({
    required BuildContext context,
    required String title,
    required String message,
    bool showLogo = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => StatusModal(
        title: title,
        message: message,
        type: StatusType.loading,
        showLogo: showLogo,
      ),
    );
  }
}

class _StatusModalState extends State<StatusModal>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _iconController;
  late AnimationController _rippleController;
  late AnimationController _loadingController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _handleAutoDismiss();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.bounceOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();

    Future.delayed(const Duration(milliseconds: 400), () {
      _iconController.forward();
    });

    if (widget.type == StatusType.success) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _rippleController.forward();
      });
    }

    if (widget.type == StatusType.loading) {
      _loadingController.repeat();
    }
  }

  void _handleAutoDismiss() {
    if (widget.autoDismiss) {
      Future.delayed(Duration(milliseconds: widget.autoDismissDelay), () {
        if (mounted) {
          Navigator.of(context).pop();
          if (widget.onClose != null) {
            widget.onClose!();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _iconController.dispose();
    _rippleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleAction() {
    if (widget.onAction != null) {
      widget.onAction!();
    }
    Navigator.of(context).pop();
  }

  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    }
    Navigator.of(context).pop();
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
                        color: _getStatusColor(isDarkMode).withOpacity(0.2),
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

                      // Action button (not shown for loading)
                      if (widget.type != StatusType.loading)
                        _buildActionButton(isDarkMode),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          if (widget.type != StatusType.loading)
            IconButton(
              onPressed: _handleClose,
              icon: Icon(
                Icons.close,
                color: isDarkMode ? Colors.lime : Colors.green.shade700,
                size: 20,
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
          _buildAnimatedIcon(isDarkMode),

          const SizedBox(height: 24),

          // Title
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(isDarkMode),
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
                colors: [
                  _getStatusColor(isDarkMode),
                  _getStatusColor(isDarkMode).withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _iconController,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple effect for success
              if (widget.type == StatusType.success)
                AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 120 * _rippleAnimation.value,
                      width: 120 * _rippleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getStatusColor(
                            isDarkMode,
                          ).withOpacity(0.3 * (1 - _rippleAnimation.value)),
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),

              // Main icon container
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getStatusColor(isDarkMode).withOpacity(0.2),
                      _getStatusColor(isDarkMode).withOpacity(0.05),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(isDarkMode).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: widget.type == StatusType.loading
                    ? _buildLoadingIcon(isDarkMode)
                    : Icon(
                        widget.customIcon ?? _getStatusIcon(),
                        size: 45,
                        color:
                            widget.customColor ?? _getStatusColor(isDarkMode),
                      ),
              ),

              // Nigerian flag element for success
              if (widget.type == StatusType.success)
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.8),
                    ),
                    child: const Text('🇳🇬', style: TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIcon(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _loadingAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _loadingAnimation.value * 2 * 3.14159,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatusColor(isDarkMode),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(bool isDarkMode) {
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getStatusColor(isDarkMode),
            foregroundColor: _getButtonTextColor(isDarkMode),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            shadowColor: _getStatusColor(isDarkMode).withOpacity(0.3),
          ),
          child: Text(
            widget.actionText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(bool isDarkMode) {
    if (widget.customColor != null) return widget.customColor!;

    switch (widget.type) {
      case StatusType.success:
        return isDarkMode ? Colors.lime : Colors.green.shade600;
      case StatusType.error:
        return Colors.red;
      case StatusType.warning:
        return Colors.orange;
      case StatusType.info:
        return isDarkMode ? Colors.lime : Colors.blue;
      case StatusType.loading:
        return isDarkMode ? Colors.lime : Colors.green.shade600;
    }
  }

  Color _getButtonTextColor(bool isDarkMode) {
    switch (widget.type) {
      case StatusType.success:
        return isDarkMode ? Colors.black : Colors.white;
      case StatusType.error:
      case StatusType.warning:
        return Colors.white;
      case StatusType.info:
        return isDarkMode ? Colors.black : Colors.white;
      case StatusType.loading:
        return isDarkMode ? Colors.black : Colors.white;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.type) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.error:
        return Icons.error;
      case StatusType.warning:
        return Icons.warning;
      case StatusType.info:
        return Icons.info;
      case StatusType.loading:
        return Icons.hourglass_empty;
    }
  }
}

// Usage Examples:
class StatusModalExamples {
  // Success examples
  static void showBookingSuccess(BuildContext context) {
    StatusModal.showSuccess(
      context: context,
      title: 'Booking Confirmed!',
      message:
          'Your flight from Lagos to Abuja has been successfully booked. Check your email for details.',
      actionText: 'View Booking',
      showLogo: true,
      autoDismiss: true,
      autoDismissDelay: 4000,
      onAction: () {
        // Navigate to booking details
        print('Navigating to booking details...');
      },
    );
  }

  static void showPaymentSuccess(BuildContext context) {
    StatusModal.showSuccess(
      context: context,
      title: 'Payment Successful',
      message: 'Your payment of ₦45,000 has been processed successfully.',
      actionText: 'Continue',
      customContent: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('Transaction ID: AE123456789'),
            Text('Amount: ₦45,000'),
            Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
          ],
        ),
      ),
      onAction: () {
        print('Continue to next step...');
      },
    );
  }

  // Error examples
  static void showBookingError(BuildContext context) {
    StatusModal.showError(
      context: context,
      title: 'Booking Failed',
      message:
          'We couldn\'t process your booking. Please check your internet connection and try again.',
      actionText: 'Try Again',
      showLogo: true,
      onAction: () {
        // Retry booking
        print('Retrying booking...');
      },
    );
  }

  static void showPaymentError(BuildContext context) {
    StatusModal.showError(
      context: context,
      title: 'Payment Declined',
      message:
          'Your payment was declined by your bank. Please try a different payment method.',
      actionText: 'Change Payment Method',
      onAction: () {
        print('Opening payment methods...');
      },
    );
  }

  // Warning examples
  static void showFlightWarning(BuildContext context) {
    StatusModal.showWarning(
      context: context,
      title: 'Flight Delay Notice',
      message:
          'Your flight AE123 has been delayed by 45 minutes due to weather conditions.',
      actionText: 'Understood',
      showLogo: true,
      customContent: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('New Departure: 15:15'),
            Text('Gate: B12'),
            Text('Terminal: 2'),
          ],
        ),
      ),
    );
  }

  // Info examples
  static void showCheckinInfo(BuildContext context) {
    StatusModal.showInfo(
      context: context,
      title: 'Check-in Available',
      message:
          'Online check-in is now available for your flight tomorrow. Check in early to secure your preferred seat.',
      actionText: 'Check In Now',
      showLogo: true,
      onAction: () {
        print('Opening check-in...');
      },
    );
  }

  // Loading examples
  static void showProcessingPayment(BuildContext context) {
    StatusModal.showLoading(
      context: context,
      title: 'Processing Payment',
      message:
          'Please wait while we process your payment. This may take a few moments.',
      showLogo: true,
    );
  }

  static void showBookingFlight(BuildContext context) {
    StatusModal.showLoading(
      context: context,
      title: 'Booking Your Flight',
      message: 'We\'re securing your seat and processing your booking details.',
    );
  }
}
