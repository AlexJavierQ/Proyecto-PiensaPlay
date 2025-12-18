import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';

class FakeNewsDetectorScreen extends StatefulWidget {
  const FakeNewsDetectorScreen({super.key});

  @override
  State<FakeNewsDetectorScreen> createState() => _FakeNewsDetectorScreenState();
}

class _FakeNewsDetectorScreenState extends State<FakeNewsDetectorScreen> {
  bool _isAnswered = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final unitData = args?['unitData'] as Map<String, dynamic>? ?? {};
    final activityData = args?['activityData'] as Map<String, dynamic>? ?? {};
    final String unitId = args?['unitId'] ?? '';

    final String postAuthor = activityData['author'] ?? '@SuperSaludable';
    final String postTitle = activityData['title'] ?? '¡CURA MÁGICA PARA EL RESFRIADO!';
    final String postContent = activityData['content'] ?? 'Científicos descubren que beber agua con limón y miel ¡ELIMINA INSTANTÁNEAMENTE CUALQUIER VIRUS! Compartir con todos tus contactos para protegerlos. 🍋✨';
    final String postFooter = activityData['footer'] ?? '¡Comparte ahora o podrías enfermar en las próximas 24 horas! 😱';
    final List<dynamic> clues = activityData['clues'] ?? [
      'Lenguaje exagerado: "ELIMINA INSTANTÁNEAMENTE"',
      'Amenaza o presión: "Compartir o podrías enfermar"',
      'Falta de fuentes científicas verificables',
      'Uso de mayúsculas y signos de exclamación excesivos',
    ];
    final bool isReal = activityData['isReal'] ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF132757),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          unitData['title'] ?? 'Veracidadville',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSubHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildWelcomeBox(activityData['instructions'] ?? 'Tu misión es detectar noticias falsas analizando pistas como la fuente, tono, lenguaje emocional o exagerado.'),
                  const SizedBox(height: 24),
                  _buildSocialPost(postAuthor, postTitle, postContent, postFooter),
                  const SizedBox(height: 24),
                  _buildClueSection(clues),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildActionButtons(isReal, unitData, activityData, unitId),
          const SizedBox(height: 20),
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
            child: const Text(
              'Detecta Fake News',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF132757)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBox(String instructions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
      ),
      child: Text(
        instructions,
        style: const TextStyle(fontSize: 14, color: Color(0xFF132757), height: 1.4, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSocialPost(String author, String title, String content, String footer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF132757), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 20, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('Hace 2 horas', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFF6E16B).withOpacity(0.8),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFF9879B)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF132757), height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFF132757), width: 1.5),
                      ),
                      child: const Center(child: Icon(Icons.image_search_rounded, size: 60, color: Color(0xFFF6E16B))),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF132757),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
                ),
                child: Text(
                  footer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          Positioned(
            top: -15,
            right: -10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFF9879B), shape: BoxShape.circle),
              child: const Text('¡NUEVO!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClueSection(List<dynamic> clues) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF132757), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PISTAS A DETECTAR:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF3B82F6), fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          ...clues.map((clue) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFF9879B), size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(clue.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF132757)))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isReal, Map<String, dynamic> unitData, Map<String, dynamic> activityData, String unitId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildAnswerButton('Falso', const Color(0xFFF9879B), Icons.block_rounded, () => _handleAnswer(false, isReal, unitData, activityData, unitId))),
          const SizedBox(width: 16),
          Expanded(child: _buildAnswerButton('Verdadero', const Color(0xFFA0E69D), Icons.check_rounded, () => _handleAnswer(true, isReal, unitData, activityData, unitId))),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isAnswered ? null : onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white, size: 24), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Future<void> _handleAnswer(bool userAnswer, bool isReal, Map<String, dynamic> unitData, Map<String, dynamic> activityData, String unitId) async {
    if (_isAnswered) return;
    setState(() => _isAnswered = true);
    
    final bool isCorrect = userAnswer == isReal;
    final activityId = activityData['id'] ?? 'temp_activity';
    
    // 1. Obtener ID de usuario
    final userData = await LocalStorageService.getUserData();
    final userId = userData?['userId'] ?? 'anonymous';

    // 2. Guardar progreso en Firebase
    await FirebaseService.saveGameProgress(userId, unitId, activityId, {
      'isCorrect': isCorrect,
      'score': isCorrect ? 100 : 0,
      'completed': true,
    });
    
    // 3. Navegación ÚNICA y LIMPIA
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/activity_completion', arguments: {
      'unitData': unitData,
      'activityData': activityData,
      'unitId': unitId,
      'correctAnswers': isCorrect ? 1 : 0,
      'incorrectAnswers': isCorrect ? 0 : 1,
      'finalScore': isCorrect ? 100.0 : 0.0,
      'userId': userId,
    });
  }
}
