import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/security_service.dart';
import '../../settings/ui/security_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onSkip;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
    required this.onSkip,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    SecurityService.instance.init();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _checkSecurity() async {
    final securityService = SecurityService.instance;
    if (securityService.isPasswordEnabled()) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const SecurityPage(mode: SecurityPageMode.verify),
        ),
      );
      return result == true;
    }
    return true;
  }

  Future<void> _handleContinue() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!await _checkSecurity()) {
        setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signIn();

      if (mounted) {
        await HapticFeedback.lightImpact();
        widget.onLoginSuccess();
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to continue. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSkip() async {
    if (!await _checkSecurity()) {
      return;
    }
    widget.onSkip();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor.withValues(alpha: 0.08),
              themeProvider.backgroundColor,
              themeProvider.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  _buildTopSection(accentColor),
                  const SizedBox(height: 40),
                  _buildFeatureCards(accentColor),
                  const SizedBox(height: 40),
                  _buildErrorMessage(),
                  const SizedBox(height: 16),
                  _buildSignInButtons(accentColor),
                  const SizedBox(height: 24),
                  _buildTermsAndConditions(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(Color accentColor) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          _buildAnimatedLogo(accentColor),
          const SizedBox(height: 24),
          Text(
            'Smart Notes',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: accentColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Capture your thoughts, organize your life, and never miss a thing.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo(Color accentColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accentColor, accentColor.withValues(alpha: 0.7)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(Icons.note_alt_outlined, size: 60, color: Colors.white),
      ),
    );
  }

  Widget _buildFeatureCards(Color accentColor) {
    final features = [
      {
        'icon': Icons.note_alt_outlined,
        'title': 'Notes',
        'subtitle': 'Capture your thoughts',
        'color': Colors.purple,
      },
      {
        'icon': Icons.check_circle_outline,
        'title': 'To-Dos',
        'subtitle': 'Track your tasks',
        'color': Colors.blue,
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Calendar',
        'subtitle': 'Schedule events',
        'color': Colors.orange,
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Secure & Private',
        'subtitle': 'Your data is safe',
        'color': Colors.green,
      },
    ];

    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: _animationController,
                curve: Interval(0.3 + (index * 0.15), 1.0),
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: Offset(0, _slideAnimation.value),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.3 + (index * 0.15),
                          0.8 + (index * 0.1),
                        ),
                      ),
                    ),
                child: child,
              ),
            );
          },
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 800 + (index * 200)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: _buildFeatureCard(feature, accentColor),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (feature['color'] as Color).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (feature['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: feature['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature['subtitle'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.8, 1.0),
          ),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButtons(Color accentColor) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.85, 1.0),
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          _buildContinueButton(accentColor),
          const SizedBox(height: 12),
          _buildSkipButton(accentColor),
        ],
      ),
    );
  }

  Widget _buildContinueButton(Color accentColor) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleContinue,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.arrow_forward, size: 22),
        label: Text(
          _isLoading ? 'Loading...' : 'Get Started',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          shadowColor: accentColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildSkipButton(Color accentColor) {
    return TextButton(
      onPressed: _isLoading ? null : _handleSkip,
      child: Text(
        'Skip for now',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'By continuing, you agree to our Terms of Service and Privacy Policy',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey[400], height: 1.5),
      ),
    );
  }
}
