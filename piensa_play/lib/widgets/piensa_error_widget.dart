import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class PiensaErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String buttonText;

  const PiensaErrorWidget({
    super.key,
    this.message = '¡Ups! Algo salió mal.',
    this.onRetry,
    this.buttonText = 'Reintentar',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 80,
              color: AppStyles.primaryBlue.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Oh no!',
              style: AppStyles.headingMedium.copyWith(color: AppStyles.primaryBlue),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            if (onRetry != null)
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.yellow,
                    foregroundColor: AppStyles.primaryBlue,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
