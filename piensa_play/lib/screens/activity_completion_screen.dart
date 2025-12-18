import 'package:flutter/material.dart';

class ActivityCompletionScreen extends StatelessWidget {
  const ActivityCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    final unitData = args?['unitData'] as Map<String, dynamic>? ?? {};
    final correctAnswers = args?['correctAnswers'] as int? ?? 8;
    final incorrectAnswers = args?['incorrectAnswers'] as int? ?? 2;
    final finalScore = args?['finalScore'] as double? ?? 80.0;
    final learningPoints = args?['learningPoints'] as List<String>? ?? [
      'Siempre verifica la fuente de la información',
      'Desconfía de mensajes con lenguaje muy emocional',
      'Las promesas mágicas suelen ser falsas',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF132757),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          unitData['title'] ?? 'Veracidadville',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Subheader Blanco redondeado
          _buildSubHeader(),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // SECCIÓN RESUMEN (Contenedor con borde gris)
                  _buildSummarySection(correctAnswers, incorrectAnswers, finalScore),
                  
                  const SizedBox(height: 24),
                  
                  // SECCIÓN ¿QUÉ APRENDISTE?
                  _buildLearningSection(learningPoints),
                  
                  const SizedBox(height: 32),
                  
                  // BOTONES DE ACCIÓN
                  _buildActionButtons(context, args),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
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
            child: const Text(
              'Resumen de tu Misión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF132757)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(int correct, int incorrect, double score) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'Resumen de tu Misión',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF132757)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Cuadro Correctas (Verde)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_box_rounded, color: Colors.green, size: 35),
                      const SizedBox(height: 8),
                      Text('$correct', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF132757))),
                      const Text('Correctas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Cuadro Incorrectas (Rosa)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4EC),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cancel_rounded, color: Color(0xFFF9879B), size: 35),
                      const SizedBox(height: 8),
                      Text('$incorrect', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF132757))),
                      const Text('Incorrectas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF9879B))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Cuadro Puntuación (Degradado Naranja/Amarillo)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF6E16B), Color(0xFFF9879B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 30),
                const SizedBox(height: 8),
                Text(
                  '${score.toInt()}%',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF132757)),
                ),
                const Text(
                  'Puntuación Final',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF132757)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningSection(List<String> points) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            '¿Qué Aprendiste?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF132757)),
          ),
          const SizedBox(height: 20),
          ...points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF6E16B), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    p,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF132757), height: 1.4),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic>? args) {
    return Column(
      children: [
        _buildButton('Siguiente Misión', const Color(0xFF132757), Colors.white, () {
          Navigator.pushNamedAndRemoveUntil(context, '/game_activities_map', (r) => false, arguments: args);
        }),
        const SizedBox(height: 16),
        _buildButton('Repetir Actividad', const Color(0xFFF6E16B), const Color(0xFF132757), () {
          Navigator.pop(context);
        }),
        const SizedBox(height: 16),
        _buildButton('Volver al Mapa', Colors.white, const Color(0xFF132757), () {
          Navigator.pushNamedAndRemoveUntil(context, '/game_units', (r) => false);
        }, isOutlined: true),
      ],
    );
  }

  Widget _buildButton(String label, Color bg, Color text, VoidCallback onTap, {bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: text,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: isOutlined ? const BorderSide(color: Colors.grey, width: 1.5) : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
