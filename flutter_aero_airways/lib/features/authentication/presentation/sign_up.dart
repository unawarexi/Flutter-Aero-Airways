import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:flutter_aero_airways/common/widgets/toast_alerts.dart';
import 'package:flutter_aero_airways/core/utils/constants/image_strings.dart';
import 'package:flutter_aero_airways/core/utils/helpers/helper_functions.dart';
import 'package:flutter_aero_airways/features/authentication/presentation/widgets/divider.dart';
import 'package:flutter_aero_airways/features/authentication/domain/google_auth.dart';
import 'package:flutter_aero_airways/common/shared/custom_bottom_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_aero_airways/global/authentication_provider.dart';
import 'package:flutter_aero_airways/core/services/auth_service.dart';
import 'package:flutter_aero_airways/common/widgets/status_modal.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _receiveUpdates = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

 void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        context.showToast(
          "Please agree to terms and conditions",
          type: ToastType.error,
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final userCredential = await AuthService.signUpWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _fullNameController.text,
          phoneNumber: _phoneController.text, // Pass phone number to Firestore
        );
        final user = userCredential.user;
        if (user != null && mounted) {
          final userModel = UserModel.fromFirebaseUser(user);
          ref.read(authProvider.notifier).setUser(userModel);

          await StatusModal.showSuccess(
            context: context,
            title: 'Account Created',
            message: 'Your account has been created successfully!',
            actionText: 'Continue',
            showLogo: true,
            autoDismiss: true,
            autoDismissDelay: 1500,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavigationBarWidget(),
            ),
          );
        }
      } catch (e) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        if (mounted) {
          await StatusModal.showError(
            context: context,
            title: 'Sign Up Failed',
            message: errorMessage,
            actionText: 'Try Again',
            showLogo: true,
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
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
        child: SafeArea(
          child: Stack(
            children: [
              
              Positioned(
                top: 10,
                left: 32,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildLogo(isDarkMode),
                ),
              ),

              // Main content
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Welcome text - centered
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      top: 80, // Space for logo
                                      bottom: 16,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Join Aero Airways',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? Colors.lime
                                                : Colors.green.shade800,
                                            height: 1.2,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Create your account and start flying',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: isDarkMode
                                                ? Colors.white.withOpacity(0.7)
                                                : Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Decorative line
                                Container(
                                  height: 3,
                                  width: 60,
                                  margin: const EdgeInsets.only(bottom: 32),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDarkMode
                                          ? [Colors.lime, Colors.green.shade300]
                                          : [
                                              Colors.green.shade600,
                                              Colors.green.shade300,
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),

                                // Sign up form
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: _buildSignUpForm(isDarkMode),
                                ),

                                const SizedBox(height: 20),

                                // Divider
                                const CustomDivider(),

                                const SizedBox(height: 20),

                                // Google Auth
                                GoogleAuthentication(),

                                const SizedBox(height: 20),

                                // Sign in button
                                _buildSignInButton(isDarkMode, size),

                                const SizedBox(height: 20),

                                // Footer
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: _buildFooter(isDarkMode),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildLogo(bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode ? Colors.grey.shade900 : const Color(0xFF112712),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.lime.withOpacity(0.2)
                : Colors.green.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Image.asset(
        TImages.secondLogo,
        height: 70,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 32,
          width: 40,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.lime : Colors.green,
            borderRadius: BorderRadius.circular(8),
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
    );
  }

  Widget _buildSignUpForm(bool isDarkMode) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAnimatedTextField(
            controller: _fullNameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            isDarkMode: isDarkMode,
            validator: ValidationBuilder()
                .minLength(2, 'Name must be at least 2 characters')
                .required('Please enter your full name')
                .build(),
          ),
          const SizedBox(height: 10),
          _buildAnimatedTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDarkMode: isDarkMode,
            validator: ValidationBuilder()
                .email('Please enter a valid email')
                .required('Please enter your email')
                .build(),
          ),
          const SizedBox(height: 10),
          _buildAnimatedTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            isDarkMode: isDarkMode,
            validator: ValidationBuilder()
                .minLength(10, 'Please enter a valid phone number')
                .required('Please enter your phone number')
                .build(),
          ),
          const SizedBox(height: 10),
          _buildAnimatedTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            isDarkMode: isDarkMode,
            validator: ValidationBuilder()
                .minLength(8, 'Password must be at least 8 characters')
                .required('Please enter your password')
                .build(),
          ),
          const SizedBox(height: 10),
          _buildAnimatedTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            icon: Icons.lock_outline,
            isPassword: true,
            isConfirmPassword: true,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildCheckboxSection(isDarkMode),
          const SizedBox(height: 30),
          _buildSignUpButton(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCheckboxSection(bool isDarkMode) {
    return Column(
      children: [
        // Terms and conditions checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                activeColor: isDarkMode ? Colors.lime : Colors.green,
                checkColor: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                children: [
                  Text(
                    'I agree to the ',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to terms and conditions
                    },
                    child: Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        color: isDarkMode ? Colors.lime : Colors.green.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    ' and ',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to privacy policy
                    },
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: isDarkMode ? Colors.lime : Colors.green.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Newsletter checkbox
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: _receiveUpdates,
                onChanged: (value) {
                  setState(() {
                    _receiveUpdates = value ?? false;
                  });
                },
                activeColor: isDarkMode ? Colors.lime : Colors.green,
                checkColor: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'I want to receive flight updates and promotional offers',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.8)
                      : Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpButton(bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.lime : Colors.green.shade600,
          foregroundColor: isDarkMode ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: isDarkMode
              ? Colors.lime.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.flight_takeoff, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildSignInButton(bool isDarkMode, Size size) {
    return SizedBox(
      width: size.width * 0.8,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDarkMode ? Colors.lime : Colors.green.shade600,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Already have an account? Sign In',
          style: TextStyle(
            color: isDarkMode ? Colors.lime : Colors.green.shade700,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        controller: controller,
        obscureText:
            isPassword &&
            (isConfirmPassword
                ? !_isConfirmPasswordVisible
                : !_isPasswordVisible),
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: isDarkMode ? Colors.lime : Colors.green.shade600,
            size: 20,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (isConfirmPassword
                            ? _isConfirmPasswordVisible
                            : _isPasswordVisible)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: isDarkMode ? Colors.lime : Colors.green.shade600,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isConfirmPassword) {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      } else {
                        _isPasswordVisible = !_isPasswordVisible;
                      }
                    });
                  },
                )
              : null,
          labelStyle: TextStyle(
            color: isDarkMode
                ? Colors.white.withOpacity(0.7)
                : Colors.grey.shade600,
            fontSize: 14,
          ),
          filled: true,
          fillColor: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDarkMode
                  ? Colors.lime.withOpacity(0.3)
                  : Colors.green.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDarkMode
                  ? Colors.lime.withOpacity(0.3)
                  : Colors.green.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.lime : Colors.green.shade600,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    return Column(
      children: [
        // Security info
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.lime.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? Colors.lime.withOpacity(0.3)
                  : Colors.green.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: isDarkMode ? Colors.lime : Colors.green.shade600,
                size: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your data is secured with 256-bit encryption',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey.shade700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Nigerian flag
       
      ],
    );
  }
}
