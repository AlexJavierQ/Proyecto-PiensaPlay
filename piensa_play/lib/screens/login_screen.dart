import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
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
    for (var i = 0; i < 8; i++) {
      final candidate = code();
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('tag', isEqualTo: candidate)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) return candidate;
    }
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear Perfil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppStyles.primaryBlue, AppStyles.backgroundLight],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Icono centralizado
              _buildProfileHeader(),
              
              const SizedBox(height: 32),
              
              const Text(
                '¡Cuéntanos sobre ti!',
                style: AppStyles.headingMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Formulario normalizado
              _buildFormCard(),
              
              const SizedBox(height: 32),
              
              const Text(
                '¡Elige tu Avatar!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.primaryBlue,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Grid de avatares centrado
              _buildAvatarGrid(),
              
              const SizedBox(height: 40),
              
              // Existing user login
              const Text(
                '¿Ya tienes un perfil?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              _buildTagLoginCard(),
              
              const SizedBox(height: 32),
              
              // Botón de acción principal
              _buildSubmitButton(),
              
              const SizedBox(height: 24),
              
              // Acceso para tutores centrado
              _buildTutorLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Image.asset('assets/image 2.png', width: 80, height: 80, fit: BoxFit.contain),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppStyles.yellow.withValues(alpha: 0.5), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            hintText: '¿Cómo te llamas?',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ageController,
            hintText: '¿Cuántos años tienes?',
            icon: Icons.cake_rounded,
            isNumber: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyles.inputBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppStyles.primaryBlue),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: AppStyles.primaryBlue, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAvatarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: _avatarImages.length,
      itemBuilder: (context, index) {
        final isSelected = _selectedAvatar == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedAvatar = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppStyles.yellow : Colors.transparent,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? AppStyles.yellow.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(_avatarImages[index], fit: BoxFit.contain),
          ),
        );
      },
    );
  }

  Widget _buildTagLoginCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppStyles.yellow.withValues(alpha: 0.5), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _tagController,
            hintText: 'Ingresa tu tag (ej: 123456)',
            icon: Icons.tag,
            isNumber: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleTagLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 4,
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'INICIAR SESIÓN',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyles.accentGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 4,
          shadowColor: AppStyles.accentGreen.withValues(alpha: 0.4),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                '¡EMPEZAR AVENTURA!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2),
              ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_nameController.text.isEmpty || _ageController.text.isEmpty) {
      _showError('Por favor, completa tus datos');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final tag = await _generateUniqueCode();
      final name = _nameController.text.trim();
      final userData = {
        'name': name,
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'avatarIndex': _selectedAvatar,
        'tag': tag,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final id = await FirebaseService.createUser(userData);
      if (id != null) {
        await LocalStorageService.saveUserData(
          userId: id,
          userName: '$name#$tag',
          userAvatar: _selectedAvatar.toString(),
        );

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home', arguments: {
          'userId': id,
          'userName': '$name#$tag',
          'avatarIndex': _selectedAvatar,
          'userTag': tag,
        });
      }
    } catch (e) {
      _showError('Hubo un problema: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleTagLogin() async {
    if (_tagController.text.isEmpty) {
      _showError('Por favor, ingresa tu tag');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userData = await FirebaseService.getUserByTag(_tagController.text.trim());
      if (userData != null) {
        final id = userData['id'];
        final name = userData['name'];
        final tag = userData['tag'];
        final avatarIndex = userData['avatarIndex'] ?? 0;

        await LocalStorageService.saveUserData(
          userId: id,
          userName: '$name#$tag',
          userAvatar: avatarIndex.toString(),
        );

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home', arguments: {
          'userId': id,
          'userName': '$name#$tag',
          'avatarIndex': avatarIndex,
          'userTag': tag,
        });
      } else {
        _showError('Tag no encontrado. Verifica e intenta de nuevo.');
      }
    } catch (e) {
      _showError('Hubo un problema: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildTutorLink() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/tutor_login'),
      child: RichText(
        text: const TextSpan(
          text: '¿Eres profesor? ',
          style: TextStyle(color: AppStyles.textLight, fontSize: 16),
          children: [
            TextSpan(
              text: 'Inicia sesión aquí',
              style: TextStyle(color: AppStyles.primaryBlue, fontWeight: FontWeight.bold),
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
    _tagController.dispose();
    super.dispose();
  }
}
