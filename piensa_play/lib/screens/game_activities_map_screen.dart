import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/piensa_app_bar.dart';

class GameActivitiesMapScreen extends StatefulWidget {
  const GameActivitiesMapScreen({super.key});

  @override
  State<GameActivitiesMapScreen> createState() => _GameActivitiesMapScreenState();
}

class _GameActivitiesMapScreenState extends State<GameActivitiesMapScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userData = await LocalStorageService.getUserData();
    if (mounted) {
      setState(() {
        _userId = userData?['userId'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final unitData = args['unitData'] as Map<String, dynamic>;
    final unitId = args['unitId'] as String?;
    
    if (unitId == null || _userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F0),
      appBar: PiensaAppBar(title: unitData['title'] ?? 'Mapa de Actividades'),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.getUnitActivities(unitId),
          builder: (context, activitySnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getUserProgress(_userId!),
              builder: (context, progressSnapshot) {
                if (activitySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<QueryDocumentSnapshot> activityDocs = activitySnapshot.data?.docs ?? [];
                
                if (activityDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay actividades creadas para esta unidad.\nEl profesor debe agregarlas desde el panel.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  );
                }

                final List<QueryDocumentSnapshot> progressDocs = progressSnapshot.data?.docs ?? [];
                
                final completedIds = progressDocs
                    .where((doc) => (doc.data() as Map<String, dynamic>)['completed'] == true)
                    .map((doc) => (doc.data() as Map<String, dynamic>)['activityId'])
                    .toSet();

                List<Map<String, dynamic>> activities = [];
                for (int i = 0; i < activityDocs.length; i++) {
                  final data = activityDocs[i].data() as Map<String, dynamic>;
                  final id = activityDocs[i].id;
                  bool isCompleted = completedIds.contains(id);
                  bool isLocked = i == 0 ? false : !completedIds.contains(activityDocs[i-1].id);
                  
                  activities.add({
                    ...data,
                    'id': id,
                    'isCompleted': isCompleted,
                    'status': isLocked ? 'locked' : 'available',
                  });
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            _buildMapHeader(context, unitId, unitData, activities),
                            const SizedBox(height: 24),
                            _buildSectionTitle(),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: activities.map((act) => _buildActivityCard(context, act, unitId, unitData)).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            );
          }
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  void _onPlayActivity(BuildContext context, String? unitId, Map<String, dynamic> unitData, Map<String, dynamic> activity) {
    String route = '/game_play';
    final type = activity['type'];
    if (type == 'fake_news_detector') route = '/fake_news_detector';
    else if (type == 'stereotype_breaker') route = '/stereotype_breaker';
    else if (type == 'final_exam') route = '/final_exam';

    Navigator.pushNamed(context, route, arguments: {
      'unitId': unitId,
      'unitData': unitData,
      'activityData': activity,
    });
  }

  Widget _buildMapHeader(BuildContext context, String? unitId, Map<String, dynamic> unitData, List<Map<String, dynamic>> activities) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Altura proporcional o fija pero segura
        final height = 350.0; 
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.black, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/background_map.png'), 
                    fit: BoxFit.cover, 
                    opacity: 0.8
                  ),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Stack(
                  children: [
                    // Puntos posicionados con Alignment relativo (x, y) donde 0,0 es centro
                    // x va de -1 (izq) a 1 (der), y va de -1 (arriba) a 1 (abajo)
                    if (activities.isNotEmpty)
                      _buildResponsiveMapPoint(
                        alignment: const Alignment(-0.6, -0.7), // Arriba Izquierda
                        color: Color(activities[0]['color'] ?? 0xFFF9879B),
                        number: '1',
                        icon: activities[0]['isCompleted'] == true ? Icons.check_rounded : _getIconData(activities[0]['icon']),
                        onTap: activities[0]['status'] == 'locked' ? null : () => _onPlayActivity(context, unitId, unitData, activities[0]),
                      ),
                    if (activities.length > 1)
                      _buildResponsiveMapPoint(
                        alignment: const Alignment(0.6, -0.2), // Medio Derecha
                        color: Color(activities[1]['color'] ?? 0xFF87CEEB),
                        number: '2',
                        icon: activities[1]['isCompleted'] == true ? Icons.check_rounded : _getIconData(activities[1]['icon']),
                        onTap: activities[1]['status'] == 'locked' ? null : () => _onPlayActivity(context, unitId, unitData, activities[1]),
                      ),
                    if (activities.length > 2)
                      _buildResponsiveMapPoint(
                        alignment: const Alignment(-0.5, 0.3), // Medio Abajo Izquierda
                        color: Color(activities[2]['color'] ?? 0xFFBDBDBD),
                        number: '3',
                        icon: activities[2]['isCompleted'] == true ? Icons.check_rounded : _getIconData(activities[2]['icon']),
                        onTap: activities[2]['status'] == 'locked' ? null : () => _onPlayActivity(context, unitId, unitData, activities[2]),
                      ),
                    if (activities.length > 3)
                      _buildResponsiveMapPoint(
                        alignment: const Alignment(0.5, 0.8), // Abajo Derecha
                        color: Color(activities[3]['color'] ?? 0xFFBDBDBD),
                        number: '4',
                        icon: activities[3]['isCompleted'] == true ? Icons.check_rounded : _getIconData(activities[3]['icon']),
                        onTap: activities[3]['status'] == 'locked' ? null : () => _onPlayActivity(context, unitId, unitData, activities[3]),
                      ),
                  ],
                ),
              ),
              Positioned(
                top: -20, 
                right: -10, 
                child: Image.asset('assets/image-removebg-preview 1.png', width: 100, height: 100, fit: BoxFit.contain)
              ),
            ],
          ),
        );
      }
    );
  }

  IconData _getIconData(dynamic iconName) {
    if (iconName is IconData) return iconName;
    switch (iconName.toString()) {
      case 'book': return Icons.book_rounded;
      case 'extension': return Icons.extension_rounded;
      case 'lock': return Icons.lock_rounded;
      default: return Icons.videogame_asset_rounded;
    }
  }

  Widget _buildResponsiveMapPoint({
    required Alignment alignment, 
    required Color color, 
    required String number, 
    required IconData icon, 
    VoidCallback? onTap
  }) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.8), 
                shape: BoxShape.circle, 
                border: Border.all(color: Colors.black, width: 2)
              ),
              child: Center(child: Icon(icon, color: Colors.white, size: 24)),
            ),
            Positioned(
              top: -5, right: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6E16B), 
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.black, width: 1)
                ),
                child: Text(number, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ACTIVIDADES DISPONIBLES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF333333))),
          Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFF6E16B), shape: BoxShape.circle), child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 24)),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Map<String, dynamic> act, String? unitId, Map<String, dynamic> unitData) {
    final bool isLocked = act['status'] == 'locked';
    final bool isCompleted = act['isCompleted'] == true;
    final colorVal = act['color'] is int ? act['color'] : 0xFFF6E16B;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFFA0E69D) : Color(colorVal),
                shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2),
              ),
              child: Icon(isCompleted ? Icons.check_rounded : _getIconData(act['icon']), color: isLocked ? Colors.white60 : Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(act['title'] ?? 'Actividad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isLocked ? Colors.grey : Colors.black)),
                  const SizedBox(height: 4),
                  Text(isLocked ? '¡Completa la anterior para jugar!' : (isCompleted ? '¡Completada!' : act['subtitle'] ?? ''), 
                  style: TextStyle(fontSize: 13, color: isLocked ? Colors.grey : Colors.black54, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            GestureDetector(
              onTap: isLocked ? null : () => _onPlayActivity(context, unitId, unitData, act),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey[400] : (isCompleted ? const Color(0xFFA0E69D) : const Color(0xFFF6E16B)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  isLocked ? 'Bloqueado' : (isCompleted ? 'Repetir' : 'Jugar'),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return const CustomBottomNav(currentIndex: 0);
  }
}
