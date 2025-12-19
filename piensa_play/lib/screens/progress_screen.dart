import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firebase_service.dart';
import '../widgets/custom_bottom_nav.dart';

class ProgressScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // EXTRAER ARGUMENTOS CON LLAVES NORMALIZADAS
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // Prioridad: 1. Argumentos de navegación, 2. Persistencia local (si existiera), 3. Valor del constructor
    final String displayUserId = args?['userId'] ?? userId;
    final String displayUserName = args?['userName'] ?? userName;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF132757),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
              
              for (var doc in progressDocs) {
                final data = doc.data() as Map<String, dynamic>;
                totalXP += (data['score'] as num? ?? 0).toInt();
              }

              return ListView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildProfileHeader(displayUserName, totalXP),
                  const SizedBox(height: 32),
                  _buildGeneralProgressCard(completedActivities),
                  const SizedBox(height: 32),
                  _buildBadgesSection(completedActivities),
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
        boxShadow: [BoxShadow(color: const Color(0xFF132757).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
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

  Widget _buildBadgesSection(int completed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tus Insignias', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF132757))),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildBadgeItem(Icons.search, 'Detective', completed >= 1),
            _buildBadgeItem(Icons.verified_user_rounded, 'Veraz', completed >= 2),
            _buildBadgeItem(Icons.shield_rounded, 'Guardián', completed >= 3),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeItem(IconData icon, String label, bool unlocked) {
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: unlocked ? const Color(0xFFF6E16B) : Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(color: unlocked ? const Color(0xFF132757) : Colors.transparent, width: 2),
          ),
          child: Icon(icon, color: unlocked ? const Color(0xFF132757) : Colors.grey[400], size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: unlocked ? const Color(0xFF132757) : Colors.grey), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildRecentActivities(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Historial de Juegos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF132757))),
        const SizedBox(height: 16),
        ...docs.take(5).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFA0E69D)),
                const SizedBox(width: 16),
                const Expanded(child: Text('Misión Completada', style: TextStyle(fontWeight: FontWeight.bold))),
                Text('+${data['score']} XP', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
