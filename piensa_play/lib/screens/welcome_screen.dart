import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_styles.dart';
import '../utils/local_storage_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mascotController;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late Animation<double> _mascotBounce;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkSavedUser();
  }

  void _initAnimations() {
    // Animación de la mascota (flotando)
    _mascotController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _mascotBounce = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );

    // Animación de entrada con fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    // Partículas decorativas
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Iniciar animaciones secuencialmente
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _checkSavedUser() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    final userData = await LocalStorageService.getUserData();
    if (userData != null && mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          'userId': userData['userId'],
          'userName': userData['userName'],
          'avatarIndex': int.tryParse(userData['userAvatar'] ?? '0') ?? 0,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppStyles.backgroundGradient),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Partículas animadas de fondo
            ..._buildParticles(size),
            
            // Círculos decorativos con parallax sutil
            _buildDecorativeCircle(
              top: -size.height * 0.08,
              left: -size.width * 0.15,
              color: AppStyles.accentGreen.withValues(alpha: 0.12),
              size: 280,
            ),
            _buildDecorativeCircle(
              bottom: -size.height * 0.08,
              right: -size.width * 0.08,
              color: AppStyles.lightBlue.withValues(alpha: 0.08),
              size: 220,
            ),
            _buildDecorativeCircle(
              top: size.height * 0.3,
              right: -size.width * 0.2,
              color: AppStyles.yellow.withValues(alpha: 0.06),
              size: 150,
            ),

            // Contenido principal animado
            SafeArea(
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.05),
                        
                        // Mascota animada con efecto de flotación
                        AnimatedBuilder(
                          animation: _mascotBounce,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -_mascotBounce.value),
                              child: child,
                            );
                          },
                          child: _buildMascot(size.width * 0.48),
                        ),

                        const SizedBox(height: AppStyles.spacingXLarge),

                        // Título con efecto de gradiente
                        _buildAnimatedTitle(),

                        const SizedBox(height: AppStyles.spacingMedium),

                        // Subtítulo
                        Text(
                          '¡Aprende sobre medios y\nseguridad digital jugando!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),

                        SizedBox(height: size.height * 0.08),

                        // Botones con efectos premium
                        _buildPrimaryButton(),
                        
                        const SizedBox(height: 16),
                        
                        _buildSecondaryButton(),

                        SizedBox(height: size.height * 0.05),

                        // Selector de idioma mejorado
                        _buildLanguageSelector(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles(Size size) {
    return List.generate(6, (index) {
      final random = math.Random(index);
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final particleSize = 4.0 + random.nextDouble() * 4;
      
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final progress = (_particleController.value + index * 0.15) % 1.0;
          final y = startY - (progress * size.height * 0.3);
          final opacity = math.sin(progress * math.pi) * 0.4;
          
          return Positioned(
            left: startX + math.sin(progress * math.pi * 2) * 20,
            top: y,
            child: Container(
              width: particleSize,
              height: particleSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity.clamp(0.0, 0.4)),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildDecorativeCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
    required double size,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.0, 1.0],
          ),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildMascot(double size) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Círculo de fondo con gradiente
        Container(
          width: size * 0.78,
          height: size * 0.78,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFBDD87B),
                const Color(0xFFA8D15A),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFBDD87B).withValues(alpha: 0.4),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
        ),
        // Brillo del círculo
        Positioned(
          top: size * 0.12,
          left: size * 0.18,
          child: Container(
            width: size * 0.15,
            height: size * 0.08,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        // Mascota
        Positioned(
          top: -size * 0.18,
          child: Image.asset(
            'assets/image-removebg-preview 1.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTitle() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [Colors.white, Color(0xFFF6E16B), Colors.white],
          stops: [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: const Column(
        children: [
          Text(
            '¡Bienvenido a',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'PiensaPlay!',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      width: 260,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(31),
        boxShadow: [
          BoxShadow(
            color: AppStyles.yellow.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/login'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyles.yellow,
          foregroundColor: AppStyles.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(31),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Comenzar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppStyles.primaryBlue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return Container(
      width: 260,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: TextButton(
        onPressed: () => _showComingSoonDialog(),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.08),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              size: 24,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 8),
            Text(
              'Ver Tutorial',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.construction_rounded, color: AppStyles.yellow),
            const SizedBox(width: 12),
            const Text('¡Próximamente!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'El tutorial interactivo estará disponible muy pronto. ¡Por ahora, explora la app y diviértete aprendiendo!',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.language, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            'Español',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withValues(alpha: 0.7),
            size: 20,
          ),
        ],
      ),
    );
  }
}
