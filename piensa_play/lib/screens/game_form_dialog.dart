import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Dialog mejorado para crear/editar actividades con soporte para múltiples tipos de juegos
class GameFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const GameFormDialog({super.key, this.initialData, required this.onSave});

  @override
  State<GameFormDialog> createState() => _GameFormDialogState();
}

class _GameFormDialogState extends State<GameFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedType = 'quiz';
  int _order = 1;
  bool _isLocked = false;
  int _requiredActivities = 0;

  // Datos específicos por tipo - serán manejados por widgets específicos
  List<Map<String, dynamic>> _quizQuestions = [];
  List<Map<String, dynamic>> _matchPairs = [];
  List<Map<String, dynamic>> _memoryCards = [];
  List<Map<String, dynamic>> _sequenceSteps = [];
  List<Map<String, dynamic>> _fillBlankQuestions = [];
  
  // Para tipos existentes
  final _questionController = TextEditingController();
  final _correctAnswerController = TextEditingController();

  final List<Map<String, dynamic>> _gameTypes = [
    {'type': 'quiz', 'name': 'Quiz Interactivo', 'icon': Icons.quiz, 'description': 'Preguntas con múltiples opciones'},
    {'type': 'match_pairs', 'name': 'Emparejar Conceptos', 'icon': Icons.link, 'description': 'Conectar términos con definiciones'},
    {'type': 'memory', 'name': 'Memorama', 'icon': Icons.psychology, 'description': 'Encontrar parejas de cartas'},
    {'type': 'order_sequence', 'name': 'Ordenar Secuencia', 'icon': Icons.sort, 'description': 'Ordenar pasos correctamente'},
    {'type': 'fill_blanks', 'name': 'Completar Oraciones', 'icon': Icons.edit_note, 'description': 'Llenar espacios en blanco'},
    {'type': 'word_selection', 'name': 'Sendero de Palabras', 'icon': Icons.route, 'description': 'Clasificar palabras positivas/negativas'},
    // Tipos complejos ocultos para creación manual:
    // {'type': 'fake_news', 'name': 'Detector de Fake News', 'icon': Icons.fact_check, 'description': 'Identificar noticias falsas'},
    // {'type': 'stereotype_breaker', 'name': 'Rompe Estereotipos', 'icon': Icons.diversity_3, 'description': 'Identificar estereotipos'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _titleController.text = data['title'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _instructionsController.text = data['instructions'] ?? '';
      _selectedType = data['type'] ?? 'quiz';
      _order = data['order'] ?? 1;
      _isLocked = data['locked'] ?? false;
      _requiredActivities = data['requiredActivities'] ?? 0;
      
      // Cargar datos específicos del tipo
      _loadTypeSpecificData(data);
    }
  }

  void _loadTypeSpecificData(Map<String, dynamic> data) {
    switch (_selectedType) {
      case 'quiz':
        _quizQuestions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
        break;
      case 'match_pairs':
        _matchPairs = List<Map<String, dynamic>>.from(data['pairs'] ?? []);
        break;
      case 'memory':
        _memoryCards = List<Map<String, dynamic>>.from(data['cards'] ?? []);
        break;
      case 'order_sequence':
        _sequenceSteps = List<Map<String, dynamic>>.from(data['steps'] ?? []);
        break;
      case 'fill_blanks':
        _fillBlankQuestions = List<Map<String, dynamic>>.from(data['fillBlanks'] ?? []);
        break;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _questionController.dispose();
    _correctAnswerController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final gameData = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'instructions': _instructionsController.text.trim(),
      'type': _selectedType,
      'order': _order,
      'locked': _isLocked,
      'requiredActivities': _isLocked ? _requiredActivities : 0,
    };

    // Agregar datos específicos del tipo
    switch (_selectedType) {
      case 'quiz':
        gameData['questions'] = _quizQuestions;
        break;
      case 'match_pairs':
        gameData['pairs'] = _matchPairs;
        break;
      case 'memory':
        gameData['cards'] = _memoryCards;
        break;
      case 'order_sequence':
        gameData['steps'] = _sequenceSteps;
        break;
      case 'fill_blanks':
        gameData['fillBlanks'] = _fillBlankQuestions;
        break;
    }

    widget.onSave(gameData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppStyles.darkBlue,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.games, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.initialData == null ? 'Nueva Actividad' : 'Editar Actividad',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration('Título de la Actividad *', 'Ej: Quiz de Seguridad Digital'),
                        validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Descripción
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: _inputDecoration('Descripción', 'Breve descripción de la actividad...'),
                      ),
                      const SizedBox(height: 16),
                      
                      // Instrucciones
                      TextFormField(
                        controller: _instructionsController,
                        maxLines: 2,
                        decoration: _inputDecoration('Instrucciones para el estudiante', 'Explica cómo jugar...'),
                      ),
                      const SizedBox(height: 24),
                      
                      // Tipo de Juego - ahora usa lista vertical para evitar overflow
                      const Text('Tipo de Actividad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.darkBlue)),
                      const SizedBox(height: 12),
                      
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _gameTypes.map((type) {
                          final isSelected = _selectedType == type['type'];
                          
                          return GestureDetector(
                            onTap: () => setState(() => _selectedType = type['type'] as String),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppStyles.darkBlue : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSelected ? AppStyles.darkBlue : Colors.grey.shade300, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(type['icon'] as IconData, size: 18, color: isSelected ? Colors.white : AppStyles.darkBlue),
                                  const SizedBox(width: 6),
                                  Text(
                                    type['name'] as String,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppStyles.darkBlue),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Configuración específica del tipo
                      _buildTypeSpecificConfig(),
                      
                      const Divider(height: 32),
                      
                      // Orden y bloqueo
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _order.toString(),
                              decoration: _inputDecoration('Orden', '1, 2, 3...'),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => _order = int.tryParse(v) ?? 1,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Bloqueado', style: TextStyle(fontSize: 14)),
                              value: _isLocked,
                              onChanged: (v) => setState(() => _isLocked = v ?? false),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      
                      if (_isLocked) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _requiredActivities.toString(),
                          decoration: _inputDecoration('Actividades requeridas para desbloquear', '0'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _requiredActivities = int.tryParse(v) ?? 0,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(backgroundColor: AppStyles.darkBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    child: Text(widget.initialData == null ? 'Crear Actividad' : 'Guardar Cambios'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificConfig() {
    switch (_selectedType) {
      case 'quiz':
        return _buildQuizConfig();
      case 'match_pairs':
        return _buildMatchPairsConfig();
      case 'memory':
        return _buildMemoryConfig();
      case 'order_sequence':
        return _buildSequenceConfig();
      case 'fill_blanks':
        return _buildFillBlanksConfig();
      default:
        // No mostrar mensaje confuso - simplemente devolver un contenedor vacío
        return const SizedBox.shrink();
    }
  }

  Widget _buildQuizConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Preguntas del Quiz', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppStyles.darkBlue)),
            TextButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('Agregar'), onPressed: () => _showAddQuizQuestionDialog()),
          ],
        ),
        if (_quizQuestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text('Sin preguntas. Agrega al menos una pregunta.', style: TextStyle(color: Colors.grey))),
          )
        else
          ...List.generate(_quizQuestions.length, (i) => _buildQuizQuestionItem(i)),
      ],
    );
  }

  Widget _buildQuizQuestionItem(int index) {
    final q = _quizQuestions[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFFC9E090), child: Text('${index + 1}')),
        title: Text(q['question'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${(q['answers'] as List?)?.length ?? 0} opciones'),
        trailing: IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => setState(() => _quizQuestions.removeAt(index))),
      ),
    );
  }

  void _showAddQuizQuestionDialog() {
    final questionCtrl = TextEditingController();
    final correctCtrl = TextEditingController();
    final wrongCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Pregunta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: questionCtrl, decoration: const InputDecoration(labelText: 'Pregunta')),
              const SizedBox(height: 12),
              TextField(controller: correctCtrl, decoration: const InputDecoration(labelText: 'Respuesta Correcta')),
              const SizedBox(height: 12),
              TextField(controller: wrongCtrl, decoration: const InputDecoration(labelText: 'Respuestas incorrectas (separadas por ;)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final wrongAnswers = wrongCtrl.text.split(';').where((s) => s.trim().isNotEmpty).toList();
              final answers = [
                {'text': correctCtrl.text.trim(), 'isCorrect': true},
                ...wrongAnswers.map((w) => {'text': w.trim(), 'isCorrect': false}),
              ];
              
              setState(() => _quizQuestions.add({'question': questionCtrl.text.trim(), 'answers': answers}));
              Navigator.pop(ctx);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchPairsConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Parejas a Emparejar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppStyles.darkBlue)),
            TextButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('Agregar'), onPressed: () => _showAddPairDialog()),
          ],
        ),
        if (_matchPairs.isEmpty)
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Sin parejas configuradas', style: TextStyle(color: Colors.grey))))
        else
          ...List.generate(_matchPairs.length, (i) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
            leading: const Icon(Icons.link),
            title: Text(_matchPairs[i]['concept'] ?? ''),
            subtitle: Text(_matchPairs[i]['definition'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => setState(() => _matchPairs.removeAt(i))),
          ))),
      ],
    );
  }

  void _showAddPairDialog() {
    final conceptCtrl = TextEditingController();
    final defCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Pareja'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: conceptCtrl, decoration: const InputDecoration(labelText: 'Concepto')),
          const SizedBox(height: 12),
          TextField(controller: defCtrl, decoration: const InputDecoration(labelText: 'Definición')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () { setState(() => _matchPairs.add({'concept': conceptCtrl.text, 'definition': defCtrl.text})); Navigator.pop(ctx); }, child: const Text('Agregar')),
        ],
      ),
    );
  }

  Widget _buildMemoryConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Cartas del Memorama', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppStyles.darkBlue)),
          TextButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('Agregar'), onPressed: () => _showAddCardDialog()),
        ]),
        if (_memoryCards.isEmpty)
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Sin cartas. Agrega emojis o texto para las parejas.', style: TextStyle(color: Colors.grey))))
        else
          Wrap(spacing: 8, runSpacing: 8, children: _memoryCards.asMap().entries.map((e) => Chip(label: Text(e.value['content'] ?? ''), onDeleted: () => setState(() => _memoryCards.removeAt(e.key)))).toList()),
      ],
    );
  }

  void _showAddCardDialog() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Agregar Carta'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Emoji o texto corto')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () { setState(() => _memoryCards.add({'content': ctrl.text})); Navigator.pop(ctx); }, child: const Text('Agregar')),
      ],
    ));
  }

  Widget _buildSequenceConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Pasos a Ordenar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppStyles.darkBlue)),
          TextButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('Agregar'), onPressed: () => _showAddStepDialog()),
        ]),
        if (_sequenceSteps.isEmpty)
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Sin pasos. El orden en que los agregues será el correcto.', style: TextStyle(color: Colors.grey))))
        else
          ReorderableListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), onReorder: (o, n) { setState(() { if (n > o) n -= 1; final item = _sequenceSteps.removeAt(o); _sequenceSteps.insert(n, item); }); }, children: _sequenceSteps.asMap().entries.map((e) => ListTile(key: ValueKey(e.key), leading: CircleAvatar(child: Text('${e.key + 1}')), title: Text(e.value['text'] ?? ''), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _sequenceSteps.removeAt(e.key))))).toList()),
      ],
    );
  }

  void _showAddStepDialog() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Agregar Paso'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Descripción del paso')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () { setState(() => _sequenceSteps.add({'text': ctrl.text})); Navigator.pop(ctx); }, child: const Text('Agregar')),
      ],
    ));
  }

  Widget _buildFillBlanksConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Oraciones para Completar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppStyles.darkBlue)),
          TextButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('Agregar'), onPressed: () => _showAddFillBlankDialog()),
        ]),
        if (_fillBlankQuestions.isEmpty)
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Sin oraciones. Usa _____ donde va el espacio en blanco.', style: TextStyle(color: Colors.grey))))
        else
          ...List.generate(_fillBlankQuestions.length, (i) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(title: Text(_fillBlankQuestions[i]['sentence'] ?? ''), subtitle: Text('Correcta: ${_fillBlankQuestions[i]['correctWord']}'), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _fillBlankQuestions.removeAt(i)))))),
      ],
    );
  }

  void _showAddFillBlankDialog() {
    final sentenceCtrl = TextEditingController();
    final correctCtrl = TextEditingController();
    final optionsCtrl = TextEditingController();
    
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Agregar Oración'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: sentenceCtrl, decoration: const InputDecoration(labelText: 'Oración (usa _____ para el espacio)', helperText: 'Ej: Nunca comparto mi _____ con extraños')),
        const SizedBox(height: 12),
        TextField(controller: correctCtrl, decoration: const InputDecoration(labelText: 'Palabra correcta')),
        const SizedBox(height: 12),
        TextField(controller: optionsCtrl, decoration: const InputDecoration(labelText: 'Otras opciones (separadas por ;)')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          final options = [correctCtrl.text, ...optionsCtrl.text.split(';').where((s) => s.trim().isNotEmpty).map((s) => s.trim())];
          setState(() => _fillBlankQuestions.add({'sentence': sentenceCtrl.text, 'correctWord': correctCtrl.text, 'options': options}));
          Navigator.pop(ctx);
        }, child: const Text('Agregar')),
      ],
    ));
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(labelText: label, hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.white);
  }
}
