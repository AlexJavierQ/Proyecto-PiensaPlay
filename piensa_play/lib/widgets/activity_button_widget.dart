import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Botones estándar para actividades con estilos consistentes
class ActivityButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ActivityButtonType type;
  final IconData? icon;
  final bool isFullWidth;

  const ActivityButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ActivityButtonType.primary,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case ActivityButtonType.primary:
        backgroundColor = AppStyles.primaryBlue;
        textColor = Colors.white;
        break;
      case ActivityButtonType.secondary:
        backgroundColor = const Color(0xFFF6E16B);
        textColor = AppStyles.primaryBlue;
        break;
      case ActivityButtonType.success:
        backgroundColor = const Color(0xFFC9E090);
        textColor = AppStyles.primaryBlue;
        break;
      case ActivityButtonType.danger:
        backgroundColor = const Color(0xFFFF8FA3);
        textColor = Colors.white;
        break;
      case ActivityButtonType.outline:
        backgroundColor = Colors.white;
        textColor = AppStyles.primaryBlue;
        break;
    }

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: type == ActivityButtonType.outline
              ? const BorderSide(color: AppStyles.primaryBlue, width: 2)
              : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: type == ActivityButtonType.outline ? 0 : 2,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, height: 56, child: button)
        : SizedBox(height: 56, child: button);
  }
}

enum ActivityButtonType { primary, secondary, success, danger, outline }

/// Botones de respuesta True/False o Correcto/Incorrecto
class AnswerButton extends StatelessWidget {
  final String text;
  final bool isCorrect;
  final VoidCallback onPressed;
  final IconData? icon;

  const AnswerButton({
    super.key,
    required this.text,
    required this.isCorrect,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isCorrect
                ? const Color(0xFFC9E090)
                : const Color(0xFFFF8FA3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon ?? (isCorrect ? Icons.check : Icons.block), size: 24),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
