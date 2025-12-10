import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';

class AddGlossaryTermScreen extends StatefulWidget {
  const AddGlossaryTermScreen({super.key});

  @override
  State<AddGlossaryTermScreen> createState() => _AddGlossaryTermScreenState();
}

class _AddGlossaryTermScreenState extends State<AddGlossaryTermScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _questionController = TextEditingController();
  final _definitionController = TextEditingController();
  
  String _selectedIcon = 'menu_book'; // Default icon
  bool _isSaving = false;

  final Map<String, IconData> _availableIcons = {
    'menu_book': Icons.menu_book,
    'list_alt': Icons.list_alt,
    'share': Icons.share,
    'visibility': Icons.visibility,
    'warning_amber': Icons.warning_amber,
    'fingerprint': Icons.fingerprint,
    'fact_check': Icons.fact_check,
    'security': Icons.security,
    'lock': Icons.lock,
    'public': Icons.public,
  };

  Future<void> _saveTerm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    // Capture context-dependent objects before async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final data = {
        'title': _titleController.text.trim(),
        'question': _questionController.text.trim(),
        'definition': _definitionController.text.trim(),
        'icon': _selectedIcon,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseService.addGlossaryTerm(data);

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Término agregado correctamente')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Agregar Término',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Término'),
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration('Ej: Ciberseguridad'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),

              _buildLabel('Pregunta (para el niño)'),
              TextFormField(
                controller: _questionController,
                decoration: _buildInputDecoration('Ej: ¿Sabes cómo protegerte?'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),

              _buildLabel('Definición'),
              TextFormField(
                controller: _definitionController,
                maxLines: 4,
                decoration: _buildInputDecoration('Escribe la definición aquí...'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),

              _buildLabel('Icono'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedIcon,
                    isExpanded: true,
                    items: _availableIcons.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Row(
                          children: [
                            Icon(entry.value, color: AppStyles.primaryBlue),
                            const SizedBox(width: 12),
                            Text(entry.key),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedIcon = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTerm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar Término',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppStyles.primaryBlue,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppStyles.primaryBlue, width: 2),
      ),
    );
  }
}
