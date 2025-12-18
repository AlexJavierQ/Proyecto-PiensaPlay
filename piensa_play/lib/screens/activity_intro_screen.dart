import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../widgets/widgets.dart';

/// Pantalla de introducción de actividad que presenta el contexto y ambiente
/// Muestra una descripción narrativa antes de comenzar la actividad
class ActivityIntroScreen extends StatelessWidget {
  const ActivityIntroScreen({super.key});

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
    final activityType = activityData['type'] as String? ?? 'word_path';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          unitData['title'] ?? 'Zona cero odio',
          style: const TextStyle(
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
            // Título de la actividad
            Text(
              _getActivityTitle(activityType),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppStyles.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtítulo
            Text(
              _getActivitySubtitle(activityType),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Imagen principal de la actividad
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: _getActivityGradient(activityType),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Elementos decorativos del fondo
                  ..._getBackgroundElements(activityType),

                  // Contenido principal
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getActivityIcon(activityType),
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getActivityBadge(activityType),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Descripción narrativa
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getActivityDescription(activityType),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppStyles.textDark,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pregunta motivacional
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1976D2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getMotivationalQuestion(activityType),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppStyles.primaryBlue,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Palabras flotantes de ejemplo (solo para word_path)
            if (activityType == 'word_path')
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC9E090), width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Ejemplos de palabras que encontrarás:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppStyles.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Palabras de ejemplo
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _WordChip(text: '¡Gracias!', isPositive: true),
                        _WordChip(text: 'Eres genial', isPositive: true),
                        _WordChip(text: 'No me gusta', isPositive: false),
                        _WordChip(text: 'Respeto', isPositive: true),
                        _WordChip(text: 'Vuelve a tu país', isPositive: false),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Botón comenzar aventura
            ActivityButton(
              text: 'Comenzar Aventura →',
              type: ActivityButtonType.primary,
              icon: Icons.rocket_launch,
              onPressed: () {
                // Navegar a las instrucciones primero
                Navigator.pushNamed(
                  context,
                  '/game_instructions',
                  arguments: args,
                );
              },
            ),

            const SizedBox(height: 16),

            // Texto footer
            Text(
              _getFooterText(activityType),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getActivityTitle(String activityType) {
    switch (activityType) {
      case 'word_path':
        return 'Bosque de los Ecos Digitales';
      case 'fake_news':
        return 'Laboratorio de la Verdad';
      case 'stereotype_breaker':
        return 'Parque de la Inclusión';
      default:
        return 'Aventura Digital';
    }
  }

  String _getActivitySubtitle(String activityType) {
    switch (activityType) {
      case 'word_path':
        return 'Una aventura de palabras';
      case 'fake_news':
        return 'Detecta la desinformación';
      case 'stereotype_breaker':
        return 'Rompe las barreras';
      default:
        return 'Una experiencia educativa';
    }
  }

  LinearGradient _getActivityGradient(String activityType) {
    switch (activityType) {
      case 'word_path':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        );
      case 'fake_news':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        );
      case 'stereotype_breaker':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
        );
    }
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'word_path':
        return Icons.forest;
      case 'fake_news':
        return Icons.fact_check;
      case 'stereotype_breaker':
        return Icons.diversity_3;
      default:
        return Icons.psychology;
    }
  }

  String _getActivityBadge(String activityType) {
    switch (activityType) {
      case 'word_path':
        return 'PALABRAS QUE SANAN';
      case 'fake_news':
        return 'DETECTIVE DIGITAL';
      case 'stereotype_breaker':
        return 'CONSTRUCTOR DE PUENTES';
      default:
        return 'EXPLORADOR DIGITAL';
    }
  }

  List<Widget> _getBackgroundElements(String activityType) {
    switch (activityType) {
      case 'word_path':
        return [
          // Hojas flotantes
          Positioned(
            top: 30,
            left: 30,
            child: Icon(
              Icons.eco,
              size: 40,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 40,
            child: Icon(
              Icons.nature,
              size: 35,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            top: 80,
            right: 60,
            child: Icon(
              Icons.local_florist,
              size: 30,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ];
      case 'fake_news':
        return [
          // Elementos de investigación
          Positioned(
            top: 40,
            left: 40,
            child: Icon(
              Icons.search,
              size: 35,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 50,
            child: Icon(
              Icons.verified,
              size: 40,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ];
      case 'stereotype_breaker':
        return [
          // Elementos de diversidad
          Positioned(
            top: 35,
            left: 35,
            child: Icon(
              Icons.people,
              size: 40,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            bottom: 45,
            right: 45,
            child: Icon(
              Icons.favorite,
              size: 35,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  String _getActivityDescription(String activityType) {
    switch (activityType) {
      case 'word_path':
        return 'Has descubierto un bosque mágico donde tus palabras tienen poder. Algunas zonas están marchitas por palabras dañinas, mientras otras florecen con palabras amables.\n\nTu misión es ayudar a restaurar el bosque eligiendo las palabras correctas. Cada decisión que tomes afectará la salud del bosque y el bienestar de quienes lo habitan.';
      case 'fake_news':
        return 'Te encuentras en el Laboratorio de la Verdad, donde circulan noticias verdaderas y falsas. Como detective digital, debes usar tus habilidades para identificar la desinformación.\n\nAnaliza cada noticia cuidadosamente, busca pistas en las fuentes, el lenguaje usado y la credibilidad de la información antes de tomar tu decisión.';
      case 'stereotype_breaker':
        return 'Bienvenido al Parque de la Inclusión, un lugar donde todos deberían poder jugar y ser ellos mismos. Sin embargo, algunos estereotipos han creado barreras invisibles.\n\nTu misión es identificar estos estereotipos y transformarlos en oportunidades de inclusión, creando un espacio donde todos se sientan bienvenidos.';
      default:
        return 'Embárcate en una aventura digital donde cada decisión cuenta. Usa tu pensamiento crítico para navegar por los desafíos y aprender valiosas lecciones sobre el mundo digital.';
    }
  }

  String _getMotivationalQuestion(String activityType) {
    switch (activityType) {
      case 'word_path':
        return '¿Podrás ayudar a restaurar el bosque eligiendo las palabras correctas?';
      case 'fake_news':
        return '¿Tienes lo necesario para ser un detective de la verdad?';
      case 'stereotype_breaker':
        return '¿Puedes romper las barreras y crear un mundo más inclusivo?';
      default:
        return '¿Estás listo para el desafío?';
    }
  }

  String _getFooterText(String activityType) {
    switch (activityType) {
      case 'word_path':
        return 'Aprende a usar palabras que hacen crecer el bosque';
      case 'fake_news':
        return 'Desarrolla tu pensamiento crítico y detecta la desinformación';
      case 'stereotype_breaker':
        return 'Construye puentes de comprensión y respeto';
      default:
        return 'Una experiencia de aprendizaje única te espera';
    }
  }
}

class _WordChip extends StatelessWidget {
  final String text;
  final bool isPositive;

  const _WordChip({required this.text, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isPositive
            ? const Color(0xFFC9E090).withValues(alpha: 0.3)
            : const Color(0xFFFF8FA3).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPositive ? const Color(0xFFC9E090) : const Color(0xFFFF8FA3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isPositive ? const Color(0xFF10B981) : const Color(0xFFFF6B6B),
        ),
      ),
    );
  }
}
