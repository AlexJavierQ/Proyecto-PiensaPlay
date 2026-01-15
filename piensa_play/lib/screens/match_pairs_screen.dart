import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';

class MatchPairsScreen extends StatefulWidget {
  const MatchPairsScreen({super.key});

  @override
  State<MatchPairsScreen> createState() => _MatchPairsScreenState();
}

class _MatchPairsScreenState extends State<MatchPairsScreen> {
  List<MatchItem> _leftItems = [];
  List<MatchItem> _rightItems = [];
  String? _selectedLeftId;
  List<MatchedPair> _matchedPairs = [];
  int _attempts = 0;
  int _correctMatches = 0;
  int _totalPoints = 0;
  bool _isComplete = false;

  void _initializeGame(Map<String, dynamic> activityData) {
    if (_leftItems.isNotEmpty) return;
    
    final pairsData = activityData['pairs'] as List? ?? _getDefaultPairs();
    final pairs = pairsData.map((p) => Map<String, dynamic>.from(p as Map)).toList();
    
    _leftItems = pairs.asMap().entries.map((e) {
      return MatchItem(id: 'left_${e.key}', text: e.value['concept'] ?? '', pairId: e.key.toString());
    }).toList();
    
    _rightItems = pairs.asMap().entries.map((e) {
      return MatchItem(id: 'right_${e.key}', text: e.value['definition'] ?? '', pairId: e.key.toString());
    }).toList()..shuffle(Random());
  }

  List<Map<String, dynamic>> _getDefaultPairs() {
    return [
      {'concept': 'Ciberbullying', 'definition': 'Acoso a través de internet'},
      {'concept': 'Fake News', 'definition': 'Noticias falsas compartidas como verdaderas'},
      {'concept': 'Privacidad', 'definition': 'Derecho a proteger información personal'},
      {'concept': 'Huella Digital', 'definition': 'Rastro que dejamos en internet'},
    ];
  }

  void _selectLeft(String id) {
    if (_matchedPairs.any((p) => p.leftId == id)) return;
    setState(() => _selectedLeftId = id);
  }

  void _selectRight(String id) {
    if (_selectedLeftId == null || _matchedPairs.any((p) => p.rightId == id)) return;
    
    final leftItem = _leftItems.firstWhere((i) => i.id == _selectedLeftId);
    final rightItem = _rightItems.firstWhere((i) => i.id == id);
    _attempts++;
    
    if (leftItem.pairId == rightItem.pairId) {
      setState(() {
        _matchedPairs.add(MatchedPair(leftId: _selectedLeftId!, rightId: id));
        _correctMatches++;
        _totalPoints += 50;
        _selectedLeftId = null;
      });
      
      if (_matchedPairs.length == _leftItems.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() => _isComplete = true);
        });
      }
    } else {
      setState(() => _selectedLeftId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final unitData = args['unitData'] as Map<String, dynamic>? ?? {};
    final activityData = args['activityData'] as Map<String, dynamic>? ?? {};
    final unitId = args['unitId'] as String? ?? '';
    
    _initializeGame(activityData);
    
    if (_isComplete) return _buildCompletionScreen(unitData, activityData, args, unitId);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: AppStyles.darkBlue,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(activityData['title'] ?? 'Emparejar Conceptos', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: AppStyles.darkBlue,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Parejas: $_correctMatches/${_leftItems.length}', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    Text('Puntos: $_totalPoints', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _leftItems.isEmpty ? 0 : _correctMatches / _leftItems.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC9E090)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: _buildColumn('CONCEPTOS', _leftItems, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildColumn('DEFINICIONES', _rightItems, false)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String title, List<MatchItem> items, bool isLeft) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppStyles.darkBlue)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isMatched = _matchedPairs.any((p) => isLeft ? p.leftId == item.id : p.rightId == item.id);
              final isSelected = isLeft && _selectedLeftId == item.id;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildCard(item, isSelected, isMatched, isLeft ? () => _selectLeft(item.id) : () => _selectRight(item.id)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(MatchItem item, bool isSelected, bool isMatched, VoidCallback onTap) {
    return InkWell(
      onTap: isMatched ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMatched ? const Color(0xFFE8F5E9) : isSelected ? const Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isMatched ? const Color(0xFF66BB6A) : isSelected ? const Color(0xFFF6E16B) : Colors.grey.shade300, width: 2),
        ),
        child: Text(item.text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isMatched ? const Color(0xFF2E7D32) : AppStyles.darkBlue)),
      ),
    );
  }

  Widget _buildCompletionScreen(Map<String, dynamic> unitData, Map<String, dynamic> activityData, Map<String, dynamic> args, String unitId) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: const BoxDecoration(color: Color(0xFFC9E090), shape: BoxShape.circle),
                child: const Icon(Icons.link, size: 50, color: AppStyles.darkBlue),
              ),
              const SizedBox(height: 24),
              const Text('¡Excelente!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppStyles.darkBlue)),
              const SizedBox(height: 8),
              Text('Conectaste todos los conceptos', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 32),
              Text('$_totalPoints puntos', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppStyles.darkBlue)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final userId = await LocalStorageService.getUserId();
                    if (userId != null) {
                      await FirebaseService.saveGameProgress(userId, unitId, activityData['id'] ?? '', {'completed': true, 'score': _totalPoints, 'type': activityData['type'] ?? 'match_pairs'});
                    }
                    if (mounted) Navigator.pushReplacementNamed(context, '/activity_completion', arguments: {...args, 'score': _totalPoints});
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9E090), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('CONTINUAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppStyles.darkBlue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchItem {
  final String id;
  final String text;
  final String pairId;
  MatchItem({required this.id, required this.text, required this.pairId});
}

class MatchedPair {
  final String leftId;
  final String rightId;
  MatchedPair({required this.leftId, required this.rightId});
}
