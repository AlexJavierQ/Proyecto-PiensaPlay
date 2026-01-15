import 'package:flutter/material.dart';

class AppStyles {
  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES PRINCIPALES
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color darkBlue = Color(0xFF132757);
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
  
  // Colores adicionales para efectos premium
  static const Color coral = Color(0xFFF9879B);
  static const Color peach = Color(0xFFFFCC80);
  static const Color lavender = Color(0xFFE8D5FF);
  static const Color mint = Color(0xFFA8E6CF);
  static const Color skyBlue = Color(0xFFB4E4FF);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTES
  // ═══════════════════════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF132757), Color(0xFF1E3A8A), Color(0xFF3B82F6)],
  );
  
  // Nuevos gradientes premium
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
  );
  
  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  );
  
  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );
  
  static LinearGradient cardGradient(Color baseColor) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      baseColor,
      Color.lerp(baseColor, Colors.white, 0.2)!,
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ESTILOS DE TEXTO
  // ═══════════════════════════════════════════════════════════════════════════
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
    letterSpacing: -0.3,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: darkBlue,
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
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textLight,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryBlue,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonTextWhite = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textLight,
    letterSpacing: 0.3,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ESTILOS DE BOTONES
  // ═══════════════════════════════════════════════════════════════════════════
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: yellow,
    foregroundColor: primaryBlue,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    elevation: 4,
    shadowColor: yellow.withValues(alpha: 0.4),
  );

  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: accentGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    elevation: 4,
    shadowColor: accentGreen.withValues(alpha: 0.4),
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: Colors.white, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
  );
  
  static ButtonStyle glassButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.white.withValues(alpha: 0.15),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 0,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ESTILOS DE INPUT
  // ═══════════════════════════════════════════════════════════════════════════
  static InputDecoration textFieldDecoration(String hintText, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: textLight.withValues(alpha: 0.7)),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: primaryBlue, size: 22) : null,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: coral, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DECORACIONES DE CONTENEDORES
  // ═══════════════════════════════════════════════════════════════════════════
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  static BoxDecoration premiumCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: primaryBlue.withValues(alpha: 0.08),
        blurRadius: 30,
        offset: const Offset(0, 15),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.8),
        blurRadius: 10,
        offset: const Offset(-5, -5),
      ),
    ],
  );
  
  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
  
  static BoxDecoration coloredCardDecoration(Color color) => BoxDecoration(
    gradient: cardGradient(color),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
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
        color: yellow.withValues(alpha: 0.4),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );
  
  static BoxDecoration floatingDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: darkBlue.withValues(alpha: 0.15),
        blurRadius: 30,
        offset: const Offset(0, 15),
      ),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING Y DIMENSIONES
  // ═══════════════════════════════════════════════════════════════════════════
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
  static const double radiusCircular = 100.0;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // DURACIONES DE ANIMACIÓN
  // ═══════════════════════════════════════════════════════════════════════════
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CURVAS DE ANIMACIÓN
  // ═══════════════════════════════════════════════════════════════════════════
  static const Curve curveDefault = Curves.easeInOutCubic;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSmooth = Curves.easeOutQuart;
  static const Curve curveSnappy = Curves.easeOutBack;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS DE UTILIDAD
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Crea una sombra suave para elementos flotantes
  static List<BoxShadow> softShadow(Color color, {double blur = 20, double spread = 0}) => [
    BoxShadow(
      color: color.withValues(alpha: 0.15),
      blurRadius: blur,
      spreadRadius: spread,
      offset: const Offset(0, 8),
    ),
  ];
  
  /// Crea una sombra de elevación pronunciada
  static List<BoxShadow> elevatedShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.2),
      blurRadius: 25,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: color.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Obtiene un color de estado según el tipo
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return accentGreen;
      case 'in_progress':
      case 'warning':
        return coral;
      case 'locked':
      case 'disabled':
        return skyBlue;
      case 'error':
        return const Color(0xFFEF4444);
      default:
        return textLight;
    }
  }
}