import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';

class GameUnitsScreen extends StatelessWidget {
  const GameUnitsScreen({super.key});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'check_circle': return Icons.check_circle;
      case 'access_time': return Icons.access_time;
      case 'lock': return Icons.lock;
      case 'favorite': return Icons.favorite;
      case 'security': return Icons.security;
      case 'verified_user': return Icons.verified_user;
      default: return Icons.apps;
    }
  }

  Color _getBorderColor(String status) {
    switch (status) {
      case 'completed': return const Color(0xFFC9E090); // Verde claro
      case 'in_progress': return const Color(0xFFFFB6C1); // Rosa
      case 'locked': return const Color(0xFFB0C4DE); // Azul claro
      default: return Colors.grey;
    }
  }

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
        title: const Text(
          'Selecciona una Unidad',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.getGameUnits(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay unidades disponibles aún.',
                style: TextStyle(fontSize: 16, color: AppStyles.textLight),
              ),
            );
          }

          final units = snapshot.data!.docs;
          
          // Find the last in-progress or first locked unit
          String? continueUnitTitle;
          for (var unit in units) {
            final data = unit.data() as Map<String, dynamic>;
            if (data['status'] == 'in_progress') {
              continueUnitTitle = data['title'];
              break;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Continue button
                if (continueUnitTitle != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9E090),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Continuar: $continueUnitTitle',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppStyles.primaryBlue,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.play_arrow,
                          color: AppStyles.primaryBlue,
                          size: 28,
                        ),
                      ],
                    ),
                  ),

                // Units list
                ...units.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'locked';
                  
                  return _UnitCard(
                    title: data['title'] ?? 'Sin título',
                    subtitle: data['subtitle'] ?? '',
                    icon: _getIcon(data['icon'] ?? 'apps'),
                    status: status,
                    borderColor: _getBorderColor(status),
                    onTap: status == 'locked'
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              '/game_detail',
                              arguments: {
                                'unitId': doc.id,
                                'unitData': data,
                              },
                            );
                          },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String status;
  final Color borderColor;
  final VoidCallback? onTap;

  const _UnitCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.borderColor,
    this.onTap,
  });

  IconData _getStatusIcon() {
    switch (status) {
      case 'completed': return Icons.check_circle;
      case 'in_progress': return Icons.access_time;
      case 'locked': return Icons.lock;
      default: return Icons.circle_outlined;
    }
  }

  Color _getBackgroundColor() {
    switch (status) {
      case 'completed': return const Color(0xFFC9E090);
      case 'in_progress': return const Color(0xFFFFB6C1);
      case 'locked': return const Color(0xFFB0C4DE);
      default: return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(),
                size: 40,
                color: AppStyles.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppStyles.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppStyles.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
