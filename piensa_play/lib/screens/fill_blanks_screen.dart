import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';

class FillBlanksScreen extends StatefulWidget {
  const FillBlanksScreen({super.key});

  @override
  State<FillBlanksScreen> createState() => _FillBlanksScreenState();
}

class _FillBlanksScreenState extends State<FillBlanksScreen> {
  List<FillBlankQuestion> _questions = [];
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalPoints = 0;
  bool _isComplete = false;
  String? _selectedWord;
  bool _showResult = false;
  bool? _isCorrect;

  void _initializeGame(Map<String, dynamic> activityData) {
    if (_questions.isNotEmpty) return;
    
    final questionsData = activityData['fillBlanks'] as List? ?? _getDefaultQuestions();
    _questions = questionsData.map((q) {
      final data = Map<String, dynamic>.from(q as Map);
      return FillBlankQuestion(
        sentence: data['sentence'] ?? '',
        correctWord: data['correctWord'] ?? '',
        options: List<String>.from(data['options'] ?? []),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _getDefaultQuestions() {
    return [
      {
        'sentence': 'Nunca debo compartir mi _____ con desconocidos en internet.',
        'correctWord': 'contraseña',
        'options': ['contraseña', 'nombre', 'foto', 'email'],
      },
      {
        'sentence': 'Si alguien me molesta en línea, debo contarle a un _____.',
        'correctWord': 'adulto',
        'options': ['adulto', 'amigo', 'vecino', 'compañero'],
      },
      {
        'sentence': 'Las noticias falsas se llaman _____.',
        'correctWord': 'fake news',
        'options': ['fake news', 'good news', 'breaking news', 'old news'],
      },
      {
        'sentence': 'Antes de compartir información, debo _____ si es verdadera.',
        'correctWord': 'verificar',
        'options': ['verificar', 'olvidar', 'ignorar', 'borrar'],
      },
    ];
  }

  void _selectWord(String word) {
    if (_showResult) return;
    
    final question = _questions[_currentIndex];
    final correct = word == question.correctWord;
    
    setState(() {
      _selectedWord = word;
      _showResult = true;
      _isCorrect = correct;
      
      if (correct) {
        _correctAnswers++;
        _totalPoints += 100;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedWord = null;
        _showResult = false;
        _isCorrect = null;
      });
    } else {
      setState(() => _isComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final activityData = args['activityData'] as Map<String, dynamic>? ?? {};
    final unitId = args['unitId'] as String? ?? '';
    
    _initializeGame(activityData);
    
    if (_isComplete) return _buildCompletionScreen(args, unitId, activityData);
    if (_questions.isEmpty) return _buildEmptyState();

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: AppStyles.darkBlue,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(activityData['title'] ?? 'Completar Oraciones', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: AppStyles.darkBlue,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pregunta ${_currentIndex + 1}/${_questions.length}', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    Row(children: [const Icon(Icons.star, color: Color(0xFFF6E16B), size: 18), const SizedBox(width: 4), Text('$_totalPoints', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: (_currentIndex + 1) / _questions.length, backgroundColor: Colors.white.withOpacity(0.3), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC9E090)), minHeight: 8),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))]),
                    child: Column(
                      children: [
                        const Icon(Icons.edit_note, size: 40, color: Color(0xFFF6E16B)),
                        const SizedBox(height: 16),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(fontSize: 20, color: AppStyles.darkBlue, height: 1.5),
                            children: _buildSentenceSpans(question.sentence),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Selecciona la palabra correcta:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppStyles.darkBlue)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: question.options.map((word) {
                      final isSelected = _selectedWord == word;
                      final isCorrectWord = word == question.correctWord;
                      
                      Color bgColor = Colors.white;
                      Color borderColor = Colors.grey.shade300;
                      
                      if (_showResult) {
                        if (isCorrectWord) {
                          bgColor = const Color(0xFFE8F5E9);
                          borderColor = const Color(0xFF66BB6A);
                        } else if (isSelected && !isCorrectWord) {
                          bgColor = const Color(0xFFFFEBEE);
                          borderColor = const Color(0xFFE57373);
                        }
                      } else if (isSelected) {
                        bgColor = const Color(0xFFFFF3E0);
                        borderColor = const Color(0xFFF6E16B);
                      }
                      
                      return InkWell(
                        onTap: _showResult ? null : () => _selectWord(word),
                        borderRadius: BorderRadius.circular(25),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(25), border: Border.all(color: borderColor, width: 2)),
                          child: Text(word, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppStyles.darkBlue)),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_showResult) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: _isCorrect == true ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        Icon(_isCorrect == true ? Icons.check_circle : Icons.info, color: _isCorrect == true ? const Color(0xFF66BB6A) : const Color(0xFFE57373)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_isCorrect == true ? '¡Correcto! +100 puntos' : 'La respuesta correcta es: "${question.correctWord}"', style: TextStyle(fontWeight: FontWeight.w600, color: _isCorrect == true ? const Color(0xFF2E7D32) : const Color(0xFFC62828)))),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9E090), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: Text(_currentIndex < _questions.length - 1 ? 'SIGUIENTE' : 'VER RESULTADOS', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppStyles.darkBlue)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildSentenceSpans(String sentence) {
    final parts = sentence.split('_____');
    List<TextSpan> spans = [];
    
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));
      if (i < parts.length - 1) {
        spans.add(TextSpan(
          text: _selectedWord ?? '_____',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _showResult 
              ? (_isCorrect == true ? const Color(0xFF66BB6A) : const Color(0xFFE57373)) 
              : const Color(0xFFF6E16B),
            backgroundColor: _showResult 
              ? (_isCorrect == true ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE)) 
              : const Color(0xFFFFF3E0),
          ),
        ));
      }
    }
    return spans;
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppStyles.darkBlue, title: const Text('Completar')),
      body: const Center(child: Text('No hay preguntas configuradas')),
    );
  }

  Widget _buildCompletionScreen(Map<String, dynamic> args, String unitId, Map<String, dynamic> activityData) {
    final percentage = (_correctAnswers / _questions.length * 100).round();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 100, height: 100, decoration: const BoxDecoration(color: Color(0xFFC9E090), shape: BoxShape.circle), child: const Icon(Icons.edit_note, size: 50, color: AppStyles.darkBlue)),
              const SizedBox(height: 24),
              const Text('¡Bien hecho!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppStyles.darkBlue)),
              const SizedBox(height: 8),
              Text('Completaste todas las oraciones', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _buildStatBadge('$_correctAnswers/${_questions.length}', 'Correctas'),
                const SizedBox(width: 20),
                _buildStatBadge('$percentage%', 'Acierto'),
                const SizedBox(width: 20),
                _buildStatBadge('$_totalPoints', 'Puntos'),
              ]),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final userId = await LocalStorageService.getUserId();
                    if (userId != null) await FirebaseService.saveGameProgress(userId, unitId, activityData['id'] ?? '', {'completed': true, 'score': _totalPoints, 'type': activityData['type'] ?? 'fill_blanks'});
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

  Widget _buildStatBadge(String value, String label) {
    return Column(children: [
      Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]), child: Center(child: Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppStyles.darkBlue)))),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
    ]);
  }
}

class FillBlankQuestion {
  final String sentence;
  final String correctWord;
  final List<String> options;
  FillBlankQuestion({required this.sentence, required this.correctWord, required this.options});
}
