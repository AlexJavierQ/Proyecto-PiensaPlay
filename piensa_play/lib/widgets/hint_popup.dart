import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Pop-up de pista para ayudar al usuario durante las actividades
class HintPopup extends StatelessWidget {
  final String hintText;
  final VoidCallback? onClose;

  const HintPopup({super.key, required this.hintText, this.onClose});

  /// Muestra el pop-up de pista
  static Future<void> show({
    required BuildContext context,
    required String hintText,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) =>
          HintPopup(hintText: hintText, onClose: () => Navigator.of(ctx).pop()),
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
            // Ícono de bombilla verde
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFC9E090),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb, size: 40, color: Colors.white),
            ),

            const SizedBox(height: 20),

            // Título
            const Text(
              '¡Pista!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppStyles.primaryBlue,
              ),
            ),

            const SizedBox(height: 16),

            // Texto de la pista
            Text(
              hintText,
              style: const TextStyle(
                fontSize: 16,
                color: AppStyles.textDark,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Botón cerrar (opcional, también se puede cerrar tocando fuera)
            if (onClose != null)
              TextButton(
                onPressed: onClose,
                child: const Text(
                  'Entendido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppStyles.primaryBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
