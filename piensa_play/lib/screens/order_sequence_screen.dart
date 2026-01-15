import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';

class OrderSequenceScreen extends StatefulWidget {
  const OrderSequenceScreen({super.key});

  @override
  State<OrderSequenceScreen> createState() => _OrderSequenceScreenState();
}

class _OrderSequenceScreenState extends State<OrderSequenceScreen> {
  List<SequenceItem> _items = [];
  List<SequenceItem> _correctOrder = [];
  int _attempts = 0;
  int _totalPoints = 0;
  bool _isComplete = false;
  bool _showVerification = false;
  bool? _isCorrectOrder;

  void _initializeGame(Map<String, dynamic> activityData) {
    if (_items.isNotEmpty) return;
    
    final stepsData = activityData['steps'] as List? ?? _getDefaultSteps();
    final steps = stepsData.asMap().entries.map((e) {
      final step = Map<String, dynamic>.from(e.value as Map);
      return SequenceItem(id: e.key, text: step['text'] ?? '', correctPosition: e.key);
    }).toList();
    
    _correctOrder = List.from(steps);
    _items = List.from(steps)..shuffle();
  }

  List<Map<String, dynamic>> _getDefaultSteps() {
    return [
      {'text': '1. Verifica la fuente de la noticia'},
      {'text': '2. Lee el artículo completo'},
      {'text': '3. Busca otras fuentes que confirmen'},
      {'text': '4. Revisa la fecha de publicación'},
      {'text': '5. Comparte solo si es verdadera'},
    ];
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      _showVerification = false;
      _isCorrectOrder = null;
    });
  }

  void _checkOrder() {
    _attempts++;
    bool isCorrect = true;
    
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].correctPosition != i) {
        isCorrect = false;
        break;
      }
    }
    
    setState(() {
      _showVerification = true;
      _isCorrectOrder = isCorrect;
      if (isCorrect) {
        _totalPoints = (100 / _attempts).round() * 100;
        _totalPoints = _totalPoints.clamp(100, 500);
      }
    });
    
    if (isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isComplete = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final activityData = args['activityData'] as Map<String, dynamic>? ?? {};
    final unitId = args['unitId'] as String? ?? '';
    
    _initializeGame(activityData);
    
    if (_isComplete) return _buildCompletionScreen(args, unitId, activityData);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: AppStyles.darkBlue,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(activityData['title'] ?? 'Ordenar Secuencia', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: AppStyles.darkBlue,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Intentos: $_attempts', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.touch_app, color: Color(0xFF66BB6A)),
                const SizedBox(width: 10),
                Expanded(child: Text('Arrastra los elementos para ordenarlos correctamente', style: TextStyle(color: Colors.green.shade700, fontSize: 14))),
              ],
            ),
          ),
          
          if (_showVerification)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCorrectOrder == true ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_isCorrectOrder == true ? Icons.check_circle : Icons.error, color: _isCorrectOrder == true ? const Color(0xFF66BB6A) : const Color(0xFFE57373)),
                  const SizedBox(width: 8),
                  Text(
                    _isCorrectOrder == true ? '¡Orden correcto! +$_totalPoints puntos' : 'Orden incorrecto. ¡Intenta de nuevo!',
                    style: TextStyle(fontWeight: FontWeight.w600, color: _isCorrectOrder == true ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length,
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                final item = _items[index];
                bool? isCorrect;
                if (_showVerification) {
                  isCorrect = item.correctPosition == index;
                }
                
                return Container(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect == true ? const Color(0xFFE8F5E9) : isCorrect == false ? const Color(0xFFFFEBEE) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCorrect == true ? const Color(0xFF66BB6A) : isCorrect == false ? const Color(0xFFE57373) : Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(color: AppStyles.darkBlue.withOpacity(0.1), shape: BoxShape.circle),
                            child: Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppStyles.darkBlue))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item.text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppStyles.darkBlue))),
                          const Icon(Icons.drag_handle, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _showVerification && _isCorrectOrder == true ? null : _checkOrder,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9E090), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('VERIFICAR ORDEN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppStyles.darkBlue)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(Map<String, dynamic> args, String unitId, Map<String, dynamic> activityData) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: const BoxDecoration(color: Color(0xFFC9E090), shape: BoxShape.circle),
                child: const Icon(Icons.sort, size: 50, color: AppStyles.darkBlue),
              ),
              const SizedBox(height: 24),
              const Text('¡Perfecto!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppStyles.darkBlue)),
              const SizedBox(height: 8),
              Text('Ordenaste la secuencia correctamente', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Text('$_totalPoints puntos', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppStyles.darkBlue)),
              Text('en $_attempts intentos', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final userId = await LocalStorageService.getUserId();
                    if (userId != null) {
                      await FirebaseService.saveGameProgress(userId, unitId, activityData['id'] ?? '', {'completed': true, 'score': _totalPoints, 'attempts': _attempts, 'type': activityData['type'] ?? 'order_sequence'});
                    }
                    if (mounted) Navigator.pushReplacementNamed(context, '/activity_completion', arguments: {...args, 'score': _totalPoints});
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9E090), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('CONTINUAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppStyles.darkBlue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SequenceItem {
  final int id;
  final String text;
  final int correctPosition;
  SequenceItem({required this.id, required this.text, required this.correctPosition});
}
