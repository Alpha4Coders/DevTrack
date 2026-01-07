import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/router.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Give a small delay for splash animation
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    try {
      final apiService = ApiService();
      final isAuthenticated = await apiService.isAuthenticated();
      
      print('🔐 Session check: isAuthenticated = $isAuthenticated');
      
      if (isAuthenticated) {
        // User has a valid session, check if token is still valid with server
        final authService = AuthService();
        final user = await authService.getCurrentUser();
        
        if (user != null && mounted) {
          print('✅ Valid session found for: ${user.name}');
          // Log remaining session time
          final remaining = await apiService.getRemainingSessionTime();
          if (remaining != null) {
            print('⏰ Session expires in: ${remaining.inDays}d ${remaining.inHours % 24}h');
          }
          context.go(AppRoutes.dashboard);
          return;
        } else {
          print('⚠️ Token exists but user validation failed');
        }
      }
      
      // No valid session, go to login
      print('🔐 No valid session, redirecting to login');
      if (mounted) {
        context.go(AppRoutes.login);
      }
    } catch (e) {
      print('❌ Auth check error: $e');
      // On error, go to login
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.backgroundSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo - use DevTrack.png
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/DevTrack.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 24),

              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'Dev',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    'Track',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Track your developer journey',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ).animate(delay: 500.ms).fadeIn(duration: 600.ms),

              const SizedBox(height: 48),

              // Loading indicator
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
