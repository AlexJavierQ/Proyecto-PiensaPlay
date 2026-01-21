import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';
import '../widgets/widgets.dart';

/// Pantalla de Quiz con preguntas de opción múltiple
/// El profesor puede configurar preguntas con 2-4 opciones de respuesta
class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _totalPoints = 0;
  bool _showingResult = false;
  bool _isComplete = false;
  int? _selectedAnswerIndex;
  bool? _isCorrect;
  
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _progressController;

  // Questions will be loaded from activity data
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index, bool correct) {
    if (_showingResult) return;
    
    setState(() {
      _selectedAnswerIndex = index;
      _isCorrect = correct;
      _showingResult = true;
      
      if (correct) {
        _correctAnswers++;
        _totalPoints += 100;
        _bounceController.forward().then((_) => _bounceController.reverse());
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _isCorrect = null;
        _showingResult = false;
      });
    } else {
      setState(() {
        _isComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final unitData = args['unitData'] as Map<String, dynamic>? ?? {};
    final activityData = args['activityData'] as Map<String, dynamic>? ?? {};
    final unitId = args['unitId'] as String? ?? '';
    
    // Load questions from activity data
    if (_questions.isEmpty) {
      _questions = _loadQuestionsFromActivity(activityData);
    }

    if (_isComplete) {
      return _buildCompletionScreen(unitData, activityData, args, unitId);
    }

    if (_questions.isEmpty) {
      return _buildEmptyState();
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final rawAnswers = currentQuestion['answers'] as List?;
    final answers = rawAnswers?.map((a) => Map<String, dynamic>.from(a as Map)).toList() ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: AppStyles.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _showExitConfirmation(context),
        ),
        title: Text(
          activityData['title'] ?? 'Quiz',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFF6E16B), size: 18),
                const SizedBox(width: 4),
                ScaleTransition(
                  scale: _bounceAnimation,
                  child: Text(
                    '$_totalPoints',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            color: AppStyles.darkBlue,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pregunta ${_currentQuestionIndex + 1} de ${_questions.length}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(_correctAnswers / _questions.length * 100).round()}% correcto',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC9E090)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppStyles.darkBlue.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6E16B).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.quiz_rounded,
                            color: Color(0xFFE5A910),
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          currentQuestion['question'] ?? 'Sin pregunta',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppStyles.darkBlue,
                            height: 1.4,
                          ),
                        ),
                        if (currentQuestion['hint'] != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lightbulb_outline, color: Color(0xFF66BB6A), size: 18),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    currentQuestion['hint'],
                                    style: const TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Answer options
                  ...List.generate(answers.length, (index) {
                    final answer = answers[index];
                    final isSelected = _selectedAnswerIndex == index;
                    final isCorrectAnswer = answer['isCorrect'] == true;

                    Color bgColor = Colors.white;
                    Color borderColor = Colors.grey.shade300;
                    Color textColor = AppStyles.darkBlue;
                    IconData? icon;

                    if (_showingResult) {
                      if (isCorrectAnswer) {
                        bgColor = const Color(0xFFE8F5E9);
                        borderColor = const Color(0xFF66BB6A);
                        icon = Icons.check_circle;
                      } else if (isSelected && !isCorrectAnswer) {
                        bgColor = const Color(0xFFFFEBEE);
                        borderColor = const Color(0xFFE57373);
                        icon = Icons.cancel;
                      }
                    } else if (isSelected) {
                      bgColor = const Color(0xFFE3F2FD);
                      borderColor = AppStyles.darkBlue;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showingResult ? null : () => _selectAnswer(index, isCorrectAnswer),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 2),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: borderColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected ? borderColor : Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: icon != null
                                        ? Icon(icon, color: Colors.white, size: 20)
                                        : Text(
                                            String.fromCharCode(65 + index),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.white : AppStyles.darkBlue,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    answer['text'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Feedback message
                  if (_showingResult) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isCorrect == true
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isCorrect == true ? Icons.celebration : Icons.lightbulb,
                            color: _isCorrect == true
                                ? const Color(0xFF66BB6A)
                                : const Color(0xFFE57373),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isCorrect == true
                                  ? '¡Excelente! +100 puntos'
                                  : currentQuestion['explanation'] ?? '¡Sigue intentando!',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _isCorrect == true
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFC62828),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9E090),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentQuestionIndex < _questions.length - 1
                              ? 'Siguiente Pregunta'
                              : 'Ver Resultados',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppStyles.darkBlue,
                          ),
                        ),
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

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: AppStyles.darkBlue,
        title: const Text('Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay preguntas configuradas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El profesor aún no ha agregado preguntas a esta actividad',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(
    Map<String, dynamic> unitData,
    Map<String, dynamic> activityData,
    Map<String, dynamic> args,
    String unitId,
  ) {
    final percentage = (_correctAnswers / _questions.length * 100).round();
    final isPassing = percentage >= 70;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy or retry icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isPassing ? const Color(0xFFC9E090) : const Color(0xFFFFE082),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isPassing ? const Color(0xFFC9E090) : const Color(0xFFFFE082)).withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  isPassing ? Icons.emoji_events : Icons.replay,
                  size: 60,
                  color: AppStyles.darkBlue,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isPassing ? '¡Felicitaciones!' : '¡Buen intento!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppStyles.darkBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isPassing
                    ? 'Has completado el quiz exitosamente'
                    : 'Necesitas 70% para aprobar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle,
                      value: '$_correctAnswers/${_questions.length}',
                      label: 'Correctas',
                      color: const Color(0xFF66BB6A),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.star,
                      value: '$_totalPoints',
                      label: 'Puntos',
                      color: const Color(0xFFF6E16B),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.percent,
                      value: '$percentage%',
                      label: 'Acierto',
                      color: const Color(0xFF42A5F5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Action buttons
              if (isPassing) ...[
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      final userId = await LocalStorageService.getUserId();
                      if (userId != null) {
                        await FirebaseService.saveGameProgress(
                          userId,
                          unitId,
                          activityData['id'] ?? '',
                          {
                            'completed': true,
                            'score': _totalPoints,
                            'correctAnswers': _correctAnswers,
                            'totalQuestions': _questions.length,
                            'type': activityData['type'] ?? 'quiz',
                          },
                        );
                      }
                      if (mounted) {
                        Navigator.pushReplacementNamed(
                          context,
                          '/activity_completion',
                          arguments: {
                            ...args,
                            'score': _totalPoints,
                            'correctAnswers': _correctAnswers,
                            'totalQuestions': _questions.length,
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9E090),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppStyles.darkBlue,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex = 0;
                        _correctAnswers = 0;
                        _totalPoints = 0;
                        _showingResult = false;
                        _isComplete = false;
                        _selectedAnswerIndex = null;
                        _isCorrect = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6E16B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'INTENTAR DE NUEVO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppStyles.darkBlue,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Volver más tarde',
                    style: TextStyle(color: AppStyles.darkBlue),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppStyles.darkBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Salir del quiz?'),
        content: const Text('Perderás tu progreso actual si sales ahora.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _loadQuestionsFromActivity(Map<String, dynamic> activityData) {
    // Try to load questions from activity data
    final questionsData = activityData['questions'] as List?;
    
    if (questionsData != null && questionsData.isNotEmpty) {
      return questionsData.map((q) => Map<String, dynamic>.from(q as Map)).toList();
    }
    
    // Return demo questions if none configured
    return [
      {
        'question': '¿Qué debes hacer si recibes un mensaje de un desconocido en internet?',
        'hint': 'Piensa en tu seguridad primero',
        'explanation': 'Nunca debemos responder a desconocidos y siempre debemos contarle a un adulto de confianza.',
        'answers': [
          {'text': 'Responder inmediatamente', 'isCorrect': false},
          {'text': 'No responder y contarle a un adulto', 'isCorrect': true},
          {'text': 'Darle mi información personal', 'isCorrect': false},
          {'text': 'Agregarlo como amigo', 'isCorrect': false},
        ],
      },
      {
        'question': '¿Cuál es una contraseña segura?',
        'hint': 'Las contraseñas seguras tienen letras, números y símbolos',
        'explanation': 'Una contraseña segura combina letras mayúsculas, minúsculas, números y símbolos.',
        'answers': [
          {'text': '123456', 'isCorrect': false},
          {'text': 'MiNombre2024', 'isCorrect': false},
          {'text': 'C@sa_Azul#99!', 'isCorrect': true},
          {'text': 'password', 'isCorrect': false},
        ],
      },
      {
        'question': '¿Qué información NUNCA debes compartir en internet?',
        'explanation': 'Tu dirección de casa es información privada que puede poner en riesgo tu seguridad.',
        'answers': [
          {'text': 'Tu color favorito', 'isCorrect': false},
          {'text': 'Tu dirección de casa', 'isCorrect': true},
          {'text': 'Tu película favorita', 'isCorrect': false},
          {'text': 'Tu deporte preferido', 'isCorrect': false},
        ],
      },
    ];
  }
}
