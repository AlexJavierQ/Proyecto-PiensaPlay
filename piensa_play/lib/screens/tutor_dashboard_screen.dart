import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';

class TutorDashboardScreen extends StatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  State<TutorDashboardScreen> createState() => _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends State<TutorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String? _tutorId;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _loadTutorId();
  }

  Future<void> _loadTutorId() async {
    // El tutor ID debería venir de los argumentos o del storage
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    setState(() {
      _tutorId = args?['tutorId'] ?? 'demo_tutor';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tutorId == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _tutorId = args?['tutorId'] ?? 'demo_tutor';
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats
                    _buildStatsSection(),
                    const SizedBox(height: 28),

                    // Mis Clases
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mis Clases',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF132757),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/create_class',
                              arguments: {'tutorId': _tutorId},
                            );
                            if (result == true) {
                              setState(() {}); // Refresh
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppStyles.accentGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  'Nueva',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildClassesList(),

                    const SizedBox(height: 28),

                    // Acciones Rápidas
                    const Text(
                      'Acciones Rápidas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF132757),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(),

                    const SizedBox(height: 28),

                    // Tipos de Actividades Info
                    const Text(
                      'Tipos de Actividades',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF132757),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActivityTypes(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF132757), Color(0xFF1E3A6E)],
        ),
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
      child: Row(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Hola, Profesor!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const Text(
                  'Panel de Control',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _tutorId != null ? FirebaseService.getTutorClasses(_tutorId!) : null,
      builder: (context, classesSnapshot) {
        final totalClasses = classesSnapshot.data?.docs.length ?? 0;
        
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.school_rounded,
                value: '$totalClasses',
                label: 'Clases',
                color: const Color(0xFF42A5F5),
                delay: 0,
                animation: _animController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('class_members').snapshots(),
                builder: (context, membersSnapshot) {
                  // Contar estudiantes de las clases de este tutor
                  int studentCount = 0;
                  if (classesSnapshot.hasData && membersSnapshot.hasData) {
                    final classIds = classesSnapshot.data!.docs.map((d) => d.id).toSet();
                    studentCount = membersSnapshot.data!.docs
                        .where((m) => classIds.contains((m.data() as Map)['classId']))
                        .length;
                  }
                  return _StatCard(
                    icon: Icons.people_alt_rounded,
                    value: '$studentCount',
                    label: 'Estudiantes',
                    color: const Color(0xFF66BB6A),
                    delay: 0.1,
                    animation: _animController,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('game_units').snapshots(),
                builder: (context, unitsSnapshot) {
                  int unitCount = 0;
                  if (classesSnapshot.hasData && unitsSnapshot.hasData) {
                    final classIds = classesSnapshot.data!.docs.map((d) => d.id).toSet();
                    unitCount = unitsSnapshot.data!.docs
                        .where((u) => classIds.contains((u.data() as Map)['classId']))
                        .length;
                  }
                  return _StatCard(
                    icon: Icons.games_rounded,
                    value: '$unitCount',
                    label: 'Unidades',
                    color: const Color(0xFFFFC107),
                    delay: 0.2,
                    animation: _animController,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClassesList() {
    if (_tutorId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getTutorClasses(_tutorId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = snapshot.data?.docs ?? [];

        if (classes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.school_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No tienes clases aún',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea tu primera clase para comenzar',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        return Column(
          children: classes.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _ClassCard(
              classId: doc.id,
              data: data,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/class_detail',
                  arguments: {
                    'classId': doc.id,
                    'classData': data,
                    'isTutor': true,
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_circle_rounded,
            label: 'Nueva Clase',
            gradient: const [Color(0xFF4CAF50), Color(0xFF66BB6A)],
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/create_class',
                arguments: {'tutorId': _tutorId},
              );
              if (result == true) setState(() {});
            },
          ),
        ),

      ],
    );
  }

  Widget _buildActivityTypes() {
    final types = [
      {'icon': Icons.quiz_rounded, 'title': 'Quiz', 'color': const Color(0xFF42A5F5)},
      {'icon': Icons.link_rounded, 'title': 'Emparejar', 'color': const Color(0xFF66BB6A)},
      {'icon': Icons.psychology_rounded, 'title': 'Memoria', 'color': const Color(0xFFAB47BC)},
      {'icon': Icons.sort_rounded, 'title': 'Ordenar', 'color': const Color(0xFF26A69A)},
      {'icon': Icons.edit_note_rounded, 'title': 'Completar', 'color': const Color(0xFFFF7043)},
      {'icon': Icons.fact_check_rounded, 'title': 'Fake News', 'color': const Color(0xFFEC407A)},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: types.map((type) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: (type['color'] as Color).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (type['color'] as Color).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(type['icon'] as IconData, size: 18, color: type['color'] as Color),
              const SizedBox(width: 6),
              Text(
                type['title'] as String,
                style: TextStyle(
                  color: type['color'] as Color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final double delay;
  final AnimationController animation;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.delay,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = ((animation.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - progress)),
          child: Opacity(opacity: progress, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF132757),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final String classId;
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ClassCard({
    required this.classId,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF42A5F5),
      const Color(0xFF66BB6A),
      const Color(0xFFAB47BC),
      const Color(0xFFFF7043),
      const Color(0xFF26A69A),
    ];
    final color = colors[data['name'].toString().length % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'Clase',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF132757),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${data['studentCount'] ?? 0} estudiantes',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.key_outlined, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        data['code'] ?? '------',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
