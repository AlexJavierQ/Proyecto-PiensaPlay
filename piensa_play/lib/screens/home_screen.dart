import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/piensa_app_bar.dart';

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
    final List<String> avatarImages = [
      'assets/Vector.png',
      'assets/Vector (2).png',
      'assets/Vector (3).png',
      'assets/Vector (4).png',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: PiensaAppBar(
        title: 'PiensaPlay',
        showBackButton: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(avatarImages[avatarIndex % avatarImages.length]),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroActionCard(context),
            const SizedBox(height: 32),
            const Text(
              'Tus Misiones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF132757),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildMenuCard(
                  context,
                  title: 'Juegos',
                  subtitle: '¡A jugar!',
                  icon: Icons.videogame_asset_rounded,
                  color: const Color(0xFFBDD87B),
                  route: '/game_units',
                ),
                _buildMenuCard(
                  context,
                  title: 'Glosario',
                  subtitle: 'Palabras mágicas',
                  icon: Icons.auto_stories_rounded,
                  color: const Color(0xFFFFD700),
                  route: '/glossary',
                ),
                _buildMenuCard(
                  context,
                  title: 'Mi Progreso',
                  subtitle: 'Tus trofeos',
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFFF9C0D0),
                  route: '/progress',
                ),
                _buildMenuCard(
                  context,
                  title: 'Ajustes',
                  subtitle: 'Tu perfil',
                  icon: Icons.settings_rounded,
                  color: const Color(0xFF93C5FD),
                  route: '/settings',
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeroActionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132757).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFF6E16B), width: 3),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset('assets/image-removebg-preview 1.png', width: 60, height: 60),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIGUIENTE MISIÓN:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey),
                    ),
                    Text(
                      'Detective de Noticias',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF132757)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/game_units'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBDD87B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text(
                '¡CONTINUAR AVENTURA!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF132757), letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF132757)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF132757)),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF132757).withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
