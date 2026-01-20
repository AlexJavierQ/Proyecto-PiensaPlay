import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_styles.dart';
import '../utils/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _loadingController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animación del logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );
    
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Animación de pulso
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animación de loading
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    // Iniciar secuencia
    _startSequence();
  }

  Future<void> _startSequence() async {
    // Esperar un frame
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Animar logo
    _logoController.forward();
    
    // Esperar y verificar sesión
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;
    
    // Verificar si hay usuario guardado
    final userData = await LocalStorageService.getUserData();
    
    if (!mounted) return;
    
    if (userData != null && userData['userId'] != null) {
      // Usuario existente, ir al home
      Navigator.pushReplacementNamed(context, '/home', arguments: userData);
    } else {
      // Usuario nuevo, ir a welcome
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF132757),
              Color(0xFF1E3A6E),
              Color(0xFF2B4A85),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Círculos decorativos de fondo
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            
            // Contenido principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animado
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppStyles.yellow, Color(0xFFF5B800)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppStyles.yellow.withValues(alpha: 0.4),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/image-removebg-preview 1.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, stack) => const Icon(
                              Icons.psychology_rounded,
                              size: 70,
                              color: Color(0xFF132757),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Título
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        const Text(
                          'PiensaPlay',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aprende jugando',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  AnimatedBuilder(
                    animation: _loadingController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final delay = index * 0.2;
                          final progress = ((_loadingController.value - delay) % 1.0);
                          final scale = 0.5 + 0.5 * (1 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0);
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppStyles.yellow.withValues(alpha: scale),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Footer
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: child,
                  );
                },
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
