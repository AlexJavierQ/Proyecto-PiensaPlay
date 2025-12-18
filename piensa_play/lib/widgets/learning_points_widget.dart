import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Widget para mostrar puntos de aprendizaje después de completar una actividad
class LearningPointsWidget extends StatelessWidget {
  final List<String> learningPoints;
  final String title;

  const LearningPointsWidget({
    super.key,
    required this.learningPoints,
    this.title = '¿Qué Aprendiste?',
  });

  @override
  Widget build(BuildContext context) {
    if (learningPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC9E090), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppStyles.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),

          ...learningPoints.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC9E090),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppStyles.textDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Widget para mostrar pistas a detectar en actividades de fake news
class ClueListWidget extends StatelessWidget {
  final List<ClueItem> clues;
  final String title;

  const ClueListWidget({
    super.key,
    required this.clues,
    this.title = 'PISTAS A DETECTAR',
  });

  @override
  Widget build(BuildContext context) {
    if (clues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppStyles.primaryBlue,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),

          ...clues.map((clue) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning,
                    color: clue.isDetected
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFF6B6B),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clue.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: clue.isDetected
                                ? const Color(0xFF10B981)
                                : AppStyles.textDark,
                          ),
                        ),
                        if (clue.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            clue.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (clue.isDetected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ClueItem {
  final String title;
  final String? description;
  final bool isDetected;

  ClueItem({required this.title, this.description, this.isDetected = false});
}
