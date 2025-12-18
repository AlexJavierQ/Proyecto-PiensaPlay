import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      final title = (data['title'] ?? '').toString().toLowerCase();
      bool matchesSearch = _searchQuery.isEmpty || title.contains(_searchQuery.toLowerCase());
      bool matchesFilter = _selectedFilter == 'Todos' || title.startsWith(_selectedFilter.toLowerCase());
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Set<String> _getAvailableLetters(List<DocumentSnapshot> docs) {
    final letters = <String>{};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] ?? '').toString();
      if (title.isNotEmpty) letters.add(title[0].toUpperCase());
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1, crossAxisSpacing: 16, mainAxisSpacing: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    return _GlossaryCard(
                      icon: _getIcon(data['icon'] ?? 'menu_book'),
                      title: data['title'] ?? 'Sin título',
                      definition: data['definition'] ?? '',
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
  const _GlossaryCard({required this.icon, required this.title, required this.definition});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDefinition(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFA0E69D), width: 2)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF132757)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF132757))),
          ],
        ),
      ),
    );
  }

  void _showDefinition(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(definition),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido'))],
      ),
    );
  }
}
