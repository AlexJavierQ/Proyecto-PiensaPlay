import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF132757), // Color exacto del prototipo
              Color(0xFF132757),  // Azul final
            ],
          ),
        ),
        child: Stack(
          children: [
            // Formas decorativas del fondo más sutiles y mejor posicionadas
            // Círculo superior izquierda - verde grande
            Positioned(
              top: -screenHeight * 0.12,
              left: -screenWidth * 0.35,
              child: Container(
                width: screenWidth * 0.85,
                height: screenWidth * 0.85,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12), 
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Círculo superior derecha - cyan
            Positioned(
              top: screenHeight * 0.05,
              right: -screenWidth * 0.45,
              child: Container(
                width: screenWidth * 1.0,
                height: screenWidth * 1.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Círculo medio izquierda - azul claro
            Positioned(
              top: screenHeight * 0.35,
              left: -screenWidth * 0.25,
              child: Container(
                width: screenWidth * 0.6,
                height: screenWidth * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Círculo inferior - verde mediano
            Positioned(
              bottom: -screenHeight * 0.15,
              left: -screenWidth * 0.15,
              child: Container(
                width: screenWidth * 0.9,
                height: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Círculo inferior derecha - blanco sutil
            Positioned(
              bottom: -screenHeight * 0.25,
              right: -screenWidth * 0.3,
              child: Container(
                width: screenWidth * 1.1,
                height: screenWidth * 1.1,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Círculo pequeño superior centro - accent
            Positioned(
              top: screenHeight * 0.15,
              right: screenWidth * 0.15,
              child: Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Contenido principal
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                      left: 32.0,
                      right: 32.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Spacer para empujar contenido hacia el centro
                        SizedBox(height: screenHeight * 0.06),
                        
                        // Logo/Mascota con círculo verde - las orejas sobresalen
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none, // Permite que las orejas sobresalgan
                          children: [
                            // Círculo verde de fondo

                            // donde puedo editar la posicion de circulo? quiero bajar un poco el circulo
                            

                            Container(
                              width: screenWidth * 0.34,
                              height: screenWidth * 0.34,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(189, 216, 123, 1), // Verde exacto del prototipo
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            // Mascota posicionada para que las orejas sobresalgan
                            Positioned(
                              top: -screenWidth * 0.09, // Subir la mascota para que las orejas sobresalgan
                              child: Image.asset(
                                'assets/image-removebg-preview 1.png',
                                width: screenWidth * 0.45, // Más grande para que las orejas sobresalgan
                                height: screenWidth * 0.45,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: screenHeight * 0.04),
                        
                        // Título de bienvenida
                        const Text(
                          '¡Bienvenido a\nPiensaPlay!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800, // Más bold
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Subtítulo
                        const Text(
                          '¿Listo para aprender sobre\nmedios y seguridad digital?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            height: 1.4,
                            letterSpacing: 0.2,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.06),
                        
                        // Botón Comenzar - exacto al prototipo
                        Container(
                          width: 220,
                          height: 56,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF6E16B), // Amarillo exacto
                              foregroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Comenzar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E3A8A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF1E3A8A),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Botón Ver Tutorial - verde exacto
                        Container(
                          width: 220,
                          height: 56,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Implementar navegación al tutorial
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(160, 230, 157, 0.5), // Verde exacto
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text(
                              'Ver Tutorial',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.03),
                        
                        // Selector de idioma - más sutil
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.language,
                                  size: 16,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Español',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}