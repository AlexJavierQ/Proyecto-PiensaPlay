import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../widgets/widgets.dart';

/// Pantalla de instrucciones de juego que explica cómo jugar
/// Muestra las reglas y elementos a identificar antes de comenzar una actividad
class GameInstructionsScreen extends StatelessWidget {
  const GameInstructionsScreen({super.key});

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
    final activityType = activityData['type'] as String? ?? 'fake_news';

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
              unitData['title'] ?? 'VeracidadVille',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Text(
              'Verifica o Falla',
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
            // Card de instrucciones principal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF6E16B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿CÓMO JUGAR?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppStyles.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Instrucciones numeradas
                  ..._getInstructions(activityType).asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final instruction = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppStyles.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              instruction,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppStyles.primaryBlue,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Texto de búsqueda de pistas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1976D2), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF1976D2), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getSearchHint(activityType),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppStyles.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección de ejemplo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppStyles.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ANALIZA ESTA NOTICIA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ejemplo de noticia
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Científicos descubren que beber jugo de zanahoria hace que puedas ver en la oscuridad',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppStyles.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Según un estudio reciente, tomar un vaso de jugo de zanahoria diariamente durante 30 días permite desarrollar visión nocturna similar a la de los gatos.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.source,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Fuente: NoticiasFalsas.com',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Elementos a identificar
                  const Text(
                    'Elementos a identificar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Lista de elementos
                  ..._getElementsToIdentify(activityType).map((element) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: element.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: element.color, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(element.icon, color: element.color, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              element.text,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: element.color,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: element.color,
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mensaje de confirmación
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFC9E090).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC9E090), width: 2),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '¡Correcta, es una noticia falsa!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botón comenzar
            ActivityButton(
              text: 'Comenzar Actividad',
              type: ActivityButtonType.primary,
              icon: Icons.play_arrow,
              onPressed: () {
                // Navegar a la actividad correspondiente según el tipo
                String routeName;
                switch (activityType) {
                  case 'fake_news':
                    routeName = '/fake_news_detector';
                    break;
                  case 'stereotype_breaker':
                    routeName = '/stereotype_breaker';
                    break;
                  case 'word_path':
                    routeName = '/word_path';
                    break;
                  default:
                    routeName = '/game_play';
                }

                Navigator.pushReplacementNamed(
                  context,
                  routeName,
                  arguments: args,
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<String> _getInstructions(String activityType) {
    switch (activityType) {
      case 'fake_news':
        return [
          'Lee la noticia o información presentada',
          'Analiza los elementos sospechosos',
          'Enlista los elementos identificados',
        ];
      case 'stereotype_breaker':
        return [
          'Observa cada escenario presentado',
          'Identifica cuáles muestran estereotipos',
          'Toca para transformar en opciones inclusivas',
        ];
      case 'word_path':
        return [
          'Lee cada palabra o frase presentada',
          'Decide si la palabra hiere o construye',
          'Ayuda al bosque a crecer con buenas decisiones',
        ];
      default:
        return [
          'Lee la información presentada',
          'Analiza los elementos importantes',
          'Toma la mejor decisión',
        ];
    }
  }

  String _getSearchHint(String activityType) {
    switch (activityType) {
      case 'fake_news':
        return 'Busca pistas en: fuentes, autores e imágenes';
      case 'stereotype_breaker':
        return 'Busca pistas en: comportamientos y expectativas limitantes';
      case 'word_path':
        return 'Busca pistas en: el impacto emocional de las palabras';
      default:
        return 'Busca pistas en: detalles importantes';
    }
  }

  List<ElementToIdentify> _getElementsToIdentify(String activityType) {
    switch (activityType) {
      case 'fake_news':
        return [
          ElementToIdentify(
            text: 'Autor: ¿No es un experto real?',
            icon: Icons.person,
            color: const Color(0xFF1976D2),
          ),
          ElementToIdentify(
            text: 'Fuente: ¿Es falsa?',
            icon: Icons.source,
            color: const Color(0xFF388E3C),
          ),
          ElementToIdentify(
            text: 'Imagen: ¿Parece manipulada?',
            icon: Icons.image,
            color: const Color(0xFFE91E63),
          ),
          ElementToIdentify(
            text: 'Datos: ¿Son exagerados?',
            icon: Icons.analytics,
            color: const Color(0xFF7B1FA2),
          ),
        ];
      case 'stereotype_breaker':
        return [
          ElementToIdentify(
            text: 'Expectativas: ¿Limitan por género?',
            icon: Icons.psychology,
            color: const Color(0xFF1976D2),
          ),
          ElementToIdentify(
            text: 'Actividades: ¿Excluyen a alguien?',
            icon: Icons.sports,
            color: const Color(0xFF388E3C),
          ),
          ElementToIdentify(
            text: 'Roles: ¿Son muy rígidos?',
            icon: Icons.people,
            color: const Color(0xFFE91E63),
          ),
        ];
      case 'word_path':
        return [
          ElementToIdentify(
            text: 'Tono: ¿Es respetuoso o hiriente?',
            icon: Icons.sentiment_satisfied,
            color: const Color(0xFF1976D2),
          ),
          ElementToIdentify(
            text: 'Impacto: ¿Construye o destruye?',
            icon: Icons.favorite,
            color: const Color(0xFF388E3C),
          ),
          ElementToIdentify(
            text: 'Inclusión: ¿Acepta o rechaza?',
            icon: Icons.group,
            color: const Color(0xFFE91E63),
          ),
        ];
      default:
        return [
          ElementToIdentify(
            text: 'Información: ¿Es confiable?',
            icon: Icons.info,
            color: const Color(0xFF1976D2),
          ),
        ];
    }
  }
}

class ElementToIdentify {
  final String text;
  final IconData icon;
  final Color color;

  ElementToIdentify({
    required this.text,
    required this.icon,
    required this.color,
  });
}
