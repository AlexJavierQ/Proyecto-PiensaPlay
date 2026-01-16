import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/widgets.dart';

class ProgressScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final int avatarIndex;

  const ProgressScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.avatarIndex,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _showAllBadges = false;
  bool _showAllHistory = false;

  @override
  Widget build(BuildContext context) {
    // EXTRAER ARGUMENTOS CON LLAVES NORMALIZADAS
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // Prioridad: 1. Argumentos de navegación, 2. Persistencia local (si existiera), 3. Valor del constructor
    final String displayUserId = args?['userId'] ?? widget.userId;
    final String displayUserName = args?['userName'] ?? widget.userName;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF132757),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Mi Progreso', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: (displayUserId == 'temp' || displayUserId.isEmpty)
        ? _buildNoUserError()
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.getUserProgress(displayUserId),
            builder: (context, snapshot) {
              // MANEJO DE ERRORES PARA EVITAR PANTALLA NEGRA
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF132757)));
              }

              final progressDocs = snapshot.data?.docs ?? [];
              
              int totalXP = 0;
              int completedActivities = progressDocs.length;
              Set<String> completedTypes = {};
              
              for (var doc in progressDocs) {
                final data = doc.data() as Map<String, dynamic>;
                totalXP += (data['score'] as num? ?? 0).toInt();
                
                if (data['type'] != null) {
                  completedTypes.add(data['type']);
                }
              }

              return ListView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildProfileHeader(displayUserName, totalXP),
                  const SizedBox(height: 32),
                  _buildGeneralProgressCard(completedActivities),
                  const SizedBox(height: 32),
                  _buildBadgesSection(completedActivities, totalXP, completedTypes),
                  const SizedBox(height: 32),
                  _buildRecentActivities(progressDocs),
                ],
              );
            },
          ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _buildNoUserError() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_off_rounded, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No se encontró información del usuario.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text('Error de conexión: $error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, int xp) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFBDD87B),
          child: Icon(Icons.person, size: 60, color: Color(0xFF132757)),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF132757)),
        ),
        Text(
          '¡Tienes $xp puntos de experiencia!',
          style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGeneralProgressCard(int completed) {
    double percent = (completed / 12).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF132757),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: const Color(0xFF132757).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Text('Avance de la Aventura', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120, height: 120,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 12,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA0E69D)),
                ),
              ),
              Text('${(percent * 100).toInt()}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallStat('Completadas', '$completed'),
              _buildSmallStat('Misiones', '1/3'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBadgesSection(int completed, int totalPoints, Set<String> completedTypes) {
    // Calcular logros totales
    final allAchievements = PiensaPlayAchievements.getAll(
      completedActivities: completed,
      totalPoints: totalPoints,
      completedTypes: completedTypes,
    );
    
    // Ordenar: Desbloqueadas primero
    allAchievements.sort((a, b) {
      if (a.isUnlocked && !b.isUnlocked) return -1;
      if (!a.isUnlocked && b.isUnlocked) return 1;
      return 0;
    });

    // Definir cuántas y cómo mostrar
    final displayedAchievements = _showAllBadges 
        ? allAchievements 
        : allAchievements.take(4).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tus Insignias', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF132757))),
            if (allAchievements.length > 4)
              TextButton(
                onPressed: () => setState(() => _showAllBadges = !_showAllBadges),
                child: Text(
                  _showAllBadges ? 'Ver menos' : 'Ver todas',
                  style: TextStyle(color: AppStyles.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        AchievementsGrid(
          achievements: displayedAchievements,
          // Si está colapsado mostramos 2 columnas (para que 4 queden 2x2). Si expandido, 3.
          crossAxisCount: _showAllBadges ? 3 : 2, 
        ),
      ],
    );
  }

  Widget _buildRecentActivities(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return const SizedBox.shrink();
    
    final displayedDocs = _showAllHistory ? docs : docs.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Historial de Juegos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF132757))),
            if (docs.length > 3)
              TextButton(
                onPressed: () => setState(() => _showAllHistory = !_showAllHistory),
                child: Text(
                  _showAllHistory ? 'Ver menos' : 'Ver más',
                  style: TextStyle(color: AppStyles.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...displayedDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFA0E69D)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Misión Completada', style: TextStyle(fontWeight: FontWeight.bold)),
                      if (timestamp != null)
                        Text(
                          '${timestamp.day}/${timestamp.month}/${timestamp.year}',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                        ),
                    ],
                  ),
                ),
                Text('+${data['score']} XP', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
