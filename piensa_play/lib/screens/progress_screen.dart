import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Mi Progreso', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            Text('¡Hola!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppStyles.primaryBlue,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFC9E090), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Tu Avance General',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Circular Progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: 0.75,
                        strokeWidth: 16,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC9E090)),
                      ),
                    ),
                    const Text(
                      '75%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Nivel Actual:', '3', const Color(0xFFF6E16B)),
                    _buildStat('Total XP:', '1250', Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Monedas: ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      '5',
                      style: TextStyle(fontSize: 18, color: Color(0xFFF6E16B), fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Color(0xFF6DD5FA), size: 28),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Insignias Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC9E090), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Insignias',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryBlue,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildBadge(Icons.search, 'Investigador\nJunior', true),
                    _buildBadge(Icons.lock, 'Maestro\nde Contraseñas', true),
                    _buildBadge(Icons.shield, 'Guardian Digital', false),
                    _buildBadge(Icons.chat_bubble, 'Detector\nde Spam', true),
                    _buildBadge(Icons.explore, 'Navegante\nExperto', false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actividades Recientes
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6DD5FA), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actividades Recientes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActivity(
                  Icons.lock,
                  'Crea una contraseña\nsegura',
                  '+ 50 XP',
                  true,
                  const Color(0xFFC9E090),
                ),
                const SizedBox(height: 12),
                _buildActivity(
                  Icons.article,
                  'Detector de Fake\nNews',
                  '+ 75 XP',
                  true,
                  const Color(0xFFC9E090),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label, bool unlocked) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: unlocked ? const Color(0xFFC9E090) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unlocked ? const Color(0xFF10B981) : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  icon,
                  size: 32,
                  color: unlocked ? AppStyles.primaryBlue : Colors.grey.shade500,
                ),
              ),
              if (unlocked)
                const Positioned(
                  top: 2,
                  right: 2,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: AppStyles.primaryBlue,
                    child: Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: unlocked ? AppStyles.primaryBlue : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActivity(IconData icon, String title, String xp, bool completed, Color iconBg) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppStyles.primaryBlue, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: AppStyles.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          xp,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF10B981),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        if (completed)
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
      ],
    );
  }
}
