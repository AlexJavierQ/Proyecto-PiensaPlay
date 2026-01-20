import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';
import '../widgets/custom_bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final int avatarIndex;

  const SettingsScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.avatarIndex,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _avatarImages = [
    'assets/Vector.png',
    'assets/Vector (2).png',
    'assets/Vector (3).png',
    'assets/Vector (4).png',
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final displayAvatarIndex = args?['avatarIndex'] ?? widget.avatarIndex;
    final displayUserName = args?['userName'] ?? widget.userName;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF132757),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildProfileCard(displayUserName, displayAvatarIndex),
                const SizedBox(height: 24),
                _buildTagCard(displayUserName),
                const SizedBox(height: 32),
                _buildSectionTitle('Ajustes de Juego'),
                _buildSettingsTile(Icons.notifications_active_rounded, 'Notificaciones', true),
                _buildSettingsTile(Icons.volume_up_rounded, 'Sonidos', true),
                const SizedBox(height: 32),
                _buildSectionTitle('Seguridad'),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseService.getUserStream(widget.userId),
                  builder: (context, snapshot) {
                    bool isLinked = false;
                    String? email;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      isLinked = data['authUid'] != null && data['email'] != null;
                      email = data['email'];
                    }

                    if (isLinked) {
                      return _buildActionTile(
                        Icons.verified_user_rounded, 
                        'Correo Vinculado\n${email ?? ""}', 
                        AppStyles.accentGreen, 
                        () {},
                      );
                    }
                    
                    return _buildActionTile(
                      Icons.email_rounded, 
                      'Vincular Correo', 
                      AppStyles.primaryBlue, 
                      () => _showLinkEmailDialog(context),
                    );
                  },
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('Cuenta'),
                _buildActionTile(Icons.logout_rounded, 'Cerrar Sesión', Colors.redAccent, () => _handleLogout(context)),
                _buildDevZone(context), // Zona de desarrollo añadida
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildProfileCard(String name, int avatarIdx) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppStyles.limeGreen, width: 3),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFF0F7FF),
            backgroundImage: AssetImage(_avatarImages[avatarIdx % _avatarImages.length]),
          ),
          const SizedBox(height: 16),
          Text(name.split('#').first, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF132757))),
          const Text('Explorador de PiensaPlay', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTagCard(String fullName) {
    final tag = fullName.contains('#') ? fullName.split('#').last : '000000';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppStyles.primaryBlue, Color(0xFF1E3A8A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppStyles.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TU CÓDIGO DE AVENTURERO',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fullName.contains('#') ? fullName : '$fullName#$tag',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: fullName));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('¡Código completo copiado: $fullName! 📋'),
                        backgroundColor: AppStyles.accentGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('COPIAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Share.share('¡Hola! Mi código en PiensaPlay es #$tag. ¡Únete a la aventura conmigo!');
                  },
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('COMPARTIR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.yellow,
                    foregroundColor: AppStyles.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF132757))),
    );
  }

  Widget _buildSettingsTile(IconData icon, String label, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF132757)),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Switch(value: value, onChanged: (v) {}, activeColor: const Color(0xFFBDD87B)),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildDevZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16, top: 32),
          child: Text('Zona de Desarrollo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        _buildActionTile(Icons.code, 'Logs de Errores', Colors.grey, () {}),
        GestureDetector(
          onTap: () => _confirmReset(context),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.delete_forever_rounded, color: Colors.red),
                const SizedBox(width: 16),
                const Text('Resetear DB & Sembrar Datos', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Zona de Peligro'),
        content: const Text('Esto borrará TODAS las unidades, clases y glosario, y creará datos de prueba nuevos. ¿Estás seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reiniciando base de datos... Espere...')),
              );
              await FirebaseService.resetAndSeedData();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Datos reiniciados con éxito')),
              );
            },
            child: const Text('¡Borrar y Reiniciar!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar Sesión?'),
        content: const Text('Tendrás que ingresar tus datos nuevamente para jugar.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseService.logout();
      await LocalStorageService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  void _showLinkEmailDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool isLinking = false;
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Vincular Correo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Asegura tu cuenta vinculando un correo electrónico para recuperar tu acceso.', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 16),
              if (errorMsg != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: Text(errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico', prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(labelText: 'Confirmar Contraseña', prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLinking ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLinking ? null : () async {
                if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                  setState(() => errorMsg = 'Completa todos los campos');
                  return;
                }
                if (passwordController.text != confirmController.text) {
                  setState(() => errorMsg = 'Las contraseñas no coinciden');
                  return;
                }
                if (passwordController.text.length < 6) {
                  setState(() => errorMsg = 'La contraseña debe tener al menos 6 caracteres');
                  return;
                }

                setState(() {
                  isLinking = true;
                  errorMsg = null;
                });

                try {
                  await FirebaseService.linkEmailToCurrentAccount(
                    email: emailController.text.trim(),
                    password: passwordController.text,
                    currentUserId: widget.userId,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Correo vinculado exitosamente!'), backgroundColor: AppStyles.accentGreen),
                    );
                  }
                } catch (e) {
                  setState(() {
                    isLinking = false;
                    errorMsg = e.toString().replaceAll('Exception: ', '');
                  });
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryBlue),
              child: isLinking 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Vincular', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
