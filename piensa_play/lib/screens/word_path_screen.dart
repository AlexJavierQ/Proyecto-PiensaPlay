import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../widgets/widgets.dart';

/// Pantalla de actividad "El sendero de las palabras"
/// El usuario debe clasificar palabras como "que hieren" o "que construyen"
class WordPathScreen extends StatefulWidget {
  const WordPathScreen({super.key});

  @override
  State<WordPathScreen> createState() => _WordPathScreenState();
}

class _WordPathScreenState extends State<WordPathScreen> {
  int _currentWordIndex = 0;
  int _score = 0;
  final Map<String, bool> _wordClassifications = {};
  bool _showResult = false;
  bool _isCorrect = false;

  // Palabras y frases para clasificar (en una implementación real vendrían de Firebase)
  final List<WordData> _words = [
    WordData(
      text: 'Vuelve a tu país, nadie te quiere aquí',
      isHurtful: true,
      context: 'Una persona le dice esto a otra en el parque',
    ),
    WordData(
      text: '¡Gracias por ayudarme!',
      isHurtful: false,
      context: 'Un niño agradece la ayuda de otro',
    ),
    WordData(
      text: 'Eres muy feo y tonto',
      isHurtful: true,
      context: 'Un comentario cruel hacia otra persona',
    ),
    WordData(
      text: 'Me gusta jugar contigo',
      isHurtful: false,
      context: 'Una invitación amistosa para jugar',
    ),
    WordData(
      text: 'No puedes jugar con nosotros',
      isHurtful: true,
      context: 'Exclusión de un grupo de juego',
    ),
    WordData(
      text: 'Todos somos diferentes y eso está bien',
      isHurtful: false,
      context: 'Mensaje de aceptación y diversidad',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppStyles.primaryBlue,
          title: const Text('Error', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text('No se encontraron datos de la actividad.'),
        ),
      );
    }

    final unitData = args['unitData'] as Map<String, dynamic>? ?? {};
    final activityData = args['activityData'] as Map<String, dynamic>? ?? {};

    if (_currentWordIndex >= _words.length) {
      return _buildCompletionScreen(unitData, activityData, args);
    }

    final currentWord = _words[_currentWordIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              unitData['title'] ?? 'Zona cero odio',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Text(
              'El sendero de las palabras',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Progreso
            ProgressBarWidget(
              current: _currentWordIndex,
              total: _words.length,
              barColor: const Color(0xFFC9E090),
            ),

            const SizedBox(height: 24),

            // Misión
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC9E090), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC9E090),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '¡Tu Misión!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppStyles.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activityData['mission'] ??
                        'Clasifica cada frase para ayudar al bosque a sanar. Elige si cada palabra construye o hiere para que respete y valore a los demás, contribuyendo a crear un ambiente donde todos se sientan seguros.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppStyles.textDark,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Imagen del bosque
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    const Color(0xFF8BC34A).withValues(alpha: 0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Árboles del bosque
                  Positioned(
                    bottom: 20,
                    left: 30,
                    child: Icon(
                      Icons.park,
                      size: 60,
                      color: _score > 50
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade400,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 30,
                    child: Icon(
                      Icons.nature,
                      size: 60,
                      color: _score > 80
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade400,
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: MediaQuery.of(context).size.width * 0.4,
                    child: Icon(
                      Icons.eco,
                      size: 80,
                      color: _score > 30
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade400,
                    ),
                  ),

                  // Progreso del bosque
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        Text(
                          'Progreso del Bosque',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _score / 100,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF4CAF50),
                          ),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contexto de la palabra/frase
            if (currentWord.context.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1976D2), width: 1),
                ),
                child: Text(
                  'Contexto: ${currentWord.context}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppStyles.textDark,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Palabra/frase actual
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Ícono de persona hablando
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble,
                      size: 30,
                      color: Color(0xFFE91E63),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Texto de la palabra/frase
                  Text(
                    '"${currentWord.text}"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppStyles.textDark,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Mensaje de resultado
            if (_showResult)
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: _isCorrect
                      ? const Color(0xFFC9E090).withValues(alpha: 0.2)
                      : const Color(0xFFFF8FA3).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isCorrect
                        ? const Color(0xFFC9E090)
                        : const Color(0xFFFF8FA3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect
                          ? const Color(0xFF10B981)
                          : const Color(0xFFFF6B6B),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _isCorrect
                            ? '¡Correcto! Has ayudado al bosque a crecer.'
                            : 'Piensa mejor. ¿Esta palabra ayuda o lastima a otros?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isCorrect
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFF6B6B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Botones de clasificación
            if (!_showResult)
              Row(
                children: [
                  Expanded(
                    child: AnswerButton(
                      text: 'Palabra que hiere',
                      isCorrect: false,
                      icon: Icons.heart_broken,
                      onPressed: () => _classifyWord(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnswerButton(
                      text: 'Palabra que conecta',
                      isCorrect: true,
                      icon: Icons.favorite,
                      onPressed: () => _classifyWord(false),
                    ),
                  ),
                ],
              )
            else
              ActivityButton(
                text: _currentWordIndex < _words.length - 1
                    ? 'Siguiente Palabra'
                    : 'Ver Resultados',
                type: ActivityButtonType.primary,
                icon: _currentWordIndex < _words.length - 1
                    ? Icons.arrow_forward
                    : Icons.assessment,
                onPressed: () {
                  setState(() {
                    _currentWordIndex++;
                    _showResult = false;
                  });
                },
              ),

            const SizedBox(height: 24),

            // Puntuación actual
            ScoreCardWidget(
              points: _score,
              label: 'Puntuación',
              showStar: true,
            ),

            const SizedBox(height: 24),

            // Botón de pista
            if (!_showResult)
              TextButton.icon(
                onPressed: () {
                  HintPopup.show(
                    context: context,
                    hintText:
                        'Piensa: ¿Esta palabra haría sentir bien o mal a la persona que la escucha? ¿Ayuda a crear un ambiente de respeto?',
                  );
                },
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('💡 Pista'),
                style: TextButton.styleFrom(
                  foregroundColor: AppStyles.primaryBlue,
                ),
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
  ) {
    final correctAnswers = _wordClassifications.values
        .where((correct) => correct)
        .length;
    final incorrectAnswers = _wordClassifications.length - correctAnswers;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'El sendero de las palabras',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Imagen de celebración
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF4CAF50), const Color(0xFF8BC34A)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forest, size: 80, color: Colors.white),
            ),

            const SizedBox(height: 24),

            // Título
            const Text(
              '¡Actividad Completada!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppStyles.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Mensaje
            const Text(
              'Has ayudado a restaurar el bosque identificando correctamente las palabras que hieren y las que construyen.',
              style: TextStyle(
                fontSize: 16,
                color: AppStyles.textDark,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Progreso del bosque final
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC9E090), width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Progreso del bosque',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppStyles.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 1.0, // 100% completado
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CAF50),
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Has restaurado completamente el bosque!',
                    style: TextStyle(fontSize: 14, color: AppStyles.textDark),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Resumen de respuestas
            MissionSummaryWidget(
              correctAnswers: correctAnswers,
              incorrectAnswers: incorrectAnswers,
              finalScore: (_score).toDouble(),
            ),

            const SizedBox(height: 24),

            // Puntos de aprendizaje
            LearningPointsWidget(
              learningPoints: [
                'Las palabras tienen poder. Pueden lastimar o sanar.',
                'Cuando elegimos palabras que respetan y valoran a los demás, contribuimos a crear un ambiente donde todos se sientan seguros.',
                'Cada palabra que elegimos puede hacer la diferencia en la vida de alguien.',
              ],
            ),

            const SizedBox(height: 32),

            // Botones de acción
            Column(
              children: [
                ActivityButton(
                  text: 'Siguiente Misión',
                  type: ActivityButtonType.primary,
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/activity_completion',
                      arguments: {
                        'unitData': unitData,
                        'activityData': activityData,
                        'correctAnswers': correctAnswers,
                        'incorrectAnswers': incorrectAnswers,
                        'learningPoints': [
                          'Las palabras tienen poder para lastimar o sanar',
                          'Elegir palabras respetuosas crea ambientes seguros',
                          'Cada palabra puede hacer la diferencia',
                        ],
                        'unitId': args['unitId'],
                        'activityId': activityData['id'],
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                ActivityButton(
                  text: 'Repetir Actividad',
                  type: ActivityButtonType.secondary,
                  icon: Icons.refresh,
                  onPressed: () {
                    setState(() {
                      _currentWordIndex = 0;
                      _score = 0;
                      _wordClassifications.clear();
                      _showResult = false;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _classifyWord(bool userSaysHurtful) {
    final currentWord = _words[_currentWordIndex];
    final isCorrect = userSaysHurtful == currentWord.isHurtful;

    setState(() {
      _isCorrect = isCorrect;
      _showResult = true;
      _wordClassifications[currentWord.text] = isCorrect;

      if (isCorrect) {
        _score += 20; // +20 puntos por respuesta correcta
        _score = _score.clamp(0, 100);
      }
    });

    // Mostrar feedback inmediato
    FeedbackPopup.show(
      context: context,
      isCorrect: isCorrect,
      customMessage: isCorrect
          ? '¡Correcto! Has ayudado al bosque a crecer'
          : 'Piensa mejor en el impacto de estas palabras',
      onContinue: () {
        // El popup se cierra automáticamente
      },
    );
  }
}

class WordData {
  final String text;
  final bool isHurtful;
  final String context;

  WordData({
    required this.text,
    required this.isHurtful,
    required this.context,
  });
}
