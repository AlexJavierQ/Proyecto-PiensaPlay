import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';

class GameUnitsScreen extends StatelessWidget {
  const GameUnitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF132757), // Azul oscuro exacto
        elevation: 4,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Selecciona una Unidad',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.getGameUnits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay misiones disponibles.'));
          }

          final units = snapshot.data!.docs;
          
          // Buscar unidad en progreso para el botón superior
          Map<String, dynamic>? inProgressUnit;
          String? inProgressId;
          for (var doc in units) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['status'] == 'in_progress') {
              inProgressUnit = data;
              inProgressId = doc.id;
              break;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            children: [
              // Botón Continuar (Solo si hay una en progreso)
              if (inProgressUnit != null)
                _buildContinueButton(context, inProgressUnit, inProgressId!),

              const SizedBox(height: 10),

              // Lista de Unidades
              ...units.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _UnitCard(
                  title: data['title'] ?? 'Sin título',
                  subtitle: data['description'] ?? data['subtitle'] ?? '',
                  status: data['status'] ?? 'locked',
                  progress: (data['progress'] ?? 0.0).toDouble(),
                  onTap: data['status'] == 'locked'
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
          );
        },
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, Map<String, dynamic> unit, String id) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/game_detail', arguments: {'unitId': id, 'unitData': unit});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFA0E69D), // Verde claro del botón continuar
          borderRadius: BorderRadius.circular(15),
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
            Text(
              'Continuar: ${unit['title']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF132757),
              ),
            ),
            const Icon(Icons.play_arrow_rounded, color: Color(0xFF132757), size: 30),
          ],
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final double progress;
  final VoidCallback? onTap;

  const _UnitCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color themeColor;
    IconData iconData;
    
    // Configuración según el estado (basado en la imagen)
    if (status == 'completed') {
      themeColor = const Color(0xFFBDD87B); // Verde
      iconData = Icons.check_rounded;
    } else if (status == 'in_progress') {
      themeColor = const Color(0xFFF9879B); // Rosado/Rojizo
      iconData = Icons.access_time_filled_rounded;
    } else {
      themeColor = const Color(0xFFB4E4FF); // Celeste/Azul claro
      iconData = Icons.lock_open_rounded; // O lock_rounded según prefieras
    }

    final isLocked = status == 'locked';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: themeColor.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Círculo con Icono
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: themeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: const Color(0xFF132757), size: 35),
            ),
            const SizedBox(height: 16),
            // Título
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isLocked ? Colors.grey : const Color(0xFF132757),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Subtítulo
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isLocked ? Colors.grey : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Barra de Progreso (según la imagen)
            _buildProgressBar(themeColor, isLocked),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(Color color, bool isLocked) {
    return Container(
      width: 180, // Ancho específico como en la imagen
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: isLocked ? 0.3 : progress, // Valor de ejemplo o real
            child: Container(
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey[400] : color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
