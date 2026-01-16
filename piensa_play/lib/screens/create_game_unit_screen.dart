import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';
import 'game_form_dialog.dart';

class CreateGameUnitScreen extends StatefulWidget {
  const CreateGameUnitScreen({super.key});

  @override
  State<CreateGameUnitScreen> createState() => _CreateGameUnitScreenState();
}

class _CreateGameUnitScreenState extends State<CreateGameUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedIcon = 'favorite';
  int _selectedColorIndex = 0;
  String _selectedStatus = 'locked';
  int _order = 1;
  
  final List<Map<String, dynamic>> _games = [];
  bool _isSaving = false;
  bool _isEditing = false;
  String? _editingUnitId;
  String? _classId;

  // Secciones expandibles
  bool _showAdvancedOptions = false;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'favorite', 'icon': Icons.favorite, 'label': 'Corazón'},
    {'name': 'security', 'icon': Icons.security, 'label': 'Seguridad'},
    {'name': 'verified_user', 'icon': Icons.verified_user, 'label': 'Verificado'},
    {'name': 'games', 'icon': Icons.games, 'label': 'Juegos'},
    {'name': 'school', 'icon': Icons.school, 'label': 'Educación'},
    {'name': 'psychology', 'icon': Icons.psychology, 'label': 'Mente'},
  ];

  final List<Color> _availableColors = [
    const Color(0xFFFFB6C1), // Rosa
    const Color(0xFFC9E090), // Verde
    const Color(0xFFB0C4DE), // Azul
    const Color(0xFFFFD700), // Dorado
    const Color(0xFFDDA0DD), // Púrpura
    const Color(0xFFF0E68C), // Amarillo
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && !_isEditing) {
      if (args.containsKey('classId')) {
        _classId = args['classId'];
      }
      
      if (args.containsKey('unitId')) {
        _isEditing = true;
        _editingUnitId = args['unitId'];
        final data = args['unitData'] as Map<String, dynamic>;
        
        _titleController.text = data['title'] ?? '';
        _subtitleController.text = data['subtitle'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _selectedIcon = data['icon'] ?? 'favorite';
        _selectedStatus = data['status'] ?? 'locked';
        _order = data['order'] ?? 1;
        _classId = data['classId'];
        
        // Identificar el color por valor
        if (data['color'] != null) {
          final colorValue = data['color'] is int ? data['color'] : 0xFFFBBF24;
          for (int i = 0; i < _availableColors.length; i++) {
            if (_availableColors[i].toARGB32() == colorValue) {
              _selectedColorIndex = i;
              break;
            }
          }
        }
        
        if (data['games'] != null) {
          _games.addAll((data['games'] as List).cast<Map<String, dynamic>>());
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_games.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar al menos una actividad'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final data = {
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'icon': _selectedIcon,
        'color': _availableColors[_selectedColorIndex].toARGB32(),
        'status': _selectedStatus,
        'order': _order,
        'games': _games,
        'classId': _classId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isEditing && _editingUnitId != null) {
        await FirebaseService.updateGameUnit(_editingUnitId!, data);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Unidad actualizada correctamente'), backgroundColor: AppStyles.accentGreen),
        );
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseService.createGameUnit(data);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('¡Unidad creada correctamente!'), backgroundColor: AppStyles.accentGreen),
        );
      }
      
      navigator.pop(true);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addGame() {
    showDialog(
      context: context,
      builder: (ctx) => GameFormDialog(
        onSave: (game) {
          setState(() => _games.add(game));
        },
      ),
    );
  }

  void _editGame(int index) {
    showDialog(
      context: context,
      builder: (ctx) => GameFormDialog(
        initialData: _games[index],
        onSave: (game) {
          setState(() => _games[index] = game);
        },
      ),
    );
  }

  void _deleteGame(int index) {
    setState(() => _games.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Editar Unidad' : 'Nueva Unidad',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECCIÓN 1: Información Básica
                    _buildSectionCard(
                      title: '1. Información Básica',
                      icon: Icons.info_outline,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _titleController,
                            label: 'Título de la Unidad *',
                            hint: 'Ej: Detective de Noticias',
                            validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _subtitleController,
                            label: 'Subtítulo',
                            hint: 'Ej: Aprende a identificar fake news',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Descripción',
                            hint: 'Breve descripción de la unidad...',
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // SECCIÓN 2: Apariencia
                    _buildSectionCard(
                      title: '2. Apariencia',
                      icon: Icons.palette_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Color de la Unidad', style: TextStyle(fontWeight: FontWeight.w600, color: AppStyles.primaryBlue)),
                          const SizedBox(height: 12),
                          _buildColorSelector(),
                          const SizedBox(height: 20),
                          const Text('Ícono', style: TextStyle(fontWeight: FontWeight.w600, color: AppStyles.primaryBlue)),
                          const SizedBox(height: 12),
                          _buildIconSelector(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // SECCIÓN 3: Actividades (la más importante)
                    _buildSectionCard(
                      title: '3. Actividades',
                      icon: Icons.games_outlined,
                      headerAction: ElevatedButton.icon(
                        onPressed: _addGame,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.accentGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      child: _games.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.games_outlined, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Sin actividades',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Agrega al menos una actividad\npara que los estudiantes jueguen',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: List.generate(_games.length, (index) {
                                final game = _games[index];
                                return _buildGameItem(index, game);
                              }),
                            ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // SECCIÓN 4: Opciones Avanzadas (colapsable)
                    _buildExpandableSection(
                      title: 'Opciones Avanzadas',
                      icon: Icons.tune,
                      isExpanded: _showAdvancedOptions,
                      onToggle: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Estado Inicial',
                                  value: _selectedStatus,
                                  items: const [
                                    DropdownMenuItem(value: 'locked', child: Text('🔒 Bloqueado')),
                                    DropdownMenuItem(value: 'in_progress', child: Text('🕐 En Progreso')),
                                    DropdownMenuItem(value: 'completed', child: Text('✓ Completado')),
                                  ],
                                  onChanged: (v) => setState(() => _selectedStatus = v!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: TextEditingController(text: _order.toString()),
                                  label: 'Orden',
                                  hint: '1, 2, 3...',
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => _order = int.tryParse(v) ?? 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Espacio para el botón flotante
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveUnit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSaving
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isEditing ? Icons.save_rounded : Icons.check_circle_rounded),
                        const SizedBox(width: 8),
                        Text(
                          _isEditing ? 'GUARDAR CAMBIOS' : 'CREAR UNIDAD',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? headerAction,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppStyles.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: AppStyles.primaryBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.primaryBlue),
                  ),
                ),
                if (headerAction != null) headerAction,
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
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
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(_availableColors.length, (index) {
        final isSelected = _selectedColorIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedColorIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _availableColors[index],
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppStyles.primaryBlue : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: _availableColors[index].withValues(alpha: 0.5), blurRadius: 8)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildIconSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableIcons.map((iconData) {
        final isSelected = _selectedIcon == iconData['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = iconData['name'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? AppStyles.primaryBlue : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppStyles.primaryBlue : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Icon(
              iconData['icon'] as IconData,
              color: isSelected ? Colors.white : AppStyles.primaryBlue,
              size: 26,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGameItem(int index, Map<String, dynamic> game) {
    final typeLabels = {
      'quiz': '🎯 Quiz',
      'match_pairs': '🔗 Emparejar',
      'memory': '🧠 Memorama',
      'order_sequence': '📋 Ordenar',
      'fill_blanks': '✏️ Completar',
      'word_selection': '🛤️ Sendero',
      'fake_news': '📰 Fake News',
      'stereotype_breaker': '🌈 Estereotipos',
    };
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: _availableColors[_selectedColorIndex].withValues(alpha: 0.3),
          child: Text(
            '${index + 1}',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppStyles.primaryBlue),
          ),
        ),
        title: Text(
          game['title'] ?? 'Sin título',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          typeLabels[game['type']] ?? game['type'] ?? 'Actividad',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _editGame(index),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () => _deleteGame(index),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }
}
