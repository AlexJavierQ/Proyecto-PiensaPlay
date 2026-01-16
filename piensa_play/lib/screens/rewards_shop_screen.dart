import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';

class RewardsShopScreen extends StatefulWidget {
  final String userId;

  const RewardsShopScreen({
    super.key,
    required this.userId,
  });

  @override
  State<RewardsShopScreen> createState() => _RewardsShopScreenState();
}

class _RewardsShopScreenState extends State<RewardsShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategory = 0;

  final List<String> _categories = ['Avatares', 'Marcos', 'Temas'];

  // Items de la tienda mejorados
  final List<Map<String, dynamic>> _shopItems = [
    // Avatares
    {
      'id': 'avatar_cyber',
      'type': 'avatar',
      'name': 'Ciber-Héroe',
      'description': 'Protector del mundo digital',
      'price': 500,
      'icon': Icons.security,
      'color': 0xFF2196F3,
      'rarity': 'epic',
    },
    {
      'id': 'avatar_detective',
      'type': 'avatar',
      'name': 'Detective',
      'description': 'Descubre la verdad',
      'price': 300,
      'icon': Icons.search,
      'color': 0xFFFFC107,
      'rarity': 'rare',
    },
    {
      'id': 'avatar_ninja',
      'type': 'avatar',
      'name': 'Ninja Digital',
      'description': 'Sigiloso y astuto',
      'price': 800,
      'icon': Icons.visibility_off,
      'color': 0xFF9C27B0,
      'rarity': 'legendary',
    },
    {
      'id': 'avatar_artist',
      'type': 'avatar',
      'name': 'Creador',
      'description': 'Artista creativo',
      'price': 400,
      'icon': Icons.palette,
      'color': 0xFFE91E63,
      'rarity': 'rare',
    },
    {
      'id': 'avatar_scientist',
      'type': 'avatar',
      'name': 'Científico',
      'description': 'Busca la verdad',
      'price': 600,
      'icon': Icons.science,
      'color': 0xFF00BCD4,
      'rarity': 'epic',
    },
    // Marcos
    {
      'id': 'frame_gold',
      'type': 'frame',
      'name': 'Marco Dorado',
      'description': 'Brilla como el oro',
      'price': 1000,
      'icon': Icons.crop_square,
      'color': 0xFFFFD700,
      'rarity': 'legendary',
    },
    {
      'id': 'frame_nature',
      'type': 'frame',
      'name': 'Naturaleza',
      'description': 'Hojas y flores',
      'price': 200,
      'icon': Icons.eco,
      'color': 0xFF4CAF50,
      'rarity': 'common',
    },
    {
      'id': 'frame_pixel',
      'type': 'frame',
      'name': 'Pixel Art',
      'description': 'Estilo retro',
      'price': 350,
      'icon': Icons.grid_on,
      'color': 0xFF9E9E9E,
      'rarity': 'rare',
    },
    // Temas
    {
      'id': 'theme_space',
      'type': 'theme',
      'name': 'Espacio',
      'description': 'Explora las estrellas',
      'price': 750,
      'icon': Icons.rocket_launch,
      'color': 0xFF3F51B5,
      'rarity': 'epic',
    },
    {
      'id': 'theme_ocean',
      'type': 'theme',
      'name': 'Océano',
      'description': 'Bajo el mar',
      'price': 500,
      'icon': Icons.water,
      'color': 0xFF00ACC1,
      'rarity': 'rare',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedCategory = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'legendary':
        return const Color(0xFFFFD700);
      case 'epic':
        return const Color(0xFF9C27B0);
      case 'rare':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getRarityLabel(String rarity) {
    switch (rarity) {
      case 'legendary':
        return 'LEGENDARIO';
      case 'epic':
        return 'ÉPICO';
      case 'rare':
        return 'RARO';
      default:
        return 'COMÚN';
    }
  }

  Future<void> _purchaseItem(Map<String, dynamic> item, int balance) async {
    if (balance < item['price']) {
      _showInsufficientFundsDialog();
      return;
    }

    final success = await FirebaseService.purchaseItem(
      widget.userId,
      item['id'],
      item['price'],
      item,
    );

    if (mounted) {
      if (success) {
        _showSuccessDialog(item);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hubo un error. Intenta de nuevo.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange[400]),
            const SizedBox(width: 8),
            const Text('¡Puntos insuficientes!'),
          ],
        ),
        content: const Text(
          'Completa más actividades para ganar puntos y desbloquear este item.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ENTENDIDO'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confetti effect placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(item['color']),
                      Color(item['color']).withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(item['color']).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¡CONSEGUIDO!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppStyles.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.accentGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '¡GENIAL!',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF132757),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tienda de Premios',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseService.getUserStream(widget.userId),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final balance = userData['points'] ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Color(0xFF132757), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$balance',
                      style: const TextStyle(
                        color: Color(0xFF132757),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseService.getUserStream(widget.userId),
        builder: (context, snapshot) {
          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final userBalance = userData['points'] ?? 0;
          final inventory = (userData['inventory'] as List?) ?? [];
          final inventoryIds = inventory.map((e) => e['id']).toSet();

          return Column(
            children: [
              // Categorías
              _buildCategoryTabs(),

              // Grid de items
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildItemsGrid('avatar', inventoryIds, userBalance),
                    _buildItemsGrid('frame', inventoryIds, userBalance),
                    _buildItemsGrid('theme', inventoryIds, userBalance),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF132757),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132757).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tienda',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Personaliza tu perfil',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Balance
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppStyles.yellow, Color(0xFFF5B800)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppStyles.yellow.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Color(0xFF132757),
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$balance',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF132757),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
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
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF132757), Color(0xFF1E3A6E)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          dividerColor: Colors.transparent,
          tabs: _categories
              .map((cat) => Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat == 'Avatares'
                              ? Icons.face
                              : cat == 'Marcos'
                                  ? Icons.crop_square
                                  : Icons.palette,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(cat),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildItemsGrid(String type, Set inventoryIds, int balance) {
    final items = _shopItems.where((i) => i['type'] == type).toList();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = inventoryIds.contains(item['id']);
        final canAfford = balance >= (item['price'] as int);
        final rarityColor = _getRarityColor(item['rarity']);

        return GestureDetector(
          onTap: isOwned
              ? () => _equipItem(item)
              : canAfford
                  ? () => _purchaseItem(item, balance)
                  : () => _showInsufficientFundsDialog(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isOwned
                  ? Border.all(color: AppStyles.accentGreen, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Rarity banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [rarityColor, rarityColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Text(
                    _getRarityLabel(item['rarity']),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Color(item['color']).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    size: 36,
                    color: Color(item['color']),
                  ),
                ),

                const SizedBox(height: 10),

                // Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF132757),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 2),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    item['description'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const Spacer(),

                // Price/Action button
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isOwned
                          ? const LinearGradient(
                              colors: [AppStyles.accentGreen, Color(0xFF2ECC71)],
                            )
                          : canAfford
                              ? const LinearGradient(
                                  colors: [AppStyles.yellow, Color(0xFFF5B800)],
                                )
                              : null,
                      color: !isOwned && !canAfford ? Colors.grey[200] : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isOwned
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'EQUIPAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.monetization_on_rounded,
                                size: 16,
                                color: canAfford
                                    ? const Color(0xFF132757)
                                    : Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item['price']}',
                                style: TextStyle(
                                  color: canAfford
                                      ? const Color(0xFF132757)
                                      : Colors.grey[500],
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _equipItem(Map<String, dynamic> item) async {
    await FirebaseService.equipItem(widget.userId, item['type'], item['id']);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('¡${item['name']} equipado!'),
            ],
          ),
          backgroundColor: AppStyles.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
