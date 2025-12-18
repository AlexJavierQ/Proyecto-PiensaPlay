import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Widget de tarjeta de puntuación reutilizable
/// Muestra puntos ganados con animación y estilo consistente
class ScoreCardWidget extends StatelessWidget {
  final int points;
  final String label;
  final bool showStar;
  final Color? backgroundColor;

  const ScoreCardWidget({
    super.key,
    required this.points,
    this.label = 'Puntuación',
    this.showStar = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: backgroundColor != null
              ? [backgroundColor!, backgroundColor!]
              : [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showStar) const Icon(Icons.star, color: Colors.white, size: 28),
          if (showStar) const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$points puntos',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget de resumen de misión con estadísticas
/// Muestra correctas, incorrectas y puntuación final
class MissionSummaryWidget extends StatelessWidget {
  final int correctAnswers;
  final int incorrectAnswers;
  final double finalScore;

  const MissionSummaryWidget({
    super.key,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.finalScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Resumen de tu Misión',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppStyles.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              // Correctas
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9E090).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$correctAnswers',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const Text(
                        'Correctas',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppStyles.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Incorrectas
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8FA3).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cancel,
                        color: Color(0xFFFF6B6B),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$incorrectAnswers',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                      const Text(
                        'Incorrectas',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppStyles.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Puntuación final
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Text(
                      '${finalScore.toInt()}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Puntuación Final',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
