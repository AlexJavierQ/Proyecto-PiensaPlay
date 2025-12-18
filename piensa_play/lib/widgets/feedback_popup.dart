import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Pop-up de feedback inmediato para mostrar si la respuesta es correcta o incorrecta
/// Usado en todas las actividades del juego
class FeedbackPopup extends StatelessWidget {
  final bool isCorrect;
  final String? customMessage;
  final VoidCallback onContinue;

  const FeedbackPopup({
    super.key,
    required this.isCorrect,
    this.customMessage,
    required this.onContinue,
  });

  /// Muestra el pop-up de feedback
  static Future<void> show({
    required BuildContext context,
    required bool isCorrect,
    String? customMessage,
    required VoidCallback onContinue,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FeedbackPopup(
        isCorrect: isCorrect,
        customMessage: customMessage,
        onContinue: () {
          Navigator.of(ctx).pop();
          onContinue();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono circular
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFFC9E090)
                    : const Color(0xFFFF8FA3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCorrect ? Icons.check : Icons.block,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Mensaje principal
            Text(
              isCorrect ? '¡Correcto! Sigue así' : 'Incorrecto',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isCorrect
                    ? const Color(0xFF10B981)
                    : const Color(0xFFFF6B6B),
              ),
              textAlign: TextAlign.center,
            ),

            if (customMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                customMessage!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppStyles.textDark,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ] else if (!isCorrect) ...[
              const SizedBox(height: 12),
              const Text(
                'Recuerda leer detenidamente los mensajes.\n¡Vuelve a intentar!',
                style: TextStyle(
                  fontSize: 16,
                  color: AppStyles.textDark,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 32),

            // Botón continuar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF6E16B),
                  foregroundColor: AppStyles.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
