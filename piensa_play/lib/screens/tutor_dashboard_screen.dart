import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class TutorDashboardScreen extends StatelessWidget {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        title: const Text(
          'Panel del Tutor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido, Tutor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppStyles.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '¿Qué deseas hacer hoy?',
              style: TextStyle(
                fontSize: 16,
                color: AppStyles.textLight,
              ),
            ),
            const SizedBox(height: 32),
            _DashboardCard(
              icon: Icons.menu_book,
              title: 'Gestionar Glosario',
              description: 'Agrega, edita o elimina términos del glosario.',
              color: AppStyles.lightGreen,
              onTap: () {
                Navigator.pushNamed(context, '/manage_glossary');
              },
            ),
            const SizedBox(height: 16),
            _DashboardCard(
              icon: Icons.games,
              title: 'Gestionar Juegos',
              description: 'Crea y administra unidades de juegos educativos.',
              color: const Color(0xFFFFD700),
              onTap: () {
                Navigator.pushNamed(context, '/manage_games');
              },
            ),
            // Add more cards here for future features (e.g., Manage Activities)
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: AppStyles.primaryBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppStyles.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppStyles.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppStyles.textLight),
          ],
        ),
      ),
    );
  }
}
