import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';

class StereotypeBreakerScreen extends StatefulWidget {
  const StereotypeBreakerScreen({super.key});

  @override
  State<StereotypeBreakerScreen> createState() => _StereotypeBreakerScreenState();
}

class _StereotypeBreakerScreenState extends State<StereotypeBreakerScreen> {
  final Set<int> _selectedIndexes = {};
  bool _isFinished = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final unitData = args?['unitData'] as Map<String, dynamic>? ?? {};
    final activityData = args?['activityData'] as Map<String, dynamic>? ?? {};
    final String unitId = args?['unitId'] ?? '';

    // Datos dinámicos de Firebase (con fallbacks)
    final String instructions = activityData['instructions'] ?? 'Observa las escenas y toca las que muestran estereotipos para romperlos.';
    final List<dynamic> scenarios = activityData['scenarios'] ?? [
      {'title': 'Los niños no lloran', 'isStereotype': true, 'icon': Icons.face_retouching_off},
      {'title': 'Las niñas son mejores en cocina', 'isStereotype': true, 'icon': Icons.soup_kitchen},
      {'title': 'Todos pueden ser astronautas', 'isStereotype': false, 'icon': Icons.rocket_launch},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF132757),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(unitData['title'] ?? 'Zona Cero Odio', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSubHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildInstructionsBox(instructions),
                  const SizedBox(height: 24),
                  const Text('Toca para seleccionar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF132757))),
                  const SizedBox(height: 20),
                  ...scenarios.asMap().entries.map((entry) => _buildScenarioCard(entry.key, entry.value)).toList(),
                ],
              ),
            ),
          ),
          _buildFinishButton(scenarios, unitData, activityData, unitId),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF132757),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text('Las Gafas de la AMI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF132757))),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsBox(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFA0E69D), width: 1.5)),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF132757), height: 1.4, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
    );
  }

  Widget _buildScenarioCard(int index, Map<String, dynamic> data) {
    final bool isSelected = _selectedIndexes.contains(index);
    return GestureDetector(
      onTap: () => setState(() => isSelected ? _selectedIndexes.remove(index) : _selectedIndexes.add(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB4E4FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade200, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(data['icon'] ?? Icons.extension_rounded, color: isSelected ? const Color(0xFF132757) : Colors.grey, size: 30),
            const SizedBox(width: 16),
            Expanded(child: Text(data['title'] ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isSelected ? const Color(0xFF132757) : Colors.black87))),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF132757)),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishButton(List<dynamic> scenarios, Map<String, dynamic> unitData, Map<String, dynamic> activityData, String unitId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _selectedIndexes.isEmpty || _isFinished ? null : () => _onFinish(scenarios, unitData, activityData, unitId),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF132757),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: const Text('¡Terminar Actividad!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _onFinish(List<dynamic> scenarios, Map<String, dynamic> unitData, Map<String, dynamic> activityData, String unitId) async {
    setState(() => _isFinished = true);
    
    int correctCount = 0;
    int incorrectCount = 0;

    // Lógica de validación
    for (int i = 0; i < scenarios.length; i++) {
      final bool isStereotype = scenarios[i]['isStereotype'] ?? false;
      final bool isSelected = _selectedIndexes.contains(i);
      
      if (isSelected && isStereotype) correctCount++;
      if (isSelected && !isStereotype) incorrectCount++;
    }

    final double finalScore = (correctCount / scenarios.where((s) => s['isStereotype'] == true).length * 100).clamp(0, 100);
    
    // Guardar en Firebase
    final userData = await LocalStorageService.getUserData();
    final userId = userData?['userId'] ?? 'anonymous';
    final activityId = activityData['id'] ?? 'ami_activity';

    await FirebaseService.saveGameProgress(userId, unitId, activityId, {
      'isCorrect': finalScore >= 70,
      'score': finalScore.toInt(),
      'completed': true,
    });

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/activity_completion', arguments: {
      'unitData': unitData,
      'activityData': activityData,
      'unitId': unitId,
      'correctAnswers': correctCount,
      'incorrectAnswers': incorrectCount,
      'finalScore': finalScore,
      'learningPoints': [
        'Los estereotipos nos limitan y debemos romperlos',
        'Todos pueden disfrutar de cualquier actividad',
        'La inclusión hace un mundo mejor',
      ],
    });
  }
}
