import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import '../utils/local_storage_service.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<MemoryCard> _cards = [];
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;
  bool _isProcessing = false;
  int _matchesFound = 0;
  int _moves = 0;
  int _totalPoints = 0;
  bool _isComplete = false;
  int _totalPairs = 0;

  void _initializeGame(Map<String, dynamic> activityData) {
    if (_cards.isNotEmpty) return;
    
    final cardsData = activityData['cards'] as List? ?? _getDefaultCards();
    final pairs = cardsData.map((c) => Map<String, dynamic>.from(c as Map)).toList();
    
    _totalPairs = pairs.length;
    
    // Create pairs - each concept appears twice
    List<MemoryCard> cards = [];
    for (int i = 0; i < pairs.length; i++) {
      cards.add(MemoryCard(id: '${i}_a', pairId: i.toString(), content: pairs[i]['content'] ?? '', icon: pairs[i]['icon']));
      cards.add(MemoryCard(id: '${i}_b', pairId: i.toString(), content: pairs[i]['content'] ?? '', icon: pairs[i]['icon']));
    }
    cards.shuffle(Random());
    _cards = cards;
  }

  List<Map<String, dynamic>> _getDefaultCards() {
    return [
      {'content': '🔒', 'icon': 'lock'},
      {'content': '🛡️', 'icon': 'shield'},
      {'content': '🌐', 'icon': 'web'},
      {'content': '💬', 'icon': 'chat'},
      {'content': '❤️', 'icon': 'heart'},
      {'content': '⭐', 'icon': 'star'},
    ];
  }

  void _flipCard(int index) {
    if (_isProcessing || _cards[index].isMatched || _cards[index].isFlipped) return;
    
    setState(() {
      _cards[index].isFlipped = true;
      
      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = index;
      } else {
        _secondFlippedIndex = index;
        _moves++;
        _isProcessing = true;
        
        // Check for match
        if (_cards[_firstFlippedIndex!].pairId == _cards[_secondFlippedIndex!].pairId) {
          // Match found!
          _cards[_firstFlippedIndex!].isMatched = true;
          _cards[_secondFlippedIndex!].isMatched = true;
          _matchesFound++;
          _totalPoints += 100;
          _resetSelection();
          
          if (_matchesFound == _totalPairs) {
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() => _isComplete = true);
            });
          }
        } else {
          // No match - flip back after delay
          Future.delayed(const Duration(milliseconds: 800), () {
            setState(() {
              _cards[_firstFlippedIndex!].isFlipped = false;
              _cards[_secondFlippedIndex!].isFlipped = false;
              _resetSelection();
            });
          });
        }
      }
    });
  }

  void _resetSelection() {
    _firstFlippedIndex = null;
    _secondFlippedIndex = null;
    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final unitData = args['unitData'] as Map<String, dynamic>? ?? {};
    final activityData = args['activityData'] as Map<String, dynamic>? ?? {};
    final unitId = args['unitId'] as String? ?? '';
    
    _initializeGame(activityData);
    
    if (_isComplete) return _buildCompletionScreen(args, unitId, activityData);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: AppStyles.darkBlue,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(activityData['title'] ?? 'Memorama', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: AppStyles.darkBlue,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat(Icons.touch_app, 'Movimientos', '$_moves'),
                _buildHeaderStat(Icons.stars, 'Parejas', '$_matchesFound/$_totalPairs'),
                _buildHeaderStat(Icons.star, 'Puntos', '$_totalPoints'),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Color(0xFF66BB6A), size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Encuentra las parejas iguales tocando las cartas', style: TextStyle(color: Colors.green.shade700, fontSize: 13))),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: _cards.length,
                itemBuilder: (context, index) => _buildCard(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF6E16B), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
      ],
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isFlipped || card.isMatched ? Colors.white : AppStyles.darkBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: card.isMatched ? const Color(0xFF66BB6A) : card.isFlipped ? const Color(0xFFF6E16B) : Colors.transparent,
            width: 3,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: card.isFlipped || card.isMatched
              ? Text(card.content, style: const TextStyle(fontSize: 32))
              : const Icon(Icons.question_mark, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(Map<String, dynamic> args, String unitId, Map<String, dynamic> activityData) {
    final efficiency = _totalPairs > 0 ? (_totalPairs / _moves * 100).round().clamp(0, 100) : 0;
    
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
                child: const Icon(Icons.psychology, size: 50, color: AppStyles.darkBlue),
              ),
              const SizedBox(height: 24),
              const Text('¡Memoria increíble!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppStyles.darkBlue)),
              const SizedBox(height: 8),
              Text('Encontraste todas las parejas', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBadge('$_moves', 'Movimientos'),
                  _buildStatBadge('$_totalPoints', 'Puntos'),
                  _buildStatBadge('$efficiency%', 'Eficiencia'),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final userId = await LocalStorageService.getUserId();
                    if (userId != null) {
                      await FirebaseService.saveGameProgress(userId, unitId, activityData['id'] ?? '', {'completed': true, 'score': _totalPoints, 'moves': _moves, 'type': activityData['type'] ?? 'memory'});
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

  Widget _buildStatBadge(String value, String label) {
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
          child: Center(child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppStyles.darkBlue))),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}

class MemoryCard {
  final String id;
  final String pairId;
  final String content;
  final String? icon;
  bool isFlipped;
  bool isMatched;

  MemoryCard({required this.id, required this.pairId, required this.content, this.icon, this.isFlipped = false, this.isMatched = false});
}
