import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

// Simplified Game Form Dialog - Only game-specific fields
class GameFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const GameFormDialog({
    super.key,
    this.initialData,
    required this.onSave,
  });

  @override
  State<GameFormDialog> createState() => _GameFormDialogState();
}

class _GameFormDialogState extends State<GameFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _questionController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _incorrectAnswer1Controller = TextEditingController();
  final _incorrectAnswer2Controller = TextEditingController();
  final _incorrectAnswer3Controller = TextEditingController();

  String _selectedType = 'question_answer';
  int _order = 1;
  bool _isLocked = false;
  int _requiredActivities = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _titleController.text = data['title'] ?? '';
      _questionController.text = data['question'] ?? '';
      _correctAnswerController.text = data['correctAnswer'] ?? '';
      _selectedType = data['type'] ?? 'question_answer';
      _order = data['order'] ?? 1;
      _isLocked = data['locked'] ?? false;
      _requiredActivities = data['requiredActivities'] ?? 0;
      
      // Load incorrect answers if they exist
      final incorrectAnswers = data['incorrectAnswers'] as List?;
      if (incorrectAnswers != null && incorrectAnswers.isNotEmpty) {
        if (incorrectAnswers.length > 0) _incorrectAnswer1Controller.text = incorrectAnswers[0];
        if (incorrectAnswers.length > 1) _incorrectAnswer2Controller.text = incorrectAnswers[1];
        if (incorrectAnswers.length > 2) _incorrectAnswer3Controller.text = incorrectAnswers[2];
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _questionController.dispose();
    _correctAnswerController.dispose();
    _incorrectAnswer1Controller.dispose();
    _incorrectAnswer2Controller.dispose();
    _incorrectAnswer3Controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final gameData = <String, dynamic>{
      'title': _titleController.text.trim(),
      'type': _selectedType,
      'order': _order,
      'locked': _isLocked,
      'requiredActivities': _isLocked ? _requiredActivities : 0,
    };

    // Add type-specific data
    if (_selectedType == 'question_answer') {
      gameData['question'] = _questionController.text.trim();
      gameData['correctAnswer'] = _correctAnswerController.text.trim();
      
      final incorrectAnswers = <String>[];
      if (_incorrectAnswer1Controller.text.trim().isNotEmpty) {
        incorrectAnswers.add(_incorrectAnswer1Controller.text.trim());
      }
      if (_incorrectAnswer2Controller.text.trim().isNotEmpty) {
        incorrectAnswers.add(_incorrectAnswer2Controller.text.trim());
      }
      if (_incorrectAnswer3Controller.text.trim().isNotEmpty) {
        incorrectAnswers.add(_incorrectAnswer3Controller.text.trim());
      }
      gameData['incorrectAnswers'] = incorrectAnswers;
    }

    widget.onSave(gameData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialData == null ? 'Agregar Juego' : 'Editar Juego',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppStyles.primaryBlue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '* Título del Juego',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: El sendero de las palabras',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                // Game Type
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Juego',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'question_answer', child: Text('Pregunta y Respuesta')),
                    DropdownMenuItem(value: 'word_selection', child: Text('Selección de Palabras')),
                    DropdownMenuItem(value: 'scenario', child: Text('Escenarios')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Type-specific fields
                if (_selectedType == 'question_answer') ...[
                  const Text(
                    'Configuración de Pregunta y Respuesta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppStyles.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _questionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '* Pregunta',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: "Vuelve a tu país, nadie te quiere aquí."',
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _correctAnswerController,
                    decoration: const InputDecoration(
                      labelText: '* Respuesta Correcta',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: Palabra que construye',
                      prefixIcon: Icon(Icons.check_circle, color: Colors.green),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _incorrectAnswer1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Respuesta Incorrecta 1',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: Palabra que hiere',
                      prefixIcon: Icon(Icons.cancel, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _incorrectAnswer2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Respuesta Incorrecta 2 (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cancel, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _incorrectAnswer3Controller,
                    decoration: const InputDecoration(
                      labelText: 'Respuesta Incorrecta 3 (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cancel, color: Colors.red),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Order
                TextFormField(
                  initialValue: _order.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Orden',
                    border: OutlineInputBorder(),
                    hintText: '1, 2, 3...',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _order = int.tryParse(value) ?? 1;
                  },
                ),
                const SizedBox(height: 12),

                // Locked checkbox
                CheckboxListTile(
                  title: const Text('Bloqueado'),
                  subtitle: const Text('El juego requiere completar otros primero'),
                  value: _isLocked,
                  onChanged: (value) {
                    setState(() {
                      _isLocked = value ?? false;
                      if (!_isLocked) _requiredActivities = 0;
                    });
                  },
                ),

                // Required activities (only if locked)
                if (_isLocked) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: _requiredActivities.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Actividades Requeridas',
                      border: OutlineInputBorder(),
                      hintText: 'Número de actividades a completar',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _requiredActivities = int.tryParse(value) ?? 0;
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      widget.initialData == null ? 'Agregar Juego' : 'Guardar Cambios',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
