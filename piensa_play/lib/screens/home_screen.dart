import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class HomeScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final int avatarIndex;
  final String userTag;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.avatarIndex,
    required this.userTag,
  });

  @override
  Widget build(BuildContext context) {
    // Extract arguments from route if provided
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final displayUserId = args?['userId'] ?? userId;
    final displayUserName = args?['userName'] ?? userName;
    final displayAvatarIndex = args?['avatarIndex'] ?? avatarIndex;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Image.asset(
                'assets/Vector.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                '¡Hola, $displayUserName!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Nueva misión card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6E16B),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0,6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¡Nueva misión!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('¡Aprende algo nuevo cada día!'),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Empezar'),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Juegos educativos
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/game_units');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6F6C8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0,6)),
                  ],
                ),
                child: Row(
                  children: const [
                    CircleAvatar(backgroundColor: AppStyles.primaryBlue, child: Icon(Icons.apps, color: Colors.white)),
                    SizedBox(width: 12),
                    Text('Juegos Educativos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mi Progreso
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/progress',
                  arguments: {
                    'userId': displayUserId,
                    'userName': displayUserName,
                    'avatarIndex': displayAvatarIndex,
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9C0D0),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0,6)),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.bar_chart, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Mi Progreso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Progress Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0,6)),
                ],
              ),
              child: Column(
                children: [
                  const Text('Tu Avance General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: 0.7,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                        ),
                      ),
                      const Text('70%\nCompletado', textAlign: TextAlign.center),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Actividad Semanal', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildProgressRow('Lun', 0.3, Colors.lightGreen),
                  _buildProgressRow('Mar', 0.5, Colors.yellow),
                  _buildProgressRow('Mié', 0.7, Colors.lightGreenAccent),
                  _buildProgressRow('Jue', 0.4, Colors.pinkAccent),
                  _buildProgressRow('Vie', 0.8, Colors.lightBlueAccent),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppStyles.primaryBlue,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const _NavItem(icon: Icons.home, label: 'Inicio'),
            _NavItem(
              icon: Icons.menu_book,
              label: 'Glosario',
              onTap: () {
                Navigator.pushNamed(context, '/glossary');
              },
            ),
            _NavItem(
              icon: Icons.settings,
              label: 'Ajustes',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/settings',
                  arguments: {
                    'userId': displayUserId,
                    'userName': displayUserName,
                    'avatarIndex': displayAvatarIndex,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(width: 36, child: Text(label)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              color: color,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 40, child: Text('${(value * 100).round()}%')),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _NavItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 6),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
