import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final provider = context.read<AppProvider>();
    await provider.init();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full splash artwork (logo + wordmark + tagline baked into the image)
          Image.asset(
            'assets/images/splash_screen.png',
            fit: BoxFit.cover,
          ).animate().fadeIn(duration: 500.ms),
          // Loading indicator, overlaid near the bottom
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.indigoPrimary.withOpacity(0.7),
                  ),
                ),
              ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }
}
