import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_mate/bloc/auth/auth_bloc.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'dart:async';

import 'package:stock_mate/core/theme/constants.dart';
import 'package:stock_mate/repositories/auth_repository.dart';
import 'package:stock_mate/views/splash/widgets/food_icons.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _loadingProgress = 0.0;
  final bool _showWelcome = false;
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;
  late DateTime _loadingStartTime; // Thêm biến này

  @override
  void initState() {
    super.initState();

    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoAnimationController, curve: Curves.elasticOut),
    );

    _logoAnimationController.forward();

    // Bắt đầu loading
    _loadingStartTime = DateTime.now();

    Timer.periodic(const Duration(milliseconds: 3), (timer) {
      if (_loadingProgress < 1.0) {
        setState(() => _loadingProgress += 0.01);
      } else {
        timer.cancel();
        // Luôn đợi đủ 2s kể từ lúc bắt đầu
        final elapsed =
            DateTime.now().difference(_loadingStartTime).inMilliseconds;
        Future.delayed(
          Duration(milliseconds: 2000 - elapsed.clamp(0, 2000)),
          _proceedAfterLoading,
        );
      }
    });
  }

  void _proceedAfterLoading() {
    getIt<AuthRepository>().checkLoggedIn().then((loggedIn) {
      if (loggedIn && mounted) {
        context.read<AuthBloc>().add(RefreshToken());
      } else if (mounted) {
        context.go("/login");
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go("/navigation");
        } else if (state is AuthFailure) {
          context.go("/login");
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppGradients.backgroundGradient,
          ),
          child: Stack(
            children: [
              // Background decorative circles
              Positioned(
                top: size.height * 0.1,
                left: size.width * 0.1,
                child: _buildDecorativeCircle(
                  size.width * 0.4,
                  AppColors.lightOrange.withOpacity(0.3),
                ),
              ),
              Positioned(
                bottom: size.height * 0.15,
                right: size.width * 0.1,
                child: _buildDecorativeCircle(
                  size.width * 0.5,
                  AppColors.lightRed.withOpacity(0.3),
                ),
              ),
              Positioned(
                top: size.height * 0.4,
                left: size.width * 0.4,
                child: _buildDecorativeCircle(
                  size.width * 0.6,
                  AppColors.lightYellow.withOpacity(0.2),
                ),
              ),

              // Floating food icons
              FloatingFoodIcon(
                icon: Icons.local_pizza,
                color: AppColors.deepOrange,
                left: size.width * 0.2,
                top: size.height * 0.2,
                delay: const Duration(milliseconds: 0),
              ),
              FloatingFoodIcon(
                icon: Icons.coffee,
                color: AppColors.deepOrange,
                left: size.width * 0.7,
                top: size.height * 0.25,
                delay: const Duration(milliseconds: 500),
              ),
              FloatingFoodIcon(
                icon: Icons.cake,
                color: AppColors.deepOrange,
                left: size.width * 0.15,
                top: size.height * 0.65,
                delay: const Duration(milliseconds: 1000),
              ),
              FloatingFoodIcon(
                icon: Icons.apple,
                color: AppColors.deepOrange,
                left: size.width * 0.75,
                top: size.height * 0.7,
                delay: const Duration(milliseconds: 1500),
              ),
              FloatingFoodIcon(
                icon: Icons.restaurant,
                color: AppColors.deepOrange,
                left: size.width * 0.1,
                top: size.height * 0.4,
                delay: const Duration(milliseconds: 2000),
              ),
              FloatingFoodIcon(
                icon: Icons.icecream,
                color: AppColors.deepOrange,
                left: size.width * 0.8,
                top: size.height * 0.45,
                delay: const Duration(milliseconds: 2500),
              ),

              // Sparkle effects
              SparkleEffect(
                color: AppColors.amber,
                left: size.width * 0.3,
                top: size.height * 0.3,
              ),
              SparkleEffect(
                color: AppColors.amber,
                left: size.width * 0.7,
                top: size.height * 0.6,
              ),
              SparkleEffect(
                color: AppColors.amber,
                left: size.width * 0.5,
                top: size.height * 0.2,
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animation
                    AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: child,
                        );
                      },
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 80,
                            color: AppColors.deepOrange,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              Icons.star,
                              size: 24,
                              color: AppColors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Brand name with gradient
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppGradients.orangeRed.createShader(bounds),
                      child: const Text(
                        'StockMate',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Animated divider
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Container(
                          width: 100 * value,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: AppGradients.orangeRed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Slogan with fade-in animation
                    AnimatedOpacity(
                      opacity: _logoAnimationController.value,
                      duration: const Duration(seconds: 1),
                      child: const Text(
                        '🌿 "Tươi mỗi ngày – Khỏe mỗi bữa."',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Loading progress
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Đang chuẩn bị...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textLight,
                                ),
                              ),
                              Text(
                                '${(_loadingProgress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              // Background
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // Progress
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 8,
                                width: MediaQuery.of(context).size.width *
                                    0.8 *
                                    _loadingProgress,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.orangeRed,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _loadingProgress < 1.0
                                      ? Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Loading dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => _buildLoadingDot(index * 300),
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      'Đang tải dữ liệu..',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Welcome message
                    AnimatedOpacity(
                      opacity: _showWelcome ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Chào mừng đến với Stock Mate!',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom decorative dots
              Positioned(
                bottom: 40,
                left: 40,
                child: _buildDecorativeDots(AppColors.orange),
              ),
              Positioned(
                bottom: 40,
                right: 40,
                child: _buildDecorativeDots(AppColors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingDot(int delayMilliseconds) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.5 + (value * 0.5),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value > 0.5 ? AppColors.orange : AppColors.red,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDecorativeDots(Color color) {
    return Row(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.3 * value),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
