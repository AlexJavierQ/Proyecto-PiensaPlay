import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
                const SizedBox(height: 32),
                _buildSectionTitle('Ajustes de Juego'),
                _buildSettingsTile(Icons.notifications_active_rounded, 'Notificaciones', true),
                _buildSettingsTile(Icons.volume_up_rounded, 'Sonidos', true),
                const SizedBox(height: 32),
                _buildSectionTitle('Cuenta'),
                _buildActionTile(Icons.logout_rounded, 'Cerrar Sesión', Colors.redAccent, () => _handleLogout(context)),
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
        border: Border.all(color: const Color(0xFFBDD87B), width: 3),
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
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF132757))),
          const Text('Explorador de PiensaPlay', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar Sesión?'),
        content: const Text('Tendrás que volver a ingresar tus datos para jugar.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await LocalStorageService.logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            },
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
