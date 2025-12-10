import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper to map string icon names to IconData
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'menu_book': return Icons.menu_book;
      case 'list_alt': return Icons.list_alt;
      case 'share': return Icons.share;
      case 'visibility': return Icons.visibility;
      case 'warning_amber': return Icons.warning_amber;
      case 'fingerprint': return Icons.fingerprint;
      case 'fact_check': return Icons.fact_check;
      case 'security': return Icons.security;
      case 'lock': return Icons.lock;
      case 'public': return Icons.public;
      default: return Icons.help_outline;
    }
  }

  // Filter terms based on search query and selected filter
  List<DocumentSnapshot> _filterTerms(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] ?? '').toString().toLowerCase();
      
      // Search filter
      bool matchesSearch = _searchQuery.isEmpty || 
                          title.contains(_searchQuery.toLowerCase());
      
      // Letter filter
      bool matchesFilter = _selectedFilter == 'Todos' || 
                          title.startsWith(_selectedFilter.toLowerCase());
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  // Get unique first letters from all terms
  Set<String> _getAvailableLetters(List<DocumentSnapshot> docs) {
    final letters = <String>{};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] ?? '').toString();
      if (title.isNotEmpty) {
        letters.add(title[0].toUpperCase());
      }
    }
    return letters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        title: const Text('Glosario'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search and Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar término...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.getGlossaryTerms(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final letters = _getAvailableLetters(snapshot.data!.docs);
                    final sortedLetters = letters.toList()..sort();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Todos',
                            selected: _selectedFilter == 'Todos',
                            onTap: () {
                              setState(() {
                                _selectedFilter = 'Todos';
                              });
                            },
                          ),
                          ...sortedLetters.map((letter) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _FilterChip(
                              label: letter,
                              selected: _selectedFilter == letter,
                              onTap: () {
                                setState(() {
                                  _selectedFilter = letter;
                                });
                              },
                            ),
                          )),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Dynamic Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getGlossaryTerms(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay términos disponibles.'));
                }

                final filteredDocs = _filterTerms(snapshot.data!.docs);

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron términos',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    return _GlossaryCard(
                      icon: _getIcon(data['icon'] ?? 'menu_book'),
                      title: data['title'] ?? 'Sin título',
                      question: data['question'] ?? '',
                      definition: data['definition'] ?? '',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNavBar(current: 1),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  
  const _FilterChip({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppStyles.lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: AppStyles.lightGreen),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppStyles.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _GlossaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String question;
  final String definition;

  const _GlossaryCard({
    required this.icon,
    required this.title,
    required this.question,
    required this.definition,
  });

  void _showDefinition(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppStyles.primaryBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppStyles.limeGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 30, color: AppStyles.primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.replaceAll('\n', ' '),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Definición',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppStyles.limeGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              // Content
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppStyles.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppStyles.limeGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      definition,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppStyles.slateText,
                        height: 1.6,
                      ),
                    ),
                  ],
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
    return GestureDetector(
      onTap: () => _showDefinition(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppStyles.lightGreen, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppStyles.limeGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppStyles.primaryBlue),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppStyles.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int current; // 0: Inicio, 1: Glosario, 2: Ajustes
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
            onTap: () => Navigator.pop(context),
          ),
          _NavItem(
            icon: Icons.menu_book,
            label: 'Glosario',
            selected: current == 1,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.settings,
            label: 'Ajustes',
            selected: current == 2,
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
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
    final color = Colors.white;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
