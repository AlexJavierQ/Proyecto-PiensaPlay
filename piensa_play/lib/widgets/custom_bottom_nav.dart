import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../utils/local_storage_service.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  
  const CustomBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) async {
    if (index == currentIndex) return;

    final userData = await LocalStorageService.getUserData();
    if (!context.mounted) return;

    // Si no hay usuario guardado, redirigir al login
    if (userData == null || userData['userId'] == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      return;
    }

    String route;
    switch (index) {
      case 0:
        route = '/home';
        break;
      case 1:
        route = '/glossary';
        break;
      case 2:
        route = '/progress';
        break;
      case 3:
        route = '/settings';
        break;
      default:
        route = '/home';
    }

    Navigator.pushReplacementNamed(
      context, 
      route, 
      arguments: {
        'userId': userData['userId'],
        'userName': userData['userName'],
        'avatarIndex': int.tryParse(userData['userAvatar'] ?? '0') ?? 0,
        'userTag': userData['userName']?.split('#').last ?? '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF132757), Color(0xFF1E3A8A)],
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132757).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(context, 0, Icons.home_rounded, 'Inicio'),
          _buildItem(context, 1, Icons.auto_stories_rounded, 'Glosario'),
          _buildItem(context, 2, Icons.emoji_events_rounded, 'Progreso'),
          _buildItem(context, 3, Icons.person_rounded, 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, IconData icon, String label) {
    final bool isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: isActive
            ? BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isActive ? AppStyles.yellow : Colors.white.withValues(alpha: 0.5),
                size: isActive ? 28 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? AppStyles.yellow : Colors.white.withValues(alpha: 0.5),
                fontSize: isActive ? 11 : 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

