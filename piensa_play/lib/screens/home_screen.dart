import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/piensa_app_bar.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final int avatarIndex;
  final String userTag;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.avatarIndex,
    required this.userTag,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _gridController;
  late Animation<double> _heroScale;
  late Animation<double> _heroFade;
  
  final List<String> avatarImages = [
    'assets/Vector.png',
    'assets/Vector (2).png',
    'assets/Vector (3).png',
    'assets/Vector (4).png',
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }
  
  void _initAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _heroScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutBack),
    );
    
    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );
    
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Iniciar animaciones
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _heroController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _gridController.forward();
    });
  }
  
  @override
  void dispose() {
    _heroController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: PiensaAppBar(
        title: 'PiensaPlay',
        showBackButton: false,
        actions: [
          _buildPointsIndicator(),
          const SizedBox(width: 8),
          _buildAvatarButton(),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo personalizado
            _buildGreeting(),
            const SizedBox(height: 20),
            
            // Hero Card animado
            AnimatedBuilder(
              animation: _heroController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _heroScale.value,
                  child: Opacity(
                    opacity: _heroFade.value,
                    child: child,
                  ),
                );
              },
              child: _buildHeroActionCard(),
            ),
            
            const SizedBox(height: 32),
            
            // Título de sección
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppStyles.yellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: AppStyles.yellow,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tus Misiones',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF132757),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Grid de opciones con animación staggered
            _buildAnimatedGrid(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;
    
    if (hour < 12) {
      greeting = '¡Buenos días';
      icon = Icons.wb_sunny_rounded;
    } else if (hour < 18) {
      greeting = '¡Buenas tardes';
      icon = Icons.wb_cloudy_rounded;
    } else {
      greeting = '¡Buenas noches';
      icon = Icons.nightlight_round;
    }
    
    final name = widget.userName.split('#').first;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppStyles.yellow, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$greeting, $name! 👋',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppStyles.slateText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: widget.userName));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tag copiado al portapapeles!'),
                duration: Duration(seconds: 2),
                backgroundColor: AppStyles.primaryBlue,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppStyles.primaryBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.badge_outlined, size: 14, color: AppStyles.primaryBlue.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppStyles.primaryBlue.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.copy_rounded, size: 12, color: AppStyles.primaryBlue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsIndicator() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.getUserStream(widget.userId),
      builder: (context, snapshot) {
        int points = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          points = data?['walletBalance'] as int? ?? 0;
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppStyles.yellow, size: 18),
              const SizedBox(width: 4),
              Text(
                '$points',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppStyles.darkBlue,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/settings'),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseService.getUserStream(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final equipped = data?['equipped_avatar'] as String?;
              
              if (equipped != null && equipped.startsWith('avatar_')) {
                IconData icon = Icons.face;
                Color color = Colors.blue;
                
                if (equipped.contains('cyber')) { icon = Icons.security; color = Colors.blue; }
                else if (equipped.contains('detective')) { icon = Icons.search; color = Colors.amber; }
                else if (equipped.contains('ninja')) { icon = Icons.visibility_off; color = Colors.black; }
                else if (equipped.contains('artist')) { icon = Icons.palette; color = Colors.pink; }
                
                return Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppStyles.yellow, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(icon, color: color, size: 20),
                  ),
                );
              }
            }
            
            return Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppStyles.yellow, width: 2),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(avatarImages[widget.avatarIndex % avatarImages.length]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroActionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132757).withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: const Color(0xFFF6E16B), width: 3),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Mascota con efecto de brillo
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBDD87B).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Image.asset(
                    'assets/image-removebg-preview 1.png',
                    width: 70,
                    height: 70,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppStyles.accentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🎯 SIGUIENTE MISIÓN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppStyles.accentGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Detective de Noticias',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF132757),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aprende a detectar información falsa',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Botón con efecto de gradiente y sombra
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFBDD87B), Color(0xFFA8D15A)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBDD87B).withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/game_units'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¡CONTINUAR AVENTURA!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF132757),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132757).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF132757),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGrid() {
    final menuItems = [
      _MenuItem(
        title: 'Explorar',
        subtitle: 'Juegos libres',
        icon: Icons.explore_rounded,
        color: const Color(0xFFBDD87B),
        route: '/game_units',
      ),
      _MenuItem(
        title: 'Mis Clases',
        subtitle: 'Cursos asignados',
        icon: Icons.school_rounded,
        color: const Color(0xFFA78BFA),
        route: '/student_classes',
      ),
      _MenuItem(
        title: 'Glosario',
        subtitle: 'Palabras mágicas',
        icon: Icons.auto_stories_rounded,
        color: const Color(0xFFFFD700),
        route: '/glossary',
      ),
      _MenuItem(
        title: 'Mi Progreso',
        subtitle: 'Tus trofeos',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFF9C0D0),
        route: '/progress',
      ),
      _MenuItem(
        title: 'Tienda',
        subtitle: 'Tus Premios',
        icon: Icons.store_mall_directory_rounded,
        color: const Color(0xFFFFCC80),
        route: '/rewards_shop',
      ),
      _MenuItem(
        title: 'Ajustes',
        subtitle: 'Tu perfil',
        icon: Icons.settings_rounded,
        color: const Color(0xFF93C5FD),
        route: '/settings',
      ),
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.05,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _gridController,
          builder: (context, child) {
            final delay = index * 0.15;
            final progress = ((_gridController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
            
            return Transform.translate(
              offset: Offset(0, 30 * (1 - progress)),
              child: Opacity(
                opacity: progress,
                child: child,
              ),
            );
          },
          child: _buildMenuCard(context, menuItems[index]),
        );
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, _MenuItem item) {
    return GestureDetector(
      onTap: () {
        // Pasar argumentos necesarios según la ruta
        Map<String, dynamic>? args;
        if (item.route == '/student_classes') {
          args = {'userId': widget.userId, 'userName': widget.userName};
        } else if (item.route == '/rewards_shop') {
          args = {'userId': widget.userId};
        } else if (item.route == '/settings' || item.route == '/progress') {
          args = {
            'userId': widget.userId,
            'userName': widget.userName,
            'avatarIndex': widget.avatarIndex,
          };
        }
        Navigator.pushNamed(context, item.route, arguments: args);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              item.color,
              Color.lerp(item.color, Colors.white, 0.15)!,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: 32,
                color: const Color(0xFF132757),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF132757),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF132757).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  
  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
