import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';

class GameUnitsScreen extends StatefulWidget {
  const GameUnitsScreen({super.key});

  @override
  State<GameUnitsScreen> createState() => _GameUnitsScreenState();
}

class _GameUnitsScreenState extends State<GameUnitsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }
  
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header personalizado
            _buildHeader(context),
            
            // Contenido principal
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.getGameUnits(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF132757)),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final units = snapshot.data!.docs;
                  return _buildMissionsList(units);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF132757),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132757).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de regreso
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded, 
                color: Colors.white, 
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Título con ícono
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppStyles.yellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    color: AppStyles.yellow,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mapa de Misiones',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Elige tu próxima aventura',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off_rounded,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay misiones disponibles',
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pronto habrá nuevas aventuras',
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsList(List<QueryDocumentSnapshot> units) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final doc = units[index];
        final data = doc.data() as Map<String, dynamic>;
        final isLast = index == units.length - 1;
        
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final delay = index * 0.2;
            final progress = ((_animController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
            
            return Transform.translate(
              offset: Offset(50 * (1 - progress), 0),
              child: Opacity(
                opacity: progress,
                child: child,
              ),
            );
          },
          child: _MissionTile(
            index: index + 1,
            title: data['title'] ?? 'Sin título',
            description: data['description'] ?? data['subtitle'] ?? '',
            status: data['status'] ?? 'locked',
            progress: (data['progress'] ?? 0.0).toDouble(),
            isLast: isLast,
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
          ),
        );
      },
    );
  }
}

class _MissionTile extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final String status;
  final double progress;
  final bool isLast;
  final VoidCallback? onTap;

  const _MissionTile({
    required this.index,
    required this.title,
    required this.description,
    required this.status,
    required this.progress,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = status == 'locked';
    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';
    
    // Colores según estado
    Color accentColor;
    IconData statusIcon;
    String statusLabel;
    
    if (isCompleted) {
      accentColor = const Color(0xFF4ADE80); // Verde brillante
      statusIcon = Icons.check_circle_rounded;
      statusLabel = '¡Completado!';
    } else if (isInProgress) {
      accentColor = const Color(0xFFFBBF24); // Amarillo
      statusIcon = Icons.play_circle_rounded;
      statusLabel = 'En progreso';
    } else {
      accentColor = const Color(0xFF94A3B8); // Gris
      statusIcon = Icons.lock_rounded;
      statusLabel = 'Bloqueado';
    }

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda: Número y línea conectora
                Column(
                  children: [
                    // Número de misión
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: isLocked 
                            ? null 
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  accentColor,
                                  accentColor.withValues(alpha: 0.7),
                                ],
                              ),
                        color: isLocked ? const Color(0xFFE2E8F0) : null,
                        shape: BoxShape.circle,
                        border: isInProgress 
                            ? Border.all(color: const Color(0xFF132757), width: 3)
                            : null,
                        boxShadow: isLocked ? null : [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isCompleted 
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                            : Text(
                                '$index',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: isLocked ? Colors.grey : Colors.white,
                                ),
                              ),
                      ),
                    ),
                    // Línea conectora
                    if (!isLast)
                      Container(
                        width: 3,
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accentColor.withValues(alpha: 0.6),
                              const Color(0xFFE2E8F0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Tarjeta de contenido
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isInProgress 
                          ? Border.all(color: accentColor, width: 2)
                          : Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila superior: título y estado
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: isLocked 
                                      ? Colors.grey[400] 
                                      : const Color(0xFF132757),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, 
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, size: 14, color: accentColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Descripción
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: isLocked ? Colors.grey[400] : Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Barra de progreso o botón de acción
                        if (isInProgress || isCompleted)
                          _buildProgressSection(accentColor)
                        else if (isLocked)
                          _buildLockedSection()
                        else
                          _buildStartButton(accentColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(Color color) {
    final progressPercent = (progress * 100).toInt();
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$progressPercent%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        if (status == 'in_progress') ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'CONTINUAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLockedSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Completa la misión anterior',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(Color color) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              '¡COMENZAR!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
