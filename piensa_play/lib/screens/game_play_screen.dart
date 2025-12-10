import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  final Set<String> _selectedWords = {};
  bool _showResult = false;
  bool _isCorrect = false;

  void _toggleWord(String word, bool isCorrectWord) {
    setState(() {
      if (_selectedWords.contains(word)) {
        _selectedWords.remove(word);
      } else {
        _selectedWords.add(word);
      }
      _showResult = false;
    });
  }

  void _checkAnswers(List<String> correctWords) {
    setState(() {
      _showResult = true;
      // Check if all selected words are correct and all correct words are selected
      _isCorrect = _selectedWords.length == correctWords.length &&
          _selectedWords.every((word) => correctWords.contains(word));
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final unitData = args['unitData'] as Map<String, dynamic>;
    final gameData = args['gameData'] as Map<String, dynamic>;

    final correctWords = (gameData['correctWords'] as List?)?.cast<String>() ?? [];
    final incorrectWords = (gameData['incorrectWords'] as List?)?.cast<String>() ?? [];
    final allWords = [...correctWords, ...incorrectWords]..shuffle();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          unitData['title'] ?? 'Juego',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                gameData['title'] ?? 'Juego',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppStyles.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                gameData['subtitle'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppStyles.textLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: gameData['imageUrl'] != null
                      ? Image.network(
                          gameData['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF90C958),
                              child: const Center(
                                child: Icon(Icons.forest, size: 80, color: Colors.white),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFF90C958),
                          child: const Center(
                            child: Icon(Icons.forest, size: 80, color: Colors.white),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Description
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameData['description'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppStyles.textDark,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      gameData['question'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppStyles.textDark,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Word chips
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: allWords.map((word) {
                  final isSelected = _selectedWords.contains(word);
                  final isCorrectWord = correctWords.contains(word);
                  
                  Color chipColor;
                  if (_showResult) {
                    if (isCorrectWord) {
                      chipColor = const Color(0xFF90C958); // Green for correct
                    } else {
                      chipColor = const Color(0xFFFF8FA3); // Red for incorrect
                    }
                  } else {
                    chipColor = isSelected
                        ? const Color(0xFFFFD700) // Yellow when selected
                        : Colors.white;
                  }

                  return GestureDetector(
                    onTap: _showResult
                        ? null
                        : () => _toggleWord(word, isCorrectWord),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppStyles.primaryBlue
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        word,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _showResult || isSelected
                              ? AppStyles.primaryBlue
                              : AppStyles.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Result message
              if (_showResult)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCorrect
                        ? const Color(0xFF90C958).withValues(alpha: 0.2)
                        : const Color(0xFFFF8FA3).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isCorrect
                          ? const Color(0xFF90C958)
                          : const Color(0xFFFF8FA3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.cancel,
                        color: _isCorrect
                            ? const Color(0xFF90C958)
                            : const Color(0xFFFF8FA3),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isCorrect
                              ? '¡Excelente! Has seleccionado todas las palabras correctas.'
                              : 'Intenta de nuevo. Revisa las palabras que seleccionaste.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _isCorrect
                                ? const Color(0xFF90C958)
                                : const Color(0xFFFF8FA3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Action buttons
              if (!_showResult)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedWords.isEmpty
                        ? null
                        : () => _checkAnswers(correctWords),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      'Verificar Respuestas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    if (!_isCorrect)
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedWords.clear();
                                _showResult = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8FA3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Reintentar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!_isCorrect) const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_isCorrect) {
                              // Save progress and go back
                              // Note: You'll need to pass userId from args
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF90C958),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isCorrect ? 'Continuar' : 'Salir',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
