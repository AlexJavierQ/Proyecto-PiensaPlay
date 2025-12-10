import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class GameActivitiesMapScreen extends StatelessWidget {
  const GameActivitiesMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final unitData = args['unitData'] as Map<String, dynamic>;
    final unitId = args['unitId'] as String?;
    
    final games = (unitData['games'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    
    // Sort games by order
    games.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          unitData['title'] ?? 'Actividades',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Decorative map image
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative map elements
                  Positioned(
                    top: 40,
                    left: 30,
                    child: _MapMarker(
                      color: games.isNotEmpty && !(games[0]['locked'] ?? false)
                          ? const Color(0xFFFF6B6B)
                          : Colors.grey,
                      icon: Icons.location_on,
                      size: 50,
                    ),
                  ),
                  if (games.length > 1)
                    Positioned(
                      top: 120,
                      right: 50,
                      child: _MapMarker(
                        color: games.length > 1 && !(games[1]['locked'] ?? false)
                            ? const Color(0xFF4ECDC4)
                            : Colors.grey,
                        icon: Icons.location_on,
                        size: 50,
                      ),
                    ),
                  if (games.length > 2)
                    Positioned(
                      bottom: 40,
                      left: 60,
                      child: _MapMarker(
                        color: games.length > 2 && !(games[2]['locked'] ?? false)
                            ? const Color(0xFFFFD93D)
                            : Colors.grey,
                        icon: Icons.location_on,
                        size: 50,
                      ),
                    ),
                  // Character/mascot
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB84D),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Activities section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'ACTIVIDADES DISPONIBLES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppStyles.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.bolt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Activities list
            ...games.asMap().entries.map((entry) {
              final index = entry.key;
              final game = entry.value;
              final isLocked = game['locked'] ?? false;
              final requiredActivities = game['requiredActivities'] ?? 0;

              return _ActivityCard(
                title: game['title'] ?? 'Sin título',
                subtitle: game['subtitle'] ?? '',
                icon: _getIconForType(game['type'] ?? 'word_selection'),
                color: _getColorForIndex(index),
                isLocked: isLocked,
                requiredActivities: requiredActivities,
                onTap: isLocked
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          '/game_play',
                          arguments: {
                            'unitId': unitId,
                            'unitData': unitData,
                            'gameData': game,
                          },
                        );
                      },
              );
            }),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppStyles.primaryBlue,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Glosario',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'detective':
        return Icons.search;
      case 'mission':
        return Icons.flag;
      default:
        return Icons.text_fields;
    }
  }

  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFD93D),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
    ];
    return colors[index % colors.length];
  }
}

class _MapMarker extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double size;

  const _MapMarker({
    required this.color,
    required this.icon,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isLocked;
  final int requiredActivities;
  final VoidCallback? onTap;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isLocked,
    required this.requiredActivities,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey[300] : color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLocked ? Colors.grey : Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock : icon,
                    color: isLocked ? Colors.grey[600] : Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isLocked ? Colors.grey : AppStyles.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLocked
                            ? 'Completa $requiredActivities actividad${requiredActivities != 1 ? 'es' : ''} para avanzar'
                            : subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isLocked ? Colors.grey[600] : AppStyles.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Action button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey[400] : const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isLocked ? 'Bloqueado' : 'Jugar',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
