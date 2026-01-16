import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Widget para mostrar logros/badges del estudiante
class AchievementBadge extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final int? progress;
  final int? total;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.progress,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), // Padding reducido
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? color.withOpacity(0.5) : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: isUnlocked
            ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge Icon - Reducido a 50px
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked ? color : Colors.grey.shade300,
              shape: BoxShape.circle,
              boxShadow: isUnlocked
                  ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                if (!isUnlocked)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, color: Colors.white70, size: 20),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8), // Espacio reducido
          
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12, // Letra un poco más pequeña
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: isUnlocked ? AppStyles.darkBlue : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              height: 1.1,
              color: isUnlocked ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
          
          // Progress indicator (if not unlocked)
          if (!isUnlocked && progress != null && total != null) ...[
            const SizedBox(height: 6), // Espacio reducido
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (progress! / total!).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.6)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$progress/$total',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Grid de logros del estudiante
class AchievementsGrid extends StatelessWidget {
  final List<AchievementData> achievements;
  final int crossAxisCount;

  const AchievementsGrid({
    super.key,
    required this.achievements,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.68, // Ajuste final de ratio
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final a = achievements[index];
        return AchievementBadge(
          title: a.title,
          description: a.description,
          icon: a.icon,
          color: a.color,
          isUnlocked: a.isUnlocked,
          progress: a.progress,
          total: a.total,
        );
      },
    );
  }
}

/// Modelo de datos para un logro
class AchievementData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final int? progress;
  final int? total;
  final String category;

  AchievementData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.progress,
    this.total,
    this.category = 'general',
  });
}

/// Lista de logros predefinidos del sistema
class PiensaPlayAchievements {
  static List<AchievementData> getAll({
    int completedActivities = 0,
    int completedUnits = 0,
    int totalPoints = 0,
    int perfectScores = 0,
    int consecutiveDays = 0,
    Set<String> completedTypes = const {},
  }) {
    return [
      AchievementData(
        id: 'first_activity',
        title: 'Primer Paso',
        description: 'Completa tu primera actividad',
        icon: Icons.play_arrow,
        color: const Color(0xFF4CAF50),
        isUnlocked: completedActivities >= 1,
        category: 'beginner',
      ),
      AchievementData(
        id: 'five_activities',
        title: 'Explorador',
        description: 'Completa 5 actividades',
        icon: Icons.explore,
        color: const Color(0xFF2196F3),
        isUnlocked: completedActivities >= 5,
        progress: completedActivities.clamp(0, 5),
        total: 5,
        category: 'progress',
      ),
      AchievementData(
        id: 'ten_activities',
        title: 'Aventurero',
        description: 'Completa 10 actividades',
        icon: Icons.hiking,
        color: const Color(0xFF9C27B0),
        isUnlocked: completedActivities >= 10,
        progress: completedActivities.clamp(0, 10),
        total: 10,
        category: 'progress',
      ),
      AchievementData(
        id: 'first_unit',
        title: 'Misión Cumplida',
        description: 'Completa una unidad',
        icon: Icons.flag,
        color: const Color(0xFFFF9800),
        isUnlocked: completedUnits >= 1,
        category: 'progress',
      ),
      AchievementData(
        id: 'points_500',
        title: 'Coleccionista',
        description: 'Acumula 500 puntos',
        icon: Icons.star,
        color: const Color(0xFFF6E16B),
        isUnlocked: totalPoints >= 500,
        progress: totalPoints.clamp(0, 500),
        total: 500,
        category: 'points',
      ),
      AchievementData(
        id: 'points_1000',
        title: 'Campeón',
        description: 'Acumula 1000 puntos',
        icon: Icons.emoji_events,
        color: const Color(0xFFFFD700),
        isUnlocked: totalPoints >= 1000,
        progress: totalPoints.clamp(0, 1000),
        total: 1000,
        category: 'points',
      ),
      AchievementData(
        id: 'perfect_quiz',
        title: 'Perfeccionista',
        description: 'Obtén 100% en un quiz',
        icon: Icons.workspace_premium,
        color: const Color(0xFFE91E63),
        isUnlocked: perfectScores >= 1,
        category: 'skill',
      ),
      AchievementData(
        id: 'fake_news_expert',
        title: 'Detective Digital',
        description: 'Completa Fake News',
        icon: Icons.fact_check,
        color: const Color(0xFF00BCD4),
        isUnlocked: completedTypes.contains('fake_news'),
        category: 'skill',
      ),
      AchievementData(
        id: 'memory_master',
        title: 'Memoria de Elefante',
        description: 'Completa un Memorama',
        icon: Icons.psychology,
        color: const Color(0xFF673AB7),
        isUnlocked: completedTypes.contains('memory'),
        category: 'skill',
      ),
    ];
  }
}

/// Popup de celebración cuando se desbloquea un logro
class AchievementUnlockedPopup extends StatelessWidget {
  final AchievementData achievement;
  final VoidCallback onClose;

  const AchievementUnlockedPopup({
    super.key,
    required this.achievement,
    required this.onClose,
  });

  static void show(BuildContext context, AchievementData achievement) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AchievementUnlockedPopup(
        achievement: achievement,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: achievement.color.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration header
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: achievement.color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: achievement.color.withOpacity(0.5), blurRadius: 20)],
              ),
              child: Icon(achievement.icon, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 20),
            
            const Text(
              '🎉 ¡NUEVO LOGRO! 🎉',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppStyles.darkBlue, letterSpacing: 1),
            ),
            const SizedBox(height: 16),
            
            Text(
              achievement.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: achievement.color),
            ),
            const SizedBox(height: 8),
            
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: achievement.color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  '¡GENIAL!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
