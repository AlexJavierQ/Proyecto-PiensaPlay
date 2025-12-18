import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final unitData = args['unitData'] as Map<String, dynamic>;
    final unitId = args['unitId'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF132757),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          unitData['title'] ?? 'Detalle de Unidad',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Título principal entre comillas
                  Text(
                    '"${unitData['highlightedTitle'] ?? 'Cazadores de Noticias Falsas'}"',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF132757),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Subtítulo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      unitData['subtitle'] ?? '¿Estás listo para convertirte en un detective digital?',
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Contenedor de Imagen
                  _buildImageContainer(),

                  const SizedBox(height: 32),

                  // Descripción "Bienvenido a..."
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido a ${unitData['title'] ?? 'Veracidadville'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF132757),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          unitData['introduction'] ?? 
                          'Un mundo digital sobrecargado de información donde todo parece confuso: titulares exagerados, imágenes contradictorias y mensajes virales.',
                          style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 15, color: Colors.black, height: 1.5),
                            children: [
                              const TextSpan(text: 'Tu misión: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: unitData['mission'] ?? 'Navegar el "Laberinto de la Veracidad" tomando decisiones informadas.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Dinámica del juego
                  _buildDynamicsSection(unitData),

                  const SizedBox(height: 32),

                  // Habilidades que desarrollarás
                  _buildSkillsSection(unitData),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Botón fijo inferior (Sobre fondo blanco ahora)
          _buildStartButton(context, unitId, unitData),
        ],
      ),
    );
  }

  Widget _buildImageContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/image-removebg-preview 1.png',
            fit: BoxFit.contain,
            width: 150,
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicsSection(Map<String, dynamic> data) {
    final dynamics = (data['gameDynamics'] as List?)?.cast<String>() ?? [
      'Analiza titulares y determina si son reales o exagerados',
      'Examina imágenes para descubrir si han sido manipuladas',
      'Investiga mensajes virales y evalúa su credibilidad',
    ];

    final colors = [const Color(0xFFFFD700), const Color(0xFFBDD87B), const Color(0xFFF9879B)];
    final icons = [Icons.sd_card_rounded, Icons.image_rounded, Icons.share_rounded];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dinámica del juego',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF132757)),
          ),
          const SizedBox(height: 16),
          ...List.generate(dynamics.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(icons[index % icons.length], color: colors[index % colors.length], size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                        child: Text(
                          dynamics[index],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(Map<String, dynamic> data) {
    final skills = (data['skills'] as List?)?.cast<String>() ?? [
      'Pensamiento crítico',
      'Verificación de datos',
      'Análisis de fuentes',
      'Seguridad digital',
    ];

    final skillIcons = [Icons.search, Icons.check_rounded, Icons.lightbulb_rounded, Icons.shield_rounded];
    final skillColors = [const Color(0xFF001F3F), const Color(0xFFFFD700), const Color(0xFFBDD87B), const Color(0xFFF9879B)];
    final bgColors = [const Color(0xFFE8EDF2), const Color(0xFFFFF9C4), const Color(0xFFE8F5E9), const Color(0xFFFFE4EC)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habilidades que desarrollarás',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF132757)),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: bgColors[index % bgColors.length],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: skillColors[index % skillColors.length],
                      radius: 24,
                      child: Icon(skillIcons[index % skillIcons.length], size: 24, color: index == 0 ? Colors.white : const Color(0xFF132757)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      skills[index],
                      style: const TextStyle(color: Color(0xFF132757), fontSize: 13, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, String? unitId, Map<String, dynamic> unitData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/game_activities_map',
              arguments: {
                'unitId': unitId,
                'unitData': unitData,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003366),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Comenzar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
