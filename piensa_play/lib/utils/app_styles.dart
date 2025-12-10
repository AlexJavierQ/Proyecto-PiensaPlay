import 'package:flutter/material.dart';

class AppStyles {
  // Colores principales de la aplicación
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color darkBlue = Color(0xFF132757); // Color exacto del prototipo
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color mediumBlue = Color(0xFF1E40AF);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color yellow = Color(0xFFFBBF24);
  static const Color lightBlue = Color(0xFF93C5FD);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);
  static const Color inputBackground = Color(0xFFE0F2FE);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color cardGray = Color(0xFFF3F4F6);
  static const Color lightGreen = Color(0xFFD7EDB2);
  static const Color limeGreen = Color(0xFFC9E090);
  static const Color slateText = Color(0xFF64748B);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E3A8A),
      Color(0xFF3B82F6),
      Color(0xFF60A5FA),
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF132757), // Color exacto del prototipo
      Color(0xFF1E3A8A), // Azul más claro hacia abajo
      Color(0xFF3B82F6), // Azul final
    ],
  );

  // Estilos de texto
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textDark,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryBlue,
  );

  static const TextStyle buttonTextWhite = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Estilos de botones
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: yellow,
    foregroundColor: primaryBlue,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    elevation: 3,
  );

  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: accentGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    elevation: 3,
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: Colors.white, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
  );

  // Estilos de input
  static InputDecoration textFieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: textLight),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: secondaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  // Estilos de contenedores
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static BoxDecoration avatarDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: primaryBlue, width: 3),
  );

  static BoxDecoration selectedAvatarDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: yellow, width: 4),
    boxShadow: [
      BoxShadow(
        color: yellow.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
}