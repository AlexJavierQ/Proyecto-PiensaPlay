import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';

class GameActivitiesMapScreen extends StatefulWidget {
  const GameActivitiesMapScreen({super.key});

  @override
  State<GameActivitiesMapScreen> createState() => _GameActivitiesMapScreenState();
}

class _GameActivitiesMapScreenState extends State<GameActivitiesMapScreen>
    with SingleTickerProviderStateMixin {
  String? _userId;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final userData = await LocalStorageService.getUserData();
    if (mounted) {
      setState(() {
        _userId = userData?['userId'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final unitData = args['unitData'] as Map<String, dynamic>;
    final unitId = args['unitId'] as String?;

    if (unitId == null || _userId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F7FF),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF132757))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.getUnitActivities(unitId),
          builder: (context, activitySnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getUserProgress(_userId!),
              builder: (context, progressSnapshot) {
                if (activitySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF132757)));
                }

                final List<QueryDocumentSnapshot> activityDocs = activitySnapshot.data?.docs ?? [];

                if (activityDocs.isEmpty) {
                  return _buildEmptyState(context, unitData);
                }

                final List<QueryDocumentSnapshot> progressDocs = progressSnapshot.data?.docs ?? [];

                final completedIds = progressDocs
                    .where((doc) => (doc.data() as Map<String, dynamic>)['completed'] == true)
                    .map((doc) => (doc.data() as Map<String, dynamic>)['activityId'])
                    .toSet();

                List<Map<String, dynamic>> activities = [];
                for (int i = 0; i < activityDocs.length; i++) {
                  final data = activityDocs[i].data() as Map<String, dynamic>;
                  final id = activityDocs[i].id;
                  bool isCompleted = completedIds.contains(id);
                  bool isLocked = i == 0 ? false : !completedIds.contains(activityDocs[i - 1].id);

                  activities.add({
                    ...data,
                    'id': id,
                    'isCompleted': isCompleted,
                    'status': isLocked ? 'locked' : 'available',
                  });
                }

                // Calcular progreso
                final completedCount = activities.where((a) => a['isCompleted'] == true).length;
                final progressPercent = activities.isEmpty ? 0.0 : completedCount / activities.length;

                return Column(
                  children: [
                    // Header con info de la unidad
                    _buildUnitHeader(context, unitData, progressPercent, completedCount, activities.length),
                    
                    // Lista de actividades
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          final isLast = index == activities.length - 1;
                          
                          return AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              final delay = index * 0.15;
                              final progress = ((_animController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                              
                              return Transform.translate(
                                offset: Offset(30 * (1 - progress), 0),
                                child: Opacity(
                                  opacity: progress,
                                  child: child,
                                ),
                              );
                            },
                            child: _ActivityTile(
                              index: index + 1,
                              activity: activity,
                              isLast: isLast,
                              onTap: activity['status'] == 'locked'
                                  ? null
                                  : () => _onPlayActivity(context, unitId, unitData, activity),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Map<String, dynamic> unitData) {
    return Column(
      children: [
        _buildUnitHeader(context, unitData, 0, 0, 0),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.games_outlined, size: 60, color: Colors.grey[400]),
                ),
                const SizedBox(height: 20),
                Text(
                  'No hay actividades aún',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'El profesor agregará actividades pronto',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitHeader(
    BuildContext context,
    Map<String, dynamic> unitData,
    double progressPercent,
    int completedCount,
    int totalCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF132757),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132757).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra superior con botón de regreso
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  unitData['title'] ?? 'Actividades',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              // Mascota pequeña
              Image.asset(
                'assets/image-removebg-preview 1.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Card de progreso
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                // Círculo de progreso
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progressPercent,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppStyles.yellow),
                      ),
                      Text(
                        '${(progressPercent * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Info de progreso
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu Progreso',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount de $totalCount actividades',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Estrellas o badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppStyles.yellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: AppStyles.yellow, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$completedCount',
                        style: const TextStyle(
                          color: AppStyles.yellow,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onPlayActivity(
    BuildContext context,
    String? unitId,
    Map<String, dynamic> unitData,
    Map<String, dynamic> activity,
  ) {
    String route = '/game_play';
    final type = activity['type'];

    switch (type) {
      case 'fake_news_detector':
      case 'fake_news':
        route = '/fake_news_detector';
        break;
      case 'stereotype_breaker':
        route = '/stereotype_breaker';
        break;
      case 'word_selection':
      case 'word_path':
        route = '/word_path';
        break;
      case 'quiz':
        route = '/quiz_game';
        break;
      case 'match_pairs':
        route = '/match_pairs';
        break;
      case 'memory':
        route = '/memory_game';
        break;
      case 'order_sequence':
        route = '/order_sequence';
        break;
      case 'fill_blanks':
        route = '/fill_blanks';
        break;
      case 'final_exam':
        route = '/final_exam';
        break;
      default:
        route = '/game_play';
    }

    Navigator.pushNamed(
      context,
      route,
      arguments: {
        'unitId': unitId,
        'unitData': unitData,
        'activityData': activity,
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> activity;
  final bool isLast;
  final VoidCallback? onTap;

  const _ActivityTile({
    required this.index,
    required this.activity,
    required this.isLast,
    this.onTap,
  });

  IconData _getIconData(dynamic iconName) {
    if (iconName is IconData) return iconName;
    switch (iconName.toString()) {
      case 'book': return Icons.book_rounded;
      case 'extension': return Icons.extension_rounded;
      case 'lock': return Icons.lock_rounded;
      case 'favorite': return Icons.favorite_rounded;
      case 'security': return Icons.security_rounded;
      case 'verified_user': return Icons.verified_user_rounded;
      case 'games': return Icons.games_rounded;
      case 'school': return Icons.school_rounded;
      case 'psychology': return Icons.psychology_rounded;
      case 'quiz': return Icons.quiz_rounded;
      case 'link': return Icons.link_rounded;
      case 'sort': return Icons.sort_rounded;
      case 'edit_note': return Icons.edit_note_rounded;
      default: return Icons.videogame_asset_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = activity['status'] == 'locked';
    final isCompleted = activity['isCompleted'] == true;
    final colorVal = activity['color'] is int ? activity['color'] : 0xFFFBBF24;
    
    Color accentColor;
    IconData statusIcon;
    String buttonLabel;
    
    if (isCompleted) {
      accentColor = const Color(0xFF4ADE80);
      statusIcon = Icons.check_circle_rounded;
      buttonLabel = 'Repetir';
    } else if (isLocked) {
      accentColor = const Color(0xFF94A3B8);
      statusIcon = Icons.lock_rounded;
      buttonLabel = 'Bloqueado';
    } else {
      accentColor = Color(colorVal);
      statusIcon = Icons.play_circle_rounded;
      buttonLabel = '¡Jugar!';
    }

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda: Número y línea conectora
                Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: isLocked
                            ? null
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                              ),
                        color: isLocked ? const Color(0xFFE2E8F0) : null,
                        shape: BoxShape.circle,
                        boxShadow: isLocked
                            ? null
                            : [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                            : Text(
                                '$index',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isLocked ? Colors.grey : Colors.white,
                                ),
                              ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 3,
                        height: 32,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accentColor.withValues(alpha: 0.5),
                              const Color(0xFFE2E8F0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Tarjeta de contenido
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCompleted
                            ? accentColor.withValues(alpha: 0.4)
                            : const Color(0xFFE2E8F0),
                        width: isCompleted ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Ícono de la actividad
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _getIconData(activity['icon']),
                            color: accentColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['title'] ?? 'Actividad',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isLocked ? Colors.grey[400] : const Color(0xFF132757),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isLocked
                                    ? 'Completa la anterior'
                                    : (isCompleted
                                        ? '¡Completada!'
                                        : activity['subtitle'] ?? 'Toca para jugar'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isLocked ? Colors.grey[400] : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botón de acción
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: isLocked
                                ? null
                                : LinearGradient(
                                    colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                                  ),
                            color: isLocked ? Colors.grey[200] : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                size: 16,
                                color: isLocked ? Colors.grey[400] : Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                buttonLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isLocked ? Colors.grey[400] : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
