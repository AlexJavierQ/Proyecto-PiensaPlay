import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class GameDetailScreen extends StatefulWidget {
  const GameDetailScreen({super.key});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool _hasCheckedArgs = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // Handle case when arguments are null (e.g., page reload)
    // Automatically redirect to game units
    if (args == null && !_hasCheckedArgs) {
      _hasCheckedArgs = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/game_units');
      });
      
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: AppStyles.primaryBlue,
          title: const Text('Redirigiendo...', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (args == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final unitData = args['unitData'] as Map<String, dynamic>;
    final unitId = args['unitId'] as String?;

    // Get first game from the unit
    final games = unitData['games'] as List<dynamic>? ?? [];
    if (games.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppStyles.primaryBlue,
          title: const Text('Error', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text('No hay juegos disponibles en esta unidad.'),
        ),
      );
    }

    final gameData = games[0] as Map<String, dynamic>;
    final gameType = gameData['type'] ?? 'word_selection';

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
          unitData['title'] ?? 'Juego',
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
          children: [
            // Header section with title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    unitData['title'] ?? 'Sin título',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppStyles.primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    unitData['subtitle'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppStyles.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Game image
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: unitData['imageUrl'] != null && (unitData['imageUrl'] as String).isNotEmpty
                    ? Image.network(
                        unitData['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(gameType);
                        },
                      )
                    : _buildPlaceholderImage(gameType),
              ),
            ),

            const SizedBox(height: 24),

            // Entry (pequeña entrada) - if exists
            if (unitData['entry'] != null && (unitData['entry'] as String).isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unitData['entry'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppStyles.textDark,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            if (unitData['entry'] != null && (unitData['entry'] as String).isNotEmpty)
              const SizedBox(height: 16),

            // Description section (always shown)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                unitData['description'] ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppStyles.textDark,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Introduction - if exists
            if (unitData['introduction'] != null && (unitData['introduction'] as String).isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unitData['introduction'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppStyles.textDark,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

            if (unitData['introduction'] != null && (unitData['introduction'] as String).isNotEmpty)
              const SizedBox(height: 16),

            // Mission - if exists
            if (unitData['mission'] != null && (unitData['mission'] as String).isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF8BC34A), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu Misión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppStyles.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      unitData['mission'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppStyles.textDark,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            if (unitData['mission'] != null && (unitData['mission'] as String).isNotEmpty)
              const SizedBox(height: 16),

            // Game Dynamics - if exists
            if (unitData['gameDynamics'] != null && (unitData['gameDynamics'] as List).isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dinámica del juego',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppStyles.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(unitData['gameDynamics'] as List).asMap().entries.map((entry) {
                      final index = entry.key;
                      final dynamic = entry.value.toString();
                      final colors = [
                        const Color(0xFFFFF9C4),
                        const Color(0xFFC8E6C9),
                        const Color(0xFFFFCCBC),
                        const Color(0xFFB2DFDB),
                      ];
                      final icons = [
                        Icons.search,
                        Icons.image,
                        Icons.message,
                        Icons.lightbulb,
                      ];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icons[index % icons.length],
                                color: AppStyles.primaryBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dynamic,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppStyles.textDark,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

            if (unitData['gameDynamics'] != null && (unitData['gameDynamics'] as List).isNotEmpty)

            // Skills section
            if (unitData['skills'] != null && (unitData['skills'] as List).isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Habilidades que desarrollarás',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppStyles.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: (unitData['skills'] as List).map((skill) {
                        return _SkillCard(skill: skill.toString());
                      }).toList(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Start button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/game_activities_map',
                    arguments: {
                      'unitId': unitId,
                      'unitData': unitData,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Comenzar Aventura',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(String gameType) {
    Color bgColor;
    IconData icon;

    switch (gameType) {
      case 'word_selection':
        bgColor = const Color(0xFF90C958);
        icon = Icons.forest;
        break;
      case 'detective':
        bgColor = const Color(0xFFFFB6C1);
        icon = Icons.search;
        break;
      case 'mission':
        bgColor = const Color(0xFF8FA3C9);
        icon = Icons.security;
        break;
      default:
        bgColor = AppStyles.lightGreen;
        icon = Icons.games;
    }

    return Container(
      color: bgColor,
      child: Center(
        child: Icon(icon, size: 80, color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final String skill;

  const _SkillCard({required this.skill});

  IconData _getSkillIcon(String skill) {
    if (skill.contains('crítico')) return Icons.psychology;
    if (skill.contains('Verificación')) return Icons.verified;
    if (skill.contains('fuentes')) return Icons.source;
    if (skill.contains('Seguridad')) return Icons.security;
    return Icons.star;
  }

  Color _getSkillColor(String skill) {
    if (skill.contains('crítico')) return const Color(0xFF1E3A8A);
    if (skill.contains('Verificación')) return const Color(0xFFFBBF24);
    if (skill.contains('fuentes')) return const Color(0xFF90C958);
    if (skill.contains('Seguridad')) return const Color(0xFFFF8FA3);
    return AppStyles.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSkillColor(skill).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSkillColor(skill).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getSkillIcon(skill),
            size: 32,
            color: _getSkillColor(skill),
          ),
          const SizedBox(height: 8),
          Text(
            skill,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getSkillColor(skill),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
