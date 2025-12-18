import 'package:flutter/material.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';

class FinalExamScreen extends StatefulWidget {
  const FinalExamScreen({super.key});

  @override
  State<FinalExamScreen> createState() => _FinalExamScreenState();
}

class _FinalExamScreenState extends State<FinalExamScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _isFinished = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final unitData = args?['unitData'] as Map<String, dynamic>? ?? {};
    final activityData = args?['activityData'] as Map<String, dynamic>? ?? {};
    final String unitId = args?['unitId'] ?? '';

    // Datos dinámicos de Firebase (con fallbacks)
    final List<dynamic> questions = activityData['questions'] ?? [
      {
        'question': '¿Qué es lo primero que debes revisar en una noticia?',
        'options': ['La fecha', 'La fuente', 'La imagen', 'Los comentarios'],
        'correctIndex': 1,
      },
      {
        'question': '¿Un estereotipo es siempre verdad?',
        'options': ['Sí, siempre', 'No, es una idea simplificada', 'A veces', 'Solo en la tele'],
        'correctIndex': 1,
      }
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
        title: Text(unitData['title'] ?? 'Gran Desafío', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSubHeader(),
          _buildProgressIndicator(questions.length),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: _buildQuestionCard(questions[_currentQuestionIndex]),
            ),
          ),
          _buildNavigationButtons(questions, unitData, activityData, unitId),
          const SizedBox(height: 24),
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
            child: const Text('Examen Final de Unidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF132757))),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (index) {
          bool isCompleted = _selectedAnswers.containsKey(index);
          bool isCurrent = index == _currentQuestionIndex;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: isCurrent ? const Color(0xFF132757) : (isCompleted ? const Color(0xFFA0E69D) : Colors.grey[200]),
              shape: BoxShape.circle,
              border: Border.all(color: isCurrent ? Colors.amber : Colors.transparent, width: 2),
            ),
            child: Center(
              child: isCompleted && !isCurrent 
                ? const Icon(Icons.check, size: 18, color: Colors.white) 
                : Text('${index + 1}', style: TextStyle(color: isCurrent ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> questionData) {
    final List<dynamic> options = questionData['options'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), width: 2),
          ),
          child: Text(
            questionData['question'] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF132757), height: 1.4),
          ),
        ),
        const SizedBox(height: 32),
        ...options.asMap().entries.map((entry) => _buildOptionTile(entry.key, entry.value)).toList(),
      ],
    );
  }

  Widget _buildOptionTile(int index, String text) {
    bool isSelected = _selectedAnswers[_currentQuestionIndex] == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedAnswers[_currentQuestionIndex] = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF132757) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.amber : Colors.grey.shade200, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(String.fromCharCode(65 + index), style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black54))),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87))),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(List<dynamic> questions, Map<String, dynamic> unitData, Map<String, dynamic> activityData, String unitId) {
    bool isLast = _currentQuestionIndex == questions.length - 1;
    bool hasSelected = _selectedAnswers.containsKey(_currentQuestionIndex);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentQuestionIndex--),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('Anterior', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF132757))),
              ),
            ),
          if (_currentQuestionIndex > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: !hasSelected || _isFinished ? null : () {
                if (isLast) _handleFinish(questions, unitData, activityData, unitId);
                else setState(() => _currentQuestionIndex++);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF132757),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(isLast ? '¡TERMINAR EXAMEN!' : 'Siguiente', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFinish(List<dynamic> questions, Map<String, dynamic> unitData, Map<String, dynamic> activityData, String unitId) async {
    setState(() => _isFinished = true);
    
    int correctCount = 0;
    for (int i = 0; i < questions.length; i++) {
      if (_selectedAnswers[i] == questions[i]['correctIndex']) correctCount++;
    }

    final double score = (correctCount / questions.length) * 100;
    final userData = await LocalStorageService.getUserData();
    final userId = userData?['userId'] ?? 'anonymous';

    // 1. Guardar progreso del examen
    await FirebaseService.saveGameProgress(userId, unitId, activityData['id'] ?? 'final_exam', {
      'score': score.toInt(),
      'completed': true,
      'isCorrect': score >= 70,
    });

    // 2. Si aprueba, marcar la UNIDAD COMPLETA
    if (score >= 70) {
      await FirebaseService.updateGameUnit(unitId, {'status': 'completed'});
    }

    if (!mounted) return;
    
    // 3. Navegación final a la pantalla de CELEBRACIÓN DE UNIDAD (la del cohete/llave)
    Navigator.pushReplacementNamed(context, '/unit_completion', arguments: {
      'unitData': unitData,
      'unitId': unitId,
      'totalXP': (score * 10).toInt(),
      'coinsEarned': (score / 10).toInt(),
      'badgeTitle': 'Maestro de la Verdad',
      'badgeDesc': 'Has demostrado ser un experto en detectar engaños.',
    });
  }
}
