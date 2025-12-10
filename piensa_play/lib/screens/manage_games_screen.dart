import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';

class ManageGamesScreen extends StatelessWidget {
  const ManageGamesScreen({super.key});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'favorite': return Icons.favorite;
      case 'security': return Icons.security;
      case 'verified_user': return Icons.verified_user;
      case 'games': return Icons.games;
      case 'school': return Icons.school;
      case 'psychology': return Icons.psychology;
      default: return Icons.apps;
    }
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse('0xFF${hexColor.substring(1)}'));
    } catch (e) {
      return AppStyles.lightGreen;
    }
  }

  Future<void> _deleteUnit(BuildContext context, String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseService.deleteGameUnit(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unidad eliminada correctamente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        title: const Text(
          'Gestionar Juegos',
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.games, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay unidades de juegos aún.',
                    style: TextStyle(fontSize: 16, color: AppStyles.textLight),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Presiona + para crear una nueva unidad',
                    style: TextStyle(fontSize: 14, color: AppStyles.textLight),
                  ),
                ],
              ),
            );
          }

          final units = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: units.length,
            itemBuilder: (context, index) {
              final doc = units[index];
              final data = doc.data() as Map<String, dynamic>;
              final games = (data['games'] as List?)?.length ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getColorFromHex(data['color'] ?? '#C9E090'),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(data['icon'] ?? 'apps'),
                      color: AppStyles.primaryBlue,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    data['title'] ?? 'Sin título',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppStyles.primaryBlue,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        data['subtitle'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppStyles.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$games juego${games != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteUnit(context, doc.id, data['title'] ?? 'Unidad');
                      } else if (value == 'edit') {
                        Navigator.pushNamed(
                          context,
                          '/create_game_unit',
                          arguments: {'unitId': doc.id, 'unitData': data},
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create_game_unit');
        },
        backgroundColor: AppStyles.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Unidad',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
