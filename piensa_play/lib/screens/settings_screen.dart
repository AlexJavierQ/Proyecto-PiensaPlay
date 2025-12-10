import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

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
  bool _notifications = true;
  bool _soundEffects = true;
  bool _backgroundMusic = false;

  final List<String> _avatarImages = [
    'assets/Vector.png',
    'assets/Vector (2).png',
    'assets/Vector (3).png',
    'assets/Vector (4).png',
  ];

  @override
  Widget build(BuildContext context) {
    // Extract arguments from route if provided
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final displayAvatarIndex = args?['avatarIndex'] ?? widget.avatarIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        title: const Text('Ajustes'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD7EDB2), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar with green ring
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9E090),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        _avatarImages[displayAvatarIndex],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Jugador',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                // Edit button
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to edit profile
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6E16B),
                    foregroundColor: AppStyles.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Preferencias Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preferencias',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildToggleRow('Notificaciones', _notifications, (val) {
                  setState(() => _notifications = val);
                }),
                const Divider(height: 24),
                _buildToggleRow('Efectos de sonido', _soundEffects, (val) {
                  setState(() => _soundEffects = val);
                }),
                const Divider(height: 24),
                _buildToggleRow('Música de fondo', _backgroundMusic, (val) {
                  setState(() => _backgroundMusic = val);
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // General Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'General',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextRow('Política de privacidad', null),
                const Divider(height: 24),
                _buildTextRow('Términos de servicio', null),
                const Divider(height: 24),
                _buildTextRow('Idioma', 'Español'),
                const Divider(height: 24),
                _buildTextRow('Versión de la App', '1.0.0'),
                const Divider(height: 24),
                InkWell(
                  onTap: () {
                    // TODO: Implement logout
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.popUntil(context, (route) => route.isFirst);
                            },
                            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppStyles.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(current: 2),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppStyles.primaryBlue,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFFC9E090),
          activeTrackColor: const Color(0xFFD7EDB2),
        ),
      ],
    );
  }

  Widget _buildTextRow(String label, String? trailing) {
    return InkWell(
      onTap: () {
        // TODO: Handle navigation
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppStyles.primaryBlue,
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int current;
  const _BottomNavBar({required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppStyles.primaryBlue,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.home,
            label: 'Inicio',
            selected: current == 0,
            onTap: () {
              // Pop until we reach the home route
              Navigator.of(context).popUntil((route) => route.settings.name == '/home');
            },
          ),
          _NavItem(
            icon: Icons.menu_book,
            label: 'Glosario',
            selected: current == 1,
            onTap: () {
              // Pop current screen and push glossary
              Navigator.pop(context);
              Navigator.pushNamed(context, '/glossary');
            },
          ),
          _NavItem(
            icon: Icons.settings,
            label: 'Ajustes',
            selected: current == 2,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
