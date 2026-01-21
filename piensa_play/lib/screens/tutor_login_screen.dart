import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';

class TutorLoginScreen extends StatefulWidget {
  const TutorLoginScreen({super.key});

  @override
  State<TutorLoginScreen> createState() => _TutorLoginScreenState();
}

class _TutorLoginScreenState extends State<TutorLoginScreen>
    with SingleTickerProviderStateMixin {
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isLogin = true;
  
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart));
    
    _animController.forward();
  }

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();
    final email = _emailController.text.trim();
    
    setState(() => _isLoading = true);
    
    try {
      if (_isLogin) {
        // LOGIN
        if (email.isEmpty || pass.isEmpty) {
          _showErrorSnackBar('Por favor ingresa correo y contraseña');
          return;
        }

        final tutorData = await FirebaseService.validateTutor(email, pass);
        
        if (tutorData != null && mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/tutor_dashboard',
            arguments: {
              'tutorId': tutorData['id'] ?? 'demo_tutor',
              'tutorName': tutorData['name'] ?? 'Tutor',
            },
          );
        } else if (mounted) {
          _showErrorSnackBar('Credenciales incorrectas');
        }
      } else {
        // REGISTER
        final email = _emailController.text.trim();
        final confirmPass = _confirmPassController.text.trim();

        if (user.isEmpty || pass.isEmpty || email.isEmpty || confirmPass.isEmpty) {
          _showErrorSnackBar('Por favor completa todos los campos');
          return;
        }

        if (pass != confirmPass) {
          _showErrorSnackBar('Las contraseñas no coinciden');
          return;
        }
        
        if (!email.contains('@')) {
          _showErrorSnackBar('Ingresa un correo válido');
          return;
        }

        try {
          final newTutor = await FirebaseService.createTutor(user, pass, email);
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/tutor_dashboard',
              arguments: {
                'tutorId': newTutor['id'],
                'tutorName': newTutor['name'],
              },
            );
          }
        } catch (e) {
          // Check for specific error message
          final msg = e.toString().contains('existe') 
              ? 'El usuario o correo ya existe' 
              : 'Error al crear cuenta: ${e.toString().replaceAll("Exception: ", "")}';
          if (mounted) _showErrorSnackBar(msg);
        }
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppStyles.coral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: AppStyles.backgroundLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppStyles.primaryBlue, AppStyles.backgroundLight],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header con botón de regreso
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Acceso Tutor',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                SizedBox(height: size.height * 0.04),
                
                // Icono animado
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (_fadeAnimation.value * 0.2),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildLogoSection(),
                ),
                
                SizedBox(height: size.height * 0.05),
                
                // Formulario con animación
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: _buildLoginForm(size),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withValues(alpha: 0.9),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 60,
            color: AppStyles.primaryBlue,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Panel Educativo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gestiona contenido educativo\npara tus estudiantes',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppStyles.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título del formulario
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppStyles.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  color: AppStyles.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppStyles.darkBlue,
                    ),
                  ),
                  Text(
                    'Ingresa tus credenciales',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppStyles.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Campo de usuario (Solo Registro)
          if (!_isLogin) ...[
             _buildInputField(
              controller: _userController,
              hint: 'Nombre de Usuario',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),
          ],
          
          // Campo de Correo (Login y Registro)
          _buildInputField(
            controller: _emailController,
            hint: 'Correo Electrónico',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 16),
          
          // Campo de contraseña
          _buildInputField(
            controller: _passController,
            hint: 'Contraseña',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
          ),

          if (!_isLogin) ...[
            const SizedBox(height: 16),
            _buildInputField(
              controller: _confirmPassController,
              hint: 'Confirmar Contraseña',
              icon: Icons.lock_reset_rounded,
              isPassword: true,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Recordar sesión
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: false,
                  onChanged: (v) {},
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  activeColor: AppStyles.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Recordar mi sesión',
                style: TextStyle(
                  fontSize: 14,
                  color: AppStyles.textLight,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Botón de login
          Container(
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppStyles.primaryBlue, AppStyles.mediumBlue],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppStyles.primaryBlue.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? 'INGRESAR' : 'CREAR CUENTA',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Toggle Login/Register
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isLogin = !_isLogin;
                  _animController.reset();
                  _animController.forward();
                });
              },
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: AppStyles.textLight),
                  children: [
                    TextSpan(text: _isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes cuenta? '),
                    TextSpan(
                      text: _isLogin ? 'Regístrate' : 'Inicia Sesión',
                      style: const TextStyle(
                        color: AppStyles.primaryBlue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Credenciales de demo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppStyles.limeGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppStyles.accentGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppStyles.accentGreen,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credenciales de prueba',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppStyles.accentGreen,
                        ),
                      ),
                      Text(
                        'Usuario: admin | Contraseña: 123456',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppStyles.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyles.inputBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppStyles.borderGray.withValues(alpha: 0.5),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppStyles.darkBlue,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppStyles.textLight.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: AppStyles.primaryBlue, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppStyles.textLight,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
