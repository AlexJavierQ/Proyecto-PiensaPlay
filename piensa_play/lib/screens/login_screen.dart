import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  int _selectedAvatar = 0;

  final List<String> _avatarImages = [
    'assets/Vector.png',
    'assets/Vector (2).png',
    'assets/Vector (3).png',
    'assets/Vector (4).png',
  ];

  bool _isSaving = false;

  Future<String> _generateUniqueCode() async {
    final rand = Random();
    String code() => List.generate(6, (_) => rand.nextInt(10).toString()).join();
    // Intenta hasta 8 veces para evitar colisiones (probabilidad muy baja).
    for (var i = 0; i < 8; i++) {
      final candidate = code();
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('tag', isEqualTo: candidate)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) return candidate;
    }
    // Si todas fallan, devuelve uno sin comprobar (extremadamente improbable).
    return code();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '¡Conócete!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Logo circular con sombra
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                'assets/image 2.png',
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Título
            const Text(
              '¡Cuéntanos sobre ti!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppStyles.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Formulario con borde dorado
            Container(
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppStyles.yellow, // Borde dorado
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Para personalizar tu aventura:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppStyles.textDark,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Campo de nombre con estilo específico
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: AppStyles.inputBackground, // Azul claro
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: '¿Cómo te llamas?',
                        hintStyle: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, 
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Campo de edad con estilo específico
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: AppStyles.inputBackground, // Azul claro
                    ),
                    child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '¿Cuántos años tienes?',
                        hintStyle: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, 
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Selección de avatar
            const Text(
              '¡Elige tu Avatar!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppStyles.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: _avatarImages.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedAvatar == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(color: AppStyles.primaryBlue, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppStyles.primaryBlue.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                                spreadRadius: 1,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        _avatarImages[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Botón de continuar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () async {
                  if (_nameController.text.isNotEmpty && _ageController.text.isNotEmpty) {
                    setState(() { _isSaving = true; });
                    try {
                      final tag = await _generateUniqueCode();
                      final userData = {
                        'name': _nameController.text.trim(),
                        'age': int.tryParse(_ageController.text.trim()) ?? 0,
                        'avatarIndex': _selectedAvatar,
                        'createdAt': DateTime.now().toIso8601String(),
                        'tag': tag,
                      };

                      final id = await FirebaseService.createUser(userData);
                      if (id != null) {
                        // Navegar a HomeScreen
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          '/home',
                          arguments: {
                            'userId': id,
                            'userName': '${_nameController.text.trim()}#$tag',
                            'avatarIndex': _selectedAvatar,
                            'userTag': tag,
                          },
                        );
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al crear usuario')),
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    } finally {
                      if (mounted) setState(() { _isSaving = false; });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor completa todos los campos'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '¡A Jugar!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Texto informativo
            const Text(
              'Solo usamos esta información para personalizar tu experiencia.',
              style: TextStyle(
                color: AppStyles.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Botón "Soy Tutor"
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/tutor_login');
              },
              child: const Text(
                'Soy Tutor',
                style: TextStyle(
                  color: AppStyles.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}