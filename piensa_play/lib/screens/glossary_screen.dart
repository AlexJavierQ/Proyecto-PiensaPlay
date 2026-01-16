import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/piensa_app_bar.dart';

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

  List<DocumentSnapshot> _filterTerms(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // CORRECCIÓN: Usar 'term' prioritariamente, fallback a 'title'
      final term = (data['term'] ?? data['title'] ?? '').toString().toLowerCase();
      bool matchesSearch = _searchQuery.isEmpty || term.contains(_searchQuery.toLowerCase());
      bool matchesFilter = _selectedFilter == 'Todos' || term.startsWith(_selectedFilter.toLowerCase());
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Set<String> _getAvailableLetters(List<DocumentSnapshot> docs) {
    final letters = <String>{};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final term = (data['term'] ?? data['title'] ?? '').toString();
      if (term.isNotEmpty) letters.add(term[0].toUpperCase());
    }
    return letters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: const PiensaAppBar(title: 'Glosario', showBackButton: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Buscar término...', border: InputBorder.none, icon: Icon(Icons.search)),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.getGlossaryTerms(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final letters = _getAvailableLetters(snapshot.data!.docs);
                    final sortedLetters = letters.toList()..sort();
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(label: 'Todos', selected: _selectedFilter == 'Todos', onTap: () => setState(() => _selectedFilter = 'Todos')),
                          ...sortedLetters.map((letter) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _FilterChip(label: letter, selected: _selectedFilter == letter, onTap: () => setState(() => _selectedFilter = letter)),
                          )),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getGlossaryTerms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No hay términos.'));
                final filteredDocs = _filterTerms(snapshot.data!.docs);
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    childAspectRatio: 0.8, // Ajustado para el nuevo diseño más alto
                    crossAxisSpacing: 16, 
                    mainAxisSpacing: 16
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    return _GlossaryCard(
                      icon: _getIcon(data['icon'] ?? 'menu_book'),
                      title: data['term'] ?? data['title'] ?? 'Sin término', // Usar 'term'
                      definition: data['definition'] ?? '',
                      category: data['category'] ?? 'General', // Pasar categoría
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.onTap, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFBDD87B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBDD87B)),
        ),
        child: Text(label, style: const TextStyle(color: Color(0xFF132757), fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _GlossaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String definition;
  final String category; // Propiedad nueva

  const _GlossaryCard({
    required this.icon,
    required this.title,
    required this.definition,
    this.category = 'General',
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'medios': return const Color(0xFF42A5F5); // Blue
      case 'seguridad': return const Color(0xFFEF5350); // Red
      case 'privacidad': return const Color(0xFFAB47BC); // Purple
      case 'social': return const Color(0xFFFFA726); // Orange
      case 'tecnología': return const Color(0xFF26A69A); // Teal
      default: return AppStyles.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getCategoryColor(category);

    return GestureDetector(
      onTap: () => _showDefinition(context, themeColor),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: themeColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color(0xFF132757),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDefinition(BuildContext context, Color color) {
    showDialog(
      context: context,
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF132757)),
              ),
               const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                definition,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
