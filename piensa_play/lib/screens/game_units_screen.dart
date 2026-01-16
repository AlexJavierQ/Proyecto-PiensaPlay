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
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getGameUnits(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }
                
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Usamos el mismo azul vibrante por defecto de las clases (Material Blue 400)
    // para que sea IDENTICO a la imagen de referencia.
    const headerColor = Color(0xFF42A5F5); 
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [headerColor, headerColor.withValues(alpha: 0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: headerColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mundo Abierto',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Exploración y aventuras libres',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final doc = units[index];
        final data = doc.data() as Map<String, dynamic>;
        
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final delay = index * 0.15;
            final progress = ((_animController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
            
            return Transform.translate(
              offset: Offset(0, 50 * (1 - progress)),
              child: Opacity(
                opacity: progress,
                child: child,
              ),
            );
          },
          child: _MissionTile(
            index: index,
            title: data['title'] ?? 'Misión #${index + 1}',
            description: data['description'] ?? data['subtitle'] ?? '¡Prepárate para esta aventura!',
            status: data['status'] ?? 'available',
            progress: (data['progress'] ?? 0.0).toDouble(),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/game_activities_map',
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
  final VoidCallback? onTap;

  const _MissionTile({
    required this.index,
    required this.title,
    required this.description,
    required this.status,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = status == 'locked';
    final isCompleted = status == 'completed';
    
    // Paleta de colores rotativa
    final colors = [
      const Color(0xFF42A5F5), // Azul
      const Color(0xFF66BB6A), // Verde
      const Color(0xFFAB47BC), // Morado
      const Color(0xFFFF7043), // Naranja
      const Color(0xFF26A69A), // Teal
      const Color(0xFFEF5350), // Rojo
    ];
    
    final color = isLocked ? Colors.grey : colors[index % colors.length];
    final textColor = isLocked ? Colors.grey[400] : const Color(0xFF132757);

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // Header de la tarjeta
              Container(
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLocked 
                        ? [Colors.grey[300]!, Colors.grey[400]!]
                        : [color, color.withValues(alpha: 0.8)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Patrón de fondo
                    Positioned(
                      right: -10,
                      top: -20,
                      child: Icon(
                        Icons.videogame_asset_rounded,
                        size: 100,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    // Etiqueta de Nivel
                    Positioned(
                      left: 20,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'NIVEL ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Icono de estado
                    Positioned(
                      right: 20,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isLocked ? Icons.lock_rounded : (isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Cuerpo de la tarjeta
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    
                    // Barra de progreso y botón
                    if (isLocked)
                       Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text(
                            'Completa el nivel anterior',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    else 
                      Column(
                        children: [
                          // Barra de progreso
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    backgroundColor: Colors.grey[100],
                                    valueColor: AlwaysStoppedAnimation(color),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
