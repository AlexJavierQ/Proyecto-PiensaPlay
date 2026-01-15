import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class CelebrationScreen extends StatefulWidget {
  const CelebrationScreen({super.key});

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Animación de escala para el contenido principal
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    // Animación de confetti
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Animación de rebote para las estrellas
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    // Generar partículas de confetti
    _generateConfetti();
    
    // Iniciar animaciones
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
      _confettiController.forward();
    });
  }

  void _generateConfetti() {
    final colors = [
      AppStyles.yellow,
      AppStyles.accentGreen,
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF9B59B6),
      const Color(0xFFE74C3C),
    ];
    
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.5,
        size: 8 + _random.nextDouble() * 8,
        color: colors[_random.nextInt(colors.length)],
        speed: 0.3 + _random.nextDouble() * 0.4,
        rotation: _random.nextDouble() * 360,
        rotationSpeed: _random.nextDouble() * 5 - 2.5,
      ));
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final pointsEarned = args['pointsEarned'] ?? 100;
    final activityTitle = args['activityTitle'] ?? 'Actividad';
    final isCorrect = args['isCorrect'] ?? true;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isCorrect 
                ? [const Color(0xFF132757), const Color(0xFF1E3A6E)]
                : [const Color(0xFF4A1A1A), const Color(0xFF2D1010)],
          ),
        ),
        child: Stack(
          children: [
            // Confetti animado
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                  size: MediaQuery.of(context).size,
                );
              },
            ),
            
            // Contenido principal
            SafeArea(
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Estrellas animadas
                      AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -_bounceAnimation.value),
                            child: child,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStar(40, 0.8),
                            const SizedBox(width: 8),
                            _buildStar(60, 1.0),
                            const SizedBox(width: 8),
                            _buildStar(40, 0.8),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Círculo con ícono
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isCorrect
                                ? [AppStyles.accentGreen, const Color(0xFF2ECC71)]
                                : [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isCorrect ? AppStyles.accentGreen : const Color(0xFFE74C3C))
                                  .withValues(alpha: 0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          isCorrect ? Icons.check_rounded : Icons.close_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Título
                      Text(
                        isCorrect ? '¡EXCELENTE!' : '¡SIGUE INTENTANDO!',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        activityTitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Puntos ganados
                      if (isCorrect) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.monetization_on_rounded,
                                color: AppStyles.yellow,
                                size: 36,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '+$pointsEarned',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: AppStyles.yellow,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'puntos',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                      
                      // Botón continuar
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppStyles.yellow, Color(0xFFF5B800)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppStyles.yellow.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'CONTINUAR',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF132757),
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF132757),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(double size, double opacity) {
    return Icon(
      Icons.star_rounded,
      size: size,
      color: AppStyles.yellow.withValues(alpha: opacity),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double size;
  Color color;
  double speed;
  double rotation;
  double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final currentY = particle.y + progress * particle.speed * 2.5;
      if (currentY > 1.2) continue;
      
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1 - progress * 0.5)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(
        particle.x * size.width,
        currentY * size.height,
      );
      canvas.rotate((particle.rotation + progress * particle.rotationSpeed * 360) * 3.14159 / 180);
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.6),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
