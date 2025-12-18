import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Widget de tarjeta de escenario para actividades de estereotipos
/// Muestra un escenario con ícono, texto y estado (correcto/incorrecto/neutral)
class ScenarioCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ScenarioState state;
  final bool isSelected;
  final VoidCallback? onTap;

  const ScenarioCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.state = ScenarioState.neutral,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    IconData? stateIcon;
    Color? stateIconColor;

    switch (state) {
      case ScenarioState.correct:
        backgroundColor = const Color(0xFFC9E090).withValues(alpha: 0.2);
        borderColor = const Color(0xFF10B981);
        stateIcon = Icons.check_circle;
        stateIconColor = const Color(0xFF10B981);
        break;
      case ScenarioState.incorrect:
        backgroundColor = const Color(0xFFFF8FA3).withValues(alpha: 0.2);
        borderColor = const Color(0xFFFF6B6B);
        stateIcon = Icons.warning;
        stateIconColor = const Color(0xFFFF6B6B);
        break;
      case ScenarioState.neutral:
        backgroundColor = Colors.white;
        borderColor = isSelected ? AppStyles.primaryBlue : Colors.grey.shade300;
        stateIcon = null;
        stateIconColor = null;
        break;
      case ScenarioState.selected:
        backgroundColor = const Color(0xFFE3F2FD);
        borderColor = AppStyles.primaryBlue;
        stateIcon = null;
        stateIconColor = null;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícono principal
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    state == ScenarioState.neutral ||
                        state == ScenarioState.selected
                    ? AppStyles.primaryBlue.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppStyles.primaryBlue, size: 28),
            ),

            const SizedBox(width: 16),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppStyles.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            // Ícono de estado
            if (stateIcon != null) ...[
              const SizedBox(width: 12),
              Icon(stateIcon, color: stateIconColor, size: 28),
            ],
          ],
        ),
      ),
    );
  }
}

enum ScenarioState { neutral, selected, correct, incorrect }
