import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Widget de barra de progreso reutilizable para actividades
/// Muestra el progreso actual del usuario en formato "X/Y"
class ProgressBarWidget extends StatelessWidget {
  final int current;
  final int total;
  final Color? barColor;
  final Color? backgroundColor;
  final double height;

  const ProgressBarWidget({
    super.key,
    required this.current,
    required this.total,
    this.barColor,
    this.backgroundColor,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto de progreso
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progreso',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppStyles.textDark,
              ),
            ),
            Text(
              '$current/$total',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppStyles.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Barra de progreso
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor: backgroundColor ?? Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              barColor ?? const Color(0xFFC9E090),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget de barra de progreso circular para porcentajes
class CircularProgressWidget extends StatelessWidget {
  final double percentage;
  final double size;
  final Color? progressColor;
  final Color? backgroundColor;
  final double strokeWidth;
  final Widget? centerChild;

  const CircularProgressWidget({
    super.key,
    required this.percentage,
    this.size = 120,
    this.progressColor,
    this.backgroundColor,
    this.strokeWidth = 12,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress indicator
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor ?? Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? const Color(0xFFC9E090),
              ),
            ),
          ),

          // Center content
          centerChild ??
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.w800,
                  color: AppStyles.primaryBlue,
                ),
              ),
        ],
      ),
    );
  }
}
