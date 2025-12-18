import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../utils/local_storage_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkSavedUser();
  }

  Future<void> _checkSavedUser() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final userData = await LocalStorageService.getUserData();
    if (userData != null && mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          'userId': userData['userId'],
          'userName': userData['userName'],
          'avatarIndex': int.tryParse(userData['userAvatar'] ?? '0') ?? 0,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppStyles.backgroundGradient),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Círculos decorativos normalizados
            _buildDecorativeCircle(top: -size.height * 0.1, left: -size.width * 0.2, color: AppStyles.accentGreen.withValues(alpha: 0.15), size: 300),
            _buildDecorativeCircle(bottom: -size.height * 0.1, right: -size.width * 0.1, color: AppStyles.lightBlue.withValues(alpha: 0.1), size: 250),
            
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.05),
                      // Mascota centralizada
                      _buildMascot(size.width * 0.45),
                      
                      SizedBox(height: AppStyles.spacingXLarge),
                      
                      const Text(
                        '¡Bienvenido a\nPiensaPlay!',
                        textAlign: TextAlign.center,
                        style: AppStyles.headingLarge,
                      ),
                      
                      const SizedBox(height: AppStyles.spacingMedium),
                      
                      const Text(
                        '¿Listo para aprender sobre\nmedios y seguridad digital?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      SizedBox(height: size.height * 0.08),
                      
                      // Botones normalizados y centrados
                      _buildMainButton(
                        label: 'Comenzar',
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        icon: Icons.play_arrow_rounded,
                        color: AppStyles.yellow,
                        textColor: AppStyles.primaryBlue,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildMainButton(
                        label: 'Ver Tutorial',
                        onPressed: () {},
                        icon: Icons.help_outline_rounded,
                        color: Colors.white.withValues(alpha: 0.2),
                        textColor: Colors.white,
                      ),
                      
                      SizedBox(height: size.height * 0.05),
                      
                      // Selector de idioma sutil
                      _buildLanguageSelector(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle({double? top, double? bottom, double? left, double? right, required Color color, required double size}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildMascot(double size) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size * 0.75,
          height: size * 0.75,
          decoration: BoxDecoration(
            color: const Color(0xFFBDD87B),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        Positioned(
          top: -size * 0.2,
          child: Image.asset(
            'assets/image-removebg-preview 1.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: 240,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 24, color: textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language, size: 18, color: Colors.white),
          SizedBox(width: 8),
          Text('Español', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }
}
