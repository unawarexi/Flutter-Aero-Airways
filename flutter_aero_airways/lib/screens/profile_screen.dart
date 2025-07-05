import 'package:flutter/material.dart';
import 'package:flutter_aero_airways/common/widgets/toast_alerts.dart';
import 'package:flutter_aero_airways/core/utils/constants/image_strings.dart';
import 'package:flutter_aero_airways/core/utils/helpers/helper_functions.dart';
import 'package:flutter_aero_airways/screens/home_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_aero_airways/global/authentication_provider.dart';
import 'package:flutter_aero_airways/core/network/pull_referesh.dart';
import 'package:flutter_aero_airways/core/services/auth_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isEditingProfile = false;
  bool _isUpdatingProfile = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeUserData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _initializeUserData() {
    // Initialize controllers with current user data
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.displayName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber.isEmpty
          ? "Add phone number"
          : user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Enhanced pull-to-refresh logic
  Future<void> _refreshProfileData() async {
    try {
      // Refresh current user data from Firestore
      await ref.read(authProvider.notifier).refreshCurrentUser();

      // Update controllers with fresh data
      _initializeUserData();

      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Profile refreshed successfully'),
      //       backgroundColor: Colors.green,
      //     ),
      //   );
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Update user profile
  Future<void> _updateProfile() async {
    if (_isUpdatingProfile) return;

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      final currentUser = ref.read(authProvider).user;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Create updated user model
      final updatedUser = currentUser.copyWith(
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      // Update via provider
      await ref.read(authProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        context.showToast('Profile updated successfully', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        context.showToast(
          'Failed to update profile: $e',
          type: ToastType.error,
        );
      }
    } finally {
      setState(() {
        _isUpdatingProfile = false;
      });
    }
  }

  // Handle sign out
  Future<void> _handleSignOut() async {
    try {
      await AuthService.signOut();
      ref.read(authProvider.notifier).clear();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', // Replace with your login route
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        context.showToast(
          'Failed to sign out: $e',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Show loading indicator if user data is being loaded
    if (authState.isLoading && user == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [
                      const Color(0xFF000000),
                      const Color(0xFF181818),
                      const Color(0xFF000000),
                    ]
                  : [
                      const Color(0xFFFFFDE7),
                      const Color(0xFFF9FBE7),
                      const Color(0xFFE8F5E8),
                    ],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Show error state if no user is loaded
    if (user == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [
                      const Color(0xFF000000),
                      const Color(0xFF181818),
                      const Color(0xFF000000),
                    ]
                  : [
                      const Color(0xFFFFFDE7),
                      const Color(0xFFF9FBE7),
                      const Color(0xFFE8F5E8),
                    ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.user,
                  size: 64,
                  color: isDarkMode ? Colors.lime : Colors.green.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'User not found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please sign in again',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleSignOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.lime
                        : Colors.green.shade600,
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  ),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF112712),
                    const Color(0xFF181818),
                    const Color(0xFF000000),
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
            onRefresh: _refreshProfileData,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(isDarkMode),
                  const SizedBox(height: 10),
                  _buildProfileHeader(isDarkMode, user),
                  const SizedBox(height: 10),
                  _buildProfileCard(isDarkMode, user),
                  const SizedBox(height: 10),
                  _buildQuickStats(isDarkMode, user),
                  const SizedBox(height: 20),
                  _buildMenuOptions(isDarkMode),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
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
                        ? Colors.grey.shade900
                        : Colors.green.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Iconsax.airplane,
                    color: isDarkMode ? Colors.lime : Colors.white,
                    size: 24,
                  ),
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
                    Text(
                      'AIRWAYS',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.lime.shade300
                            : Colors.green.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _isUpdatingProfile ? null : _toggleEditMode,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isUpdatingProfile
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDarkMode
                                  ? Colors.lime
                                  : Colors.green.shade700,
                            ),
                          )
                        : Icon(
                            _isEditingProfile
                                ? Iconsax.tick_circle
                                : Iconsax.edit,
                            key: ValueKey(_isEditingProfile),
                            color: isDarkMode
                                ? Colors.lime
                                : Colors.green.shade700,
                          ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  ),
                  icon: Icon(
                    Iconsax.arrow_left,
                    color: isDarkMode ? Colors.lime : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildProfileHeader(bool isDarkMode, UserModel user) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Profile Avatar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [Colors.lime, Colors.lime.shade300]
                          : [Colors.green.shade600, Colors.green.shade400],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: isDarkMode
                        ? Colors.grey.shade900
                        : Colors.white,
                    backgroundImage: user.photoURL.isNotEmpty
                        ? NetworkImage(user.photoURL)
                        : NetworkImage(TImages.profile),
                    // child: user.photoURL.isEmpty
                    //     ? Icon(
                    //         Iconsax.user,
                    //         size: 32,
                    //         color: isDarkMode
                    //             ? Colors.lime
                    //             : Colors.green.shade600,
                    //       )
                    //     : null,
                  ),
                ),
                const SizedBox(width: 16),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.displayName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.lime : Colors.green.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.lime.withOpacity(0.2)
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.emailVerified
                                  ? Iconsax.verify
                                  : Iconsax.info_circle,
                              size: 14,
                              color: user.emailVerified
                                  ? (isDarkMode
                                        ? Colors.lime
                                        : Colors.green.shade700)
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.emailVerified ? 'Verified' : 'Unverified',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: user.emailVerified
                                    ? (isDarkMode
                                          ? Colors.lime
                                          : Colors.green.shade700)
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isDarkMode, UserModel user) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.lime : Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileField(
                'Full Name',
                _nameController,
                Iconsax.user,
                isDarkMode,
              ),
              const SizedBox(height: 10),
              _buildProfileField(
                'Email',
                _emailController,
                Iconsax.sms,
                isDarkMode,
                enabled: false, // Email should not be editable
              ),
              const SizedBox(height: 10),
              _buildProfileField(
                'Phone',
                _phoneController,
                Iconsax.call,
                isDarkMode,
              ),
              const SizedBox(height: 10),
              // _buildInfoRow('User ID', user.uid, isDarkMode),
              // const SizedBox(height: 8),
              _buildInfoRow(
                'Provider',
                user.provider.toUpperCase(),
                isDarkMode,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Member Since',
                user.createdAt != null
                    ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                    : 'Unknown',
                isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

Widget _buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isDarkMode, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: _isEditingProfile && enabled,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: isDarkMode ? Colors.lime : Colors.green.shade600,
                size: 18,
              ),
              suffixIcon: !enabled
                  ? Icon(
                      Iconsax.lock,
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                      size: 15,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(bool isDarkMode, UserModel user) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Acct Status',
                  user.isActive ? 'Active' : 'Inactive',
                  user.isActive ? Iconsax.tick_circle : Iconsax.close_circle,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Email Status',
                  user.emailVerified ? 'Verified' : 'Unverified',
                  user.emailVerified ? Iconsax.verify : Iconsax.info_circle,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Last Login',
                  user.lastSignInTime != null
                      ? '${user.lastSignInTime!.day}/${user.lastSignInTime!.month}'
                      : 'Unknown',
                  Iconsax.calendar,
                  isDarkMode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: isDarkMode ? Colors.lime : Colors.green.shade600,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.lime : Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(bool isDarkMode) {
    final menuItems = [
      {
        'icon': Iconsax.ticket,
        'title': 'My Bookings',
        'subtitle': 'View your flight history',
        'action': () => _showFeatureComingSoon('My Bookings'),
      },
      {
        'icon': Iconsax.heart,
        'title': 'Wishlist',
        'subtitle': 'Saved destinations',
        'action': () => _showFeatureComingSoon('Wishlist'),
      },
      {
        'icon': Iconsax.refresh,
        'title': 'Refresh Data',
        'subtitle': 'Sync with server',
        'action': () => _refreshProfileData(),
      },
      {
        'icon': Iconsax.setting,
        'title': 'Settings',
        'subtitle': 'App preferences',
        'action': () => _showFeatureComingSoon('Settings'),
      },
      {
        'icon': Iconsax.info_circle,
        'title': 'Help & Support',
        'subtitle': 'Get assistance',
        'action': () => _showFeatureComingSoon('Help & Support'),
      },
      {
        'icon': Iconsax.logout,
        'title': 'Sign Out',
        'subtitle': 'Logout from your account',
        'action': () => _showSignOutDialog(isDarkMode),
      },
    ];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: menuItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == menuItems.length - 1;

              return _buildMenuTile(
                item['icon'] as IconData,
                item['title'] as String,
                item['subtitle'] as String,
                isDarkMode,
                isLast,
                item['title'] == 'Sign Out',
                item['action'] as VoidCallback,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    String subtitle,
    bool isDarkMode,
    bool isLast,
    bool isSignOut,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isLast ? 20 : 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDarkMode ? Colors.lime : Colors.green.shade600)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSignOut
                    ? Colors.red
                    : (isDarkMode ? Colors.lime : Colors.green.shade600),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSignOut
                          ? Colors.red
                          : (isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureComingSoon(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName - Coming Soon!'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditingProfile = !_isEditingProfile;
    });

    if (!_isEditingProfile) {
      // Save changes
      _updateProfile();
    }
  }

  void _showSignOutDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        title: Text(
          'Sign Out',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.lime : Colors.green.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleSignOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
