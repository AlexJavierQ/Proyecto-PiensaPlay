import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class UnitCompletionScreen extends StatelessWidget {
  const UnitCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return const Scaffold(body: Center(child: Text('No se encontraron datos.')));
    }

    final unitData = args['unitData'] as Map<String, dynamic>? ?? {};
    final totalXP = args['totalXP'] as int? ?? 1250;
    final coinsEarned = args['coinsEarned'] as int? ?? 10;
    final badgeTitle = args['badgeTitle'] as String? ?? 'Investigador Junior';
    final badgeDesc = args['badgeDesc'] as String? ?? 'Detecta la desinformación y defiende la verdad.';
    final userId = args['userId'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF132757),
        elevation: 0,
        title: Text(
          unitData['title'] ?? 'Veracidadville',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Header Desafío - Completado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Desafío',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBDD87B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Completado',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Banner Amarillo de Felicitación
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF6E16B), width: 2),
              ),
              child: Stack(
                children: [
                  const Positioned(top: 0, left: 0, child: Icon(Icons.auto_awesome, size: 16, color: Colors.black)),
                  const Positioned(bottom: 0, right: 0, child: Icon(Icons.auto_awesome, size: 16, color: Colors.black)),
                  Center(
                    child: Text(
                      '¡Excelente trabajo! Has\ncompletado\n${unitData['title'] ?? 'VeracidadVille'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Mascota
            Center(
              child: Image.asset(
                'assets/image-removebg-preview 1.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // Texto Desbloqueado
            const Text(
              '¡Portal de la Verdad Desbloqueado!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF132757),
              ),
            ),

            const SizedBox(height: 16),

            // Icono de Llave
            const Icon(Icons.vpn_key_rounded, size: 60, color: Color(0xFFFFD700)),

            const SizedBox(height: 24),

            // Sección Recompensas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recompensas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF132757)),
                  ),
                  const SizedBox(height: 12),
                  // Card de Recompensas Azul
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132757),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFBDD87B), width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRewardItem('$totalXP', Icons.star_rounded, const Color(0xFF93C5FD), 'XP'),
                            _buildRewardItem('$coinsEarned', Icons.circle, const Color(0xFFFFD700), ''),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.hexagon_rounded, color: Color(0xFF132757), size: 35),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    badgeTitle,
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    badgeDesc,
                                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botones de navegación
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Inicio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5E7EB),
                        foregroundColor: const Color(0xFF132757),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/game_units', (r) => false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF132757),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Siguiente'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(String value, IconData icon, Color iconColor, String label) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 4),
        Icon(icon, color: iconColor, size: 24),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ]
      ],
    );
  }
}
