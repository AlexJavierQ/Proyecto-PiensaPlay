import 'package:flutter/material.dart';
import '../utils/local_storage_service.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  
  const CustomBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) async {
    if (index == currentIndex) return;

    final userData = await LocalStorageService.getUserData();
    if (!context.mounted) return;

    String route = '/home';
    switch (index) {
      case 0: route = '/home'; break;
      case 1: route = '/glossary'; break;
      case 2: route = '/progress'; break;
      case 3: route = '/settings'; break;
    }

    // USAMOS PUSH REPLACEMENT para no acumular pantallas en memoria
    // y pasamos los argumentos necesarios para que Firebase no falle.
    Navigator.pushReplacementNamed(
      context, 
      route, 
      arguments: userData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF132757),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5)),
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
    final Color color = isActive ? const Color(0xFFF6E16B) : Colors.white.withOpacity(0.5);
    
    return InkWell(
      onTap: () => _onTap(context, index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
