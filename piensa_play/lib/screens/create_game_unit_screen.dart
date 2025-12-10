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
  final _entryController = TextEditingController();
  final _introductionController = TextEditingController();
  final _missionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _gameDynamicsController = TextEditingController();
  final _skillsController = TextEditingController();
  
  String _selectedIcon = 'favorite';
  String _selectedColor = '#FFB6C1';
  String _selectedStatus = 'locked';
  int _order = 1;
  
  final List<Map<String, dynamic>> _games = [];
  bool _isSaving = false;
  bool _isEditing = false;
  String? _editingUnitId;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'favorite', 'icon': Icons.favorite},
    {'name': 'security', 'icon': Icons.security},
    {'name': 'verified_user', 'icon': Icons.verified_user},
    {'name': 'games', 'icon': Icons.games},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'psychology', 'icon': Icons.psychology},
  ];

  final List<String> _availableColors = [
    '#FFB6C1', // Rosa
    '#C9E090', // Verde
    '#B0C4DE', // Azul
    '#FFD700', // Dorado
    '#DDA0DD', // Púrpura
    '#F0E68C', // Amarillo
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && !_isEditing) {
      _isEditing = true;
      _editingUnitId = args['unitId'];
      final data = args['unitData'] as Map<String, dynamic>;
      
      _titleController.text = data['title'] ?? '';
      _subtitleController.text = data['subtitle'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _entryController.text = data['entry'] ?? '';
      _introductionController.text = data['introduction'] ?? '';
      _missionController.text = data['mission'] ?? '';
      _imageUrlController.text = data['imageUrl'] ?? '';
      _selectedIcon = data['icon'] ?? 'favorite';
      _selectedColor = data['color'] ?? '#FFB6C1';
      _selectedStatus = data['status'] ?? 'locked';
      _order = data['order'] ?? 1;
      
      if (data['games'] != null) {
        _games.addAll((data['games'] as List).cast<Map<String, dynamic>>());
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

  Color _getColorFromHex(String hexColor) {
    return Color(int.parse('0xFF${hexColor.substring(1)}'));
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_games.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes agregar al menos un juego')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final data = {
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'entry': _entryController.text.trim().isEmpty ? null : _entryController.text.trim(),
        'introduction': _introductionController.text.trim().isEmpty ? null : _introductionController.text.trim(),
        'mission': _missionController.text.trim().isEmpty ? null : _missionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        'gameDynamics': _gameDynamicsController.text.trim().isEmpty 
            ? null 
            : _gameDynamicsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'skills': _skillsController.text.trim().isEmpty 
            ? null 
            : _skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'icon': _selectedIcon,
        'color': _selectedColor,
        'status': _selectedStatus,
        'order': _order,
        'games': _games,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isEditing && _editingUnitId != null) {
        await FirebaseService.updateGameUnit(_editingUnitId!, data);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Unidad actualizada correctamente')),
        );
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseService.createGameUnit(data);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Unidad creada correctamente')),
        );
      }
      
      navigator.pop();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _addGame() {
    showDialog(
      context: context,
      builder: (ctx) => GameFormDialog(
        onSave: (game) {
          setState(() {
            _games.add(game);
          });
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
          setState(() {
            _games[index] = game;
          });
        },
      ),
    );
  }

  void _deleteGame(int index) {
    setState(() {
      _games.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        title: Text(
          _isEditing ? 'Editar Unidad' : 'Nueva Unidad',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título de la Unidad',
                  hintText: 'Ej: Zona Cero Odio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Subtitle
              TextFormField(
                controller: _subtitleController,
                decoration: InputDecoration(
                  labelText: 'Subtítulo',
                  hintText: 'Ej: Construyendo el Respeto Digital',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un subtítulo';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe brevemente la unidad...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Entry (Pequeña entrada) - OPTIONAL
              TextFormField(
                controller: _entryController,
                decoration: InputDecoration(
                  labelText: 'Pequeña Entrada (opcional)',
                  hintText: '¿Estás listo para esta aventura?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Introduction - OPTIONAL
              TextFormField(
                controller: _introductionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Introducción (opcional)',
                  hintText: 'Bienvenido a...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Mission - OPTIONAL
              TextFormField(
                controller: _missionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Misión (opcional)',
                  hintText: 'Tu misión: ...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Image URL - OPTIONAL
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'URL de Imagen (opcional)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Game Dynamics - OPTIONAL
              TextFormField(
                controller: _gameDynamicsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Dinámica del Juego (opcional, separado por comas)',
                  hintText: 'Analiza, Examina, Investiga',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Skills - OPTIONAL
              TextFormField(
                controller: _skillsController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Habilidades a Desarrollar (opcional, separado por comas)',
                  hintText: 'Pensamiento crítico, Empatía',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Icon selector
              const Text(
                'Icono',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableIcons.map((iconData) {
                  final isSelected = _selectedIcon == iconData['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconData['name'] as String;
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? AppStyles.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppStyles.primaryBlue : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        iconData['icon'] as IconData,
                        color: isSelected ? Colors.white : AppStyles.primaryBlue,
                        size: 30,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Color selector
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getColorFromHex(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppStyles.primaryBlue : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Status selector
              const Text(
                'Estado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'locked', child: Text('🔒 Bloqueado')),
                  DropdownMenuItem(value: 'in_progress', child: Text('🕐 En Progreso')),
                  DropdownMenuItem(value: 'completed', child: Text('✓ Completado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Games section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Juegos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppStyles.primaryBlue,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addGame,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Agregar Juego'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.accentGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_games.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(
                    child: Text(
                      'No hay juegos agregados.\nPresiona "Agregar Juego" para comenzar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppStyles.textLight),
                    ),
                  ),
                )
              else
                ...List.generate(_games.length, (index) {
                  final game = _games[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppStyles.lightGreen,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        game['title'] ?? 'Sin título',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(game['type'] ?? 'word_selection'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _editGame(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () => _deleteGame(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveUnit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditing ? 'Actualizar Unidad' : 'Crear Unidad',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
}
