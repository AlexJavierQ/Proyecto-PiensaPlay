import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  
  /// Creates a user document in `users` collection and returns the document id.
  static Future<String?> createUser(Map<String, dynamic> data) async {
    final coll = FirebaseFirestore.instance.collection('users');
    final doc = await coll.add(data);
    return doc.id;
  }

  /// Gets a user by tag.
  static Future<Map<String, dynamic>?> getUserByTag(String tag) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('tag', isEqualTo: tag)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return {'id': snapshot.docs.first.id, ...snapshot.docs.first.data()};
    }
    return null;
  }

  /// Validates tutor credentials and returns tutor data if valid.
  static Future<Map<String, dynamic>?> validateTutor(String username, String password) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tutors')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return {
        'id': snapshot.docs.first.id,
        ...snapshot.docs.first.data(),
      };
    }
    return null;
  }

  /// Fetches all glossary terms.
  static Stream<QuerySnapshot> getGlossaryTerms() {
    return FirebaseFirestore.instance.collection('glossary_terms').snapshots();
  }

  /// Adds a new glossary term.
  static Future<void> addGlossaryTerm(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('glossary_terms').add(data);
  }

  /// Deletes a glossary term.
  static Future<void> deleteGlossaryTerm(String id) async {
    await FirebaseFirestore.instance.collection('glossary_terms').doc(id).delete();
  }

  // ==================== GAME UNITS & ACTIVITIES ====================
  
  /// Fetches global game units (not linked to a class) - for exploration mode.
  /// Note: We fetch all units and filter client-side because Firestore's isNull
  /// only works for fields that explicitly exist with null value.
  static Stream<QuerySnapshot> getGameUnits() {
    // Get all units without filtering - filter happens on client if needed
    return FirebaseFirestore.instance
        .collection('game_units')
        .snapshots();
  }

  /// Fetches game units for a specific class.
  static Stream<QuerySnapshot> getClassGameUnits(String classId) {
    // Sin orderBy para evitar requerir índice compuesto en Firestore
    return FirebaseFirestore.instance
        .collection('game_units')
        .where('classId', isEqualTo: classId)
        .snapshots();
  }

  /// Fetches all game units (for admin/tutor view).
  static Stream<QuerySnapshot> getAllGameUnits() {
    return FirebaseFirestore.instance
        .collection('game_units')
        .orderBy('order')
        .snapshots();
  }

  /// Creates a new game unit.
  static Future<String?> createGameUnit(Map<String, dynamic> data) async {
    final doc = await FirebaseFirestore.instance.collection('game_units').add(data);
    return doc.id;
  }

  /// Updates a game unit.
  static Future<void> updateGameUnit(String id, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('game_units').doc(id).update(data);
  }

  /// Deletes a game unit.
  static Future<void> deleteGameUnit(String id) async {
    await FirebaseFirestore.instance.collection('game_units').doc(id).delete();
  }

  /// Fetches activities for a specific unit.
  static Stream<QuerySnapshot> getUnitActivities(String unitId) {
    return FirebaseFirestore.instance
        .collection('game_units')
        .doc(unitId)
        .collection('activities')
        .orderBy('order')
        .snapshots();
  }

  // ==================== GAME PROGRESS ====================
  
  static Future<void> saveGameProgress(String userId, String unitId, String activityId, Map<String, dynamic> progressData) async {
    final docId = '${userId}_${unitId}_${activityId}';
    final progressRef = FirebaseFirestore.instance.collection('user_progress').doc(docId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // 1. Guardar progreso
      transaction.set(progressRef, {
        'userId': userId,
        'unitId': unitId,
        'activityId': activityId,
        ...progressData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Incrementar saldo en billetera si hay puntos nuevos
      // Nota: Esto simplificadamente suma todos los puntos. Idealmente verificaríamos si ya se pagaron.
      // Para este prototipo, asumimos que cada 'save' es un intento exitoso nuevo o mejora.
      // Una lógica más robusta requeriría verificar el score anterior.
      if (progressData['score'] != null && progressData['score'] is int) {
        transaction.update(userRef, {
          'walletBalance': FieldValue.increment(progressData['score'] as int),
          'totalXp': FieldValue.increment(progressData['score'] as int),
        });
      }
    });
  }

  static Stream<QuerySnapshot> getUserProgress(String userId) {
    return FirebaseFirestore.instance
        .collection('user_progress')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // ==================== USER PROFILE & SHOP ====================

  /// Get user profile stream
  static Stream<DocumentSnapshot> getUserStream(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  /// Purchase an item from the shop
  static Future<bool> purchaseItem(String userId, String itemId, int cost, Map<String, dynamic> itemData) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    
    try {
      return await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return false;

        final currentBalance = userDoc.data()?['walletBalance'] as int? ?? 0;
        if (currentBalance < cost) return false; // Saldo insuficiente

        // Descontar saldo y añadir item al inventario
        transaction.update(userRef, {
          'walletBalance': FieldValue.increment(-cost),
          'inventory': FieldValue.arrayUnion([itemData]),
        });
        
        return true;
      });
    } catch (e) {
      print('Error purchasing item: $e');
      return false;
    }
  }

  /// Equip an item (avatar, frame, theme)
  static Future<void> equipItem(String userId, String type, String value) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'equipped_$type': value,
    });
  }

  // ==================== CLASSES MANAGEMENT ====================

  /// Creates a new class
  static Future<String?> createClass(Map<String, dynamic> data) async {
    final doc = await FirebaseFirestore.instance.collection('classes').add(data);
    return doc.id;
  }

  /// Updates an existing class
  static Future<void> updateClass(String id, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('classes').doc(id).update(data);
  }

  /// Get classes for a tutor
  static Stream<QuerySnapshot> getTutorClasses(String tutorId) {
    return FirebaseFirestore.instance
        .collection('classes')
        .where('tutorId', isEqualTo: tutorId)
        .snapshots();
  }

  /// Get classes for a student
  static Stream<QuerySnapshot> getStudentClasses(String userId) {
    return FirebaseFirestore.instance
        .collection('class_members')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  /// Get class details by ID
  static Future<Map<String, dynamic>?> getClassById(String classId) async {
    final doc = await FirebaseFirestore.instance.collection('classes').doc(classId).get();
    if (doc.exists) {
      return {'id': doc.id, ...doc.data()!};
    }
    return null;
  }

  /// Join a class with code
  static Future<Map<String, dynamic>> joinClass(String userId, String code) async {
    final db = FirebaseFirestore.instance;
    
    // Find class by code
    final classSnapshot = await db
        .collection('classes')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();
    
    if (classSnapshot.docs.isEmpty) {
      return {'success': false, 'error': 'Código no encontrado'};
    }
    
    final classDoc = classSnapshot.docs.first;
    final classId = classDoc.id;
    final className = classDoc.data()['name'] ?? 'Clase';
    
    // Check if already a member
    final memberCheck = await db
        .collection('class_members')
        .where('classId', isEqualTo: classId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    
    if (memberCheck.docs.isNotEmpty) {
      return {'success': false, 'error': 'Ya eres miembro de esta clase'};
    }
    
    // Get user data
    final userDoc = await db.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};
    
    // Add as member
    await db.collection('class_members').add({
      'classId': classId,
      'userId': userId,
      'name': userData['name'] ?? 'Estudiante',
      'tag': userData['tag'] ?? '000000',
      'xp': userData['totalXp'] ?? 0,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    
    // Update student count
    await db.collection('classes').doc(classId).update({
      'studentCount': FieldValue.increment(1),
    });
    
    return {'success': true, 'className': className, 'classId': classId};
  }

  /// Get students in a class
  static Stream<QuerySnapshot> getClassStudents(String classId) {
    return FirebaseFirestore.instance
        .collection('class_members')
        .where('classId', isEqualTo: classId)
        .snapshots();
  }

  /// Get units for a specific class
  static Stream<QuerySnapshot> getClassUnits(String classId) {
    return FirebaseFirestore.instance
        .collection('game_units')
        .where('classId', isEqualTo: classId)
        .snapshots();
  }

  /// Delete a class and all its data
  static Future<void> deleteClass(String classId) async {
    final db = FirebaseFirestore.instance;
    
    // Delete all members
    final members = await db.collection('class_members').where('classId', isEqualTo: classId).get();
    for (final doc in members.docs) {
      await doc.reference.delete();
    }
    
    // Delete all units in this class
    final units = await db.collection('game_units').where('classId', isEqualTo: classId).get();
    for (final doc in units.docs) {
      await doc.reference.delete();
    }
    
    // Delete the class
    await db.collection('classes').doc(classId).delete();
  }

  // ==================== DEMO DATA INITIALIZATION ====================
  
  /// Resets db and creates fresh demo data
  static Future<void> resetAndSeedData() async {
    final db = FirebaseFirestore.instance;
    print('🔄 Iniciando reinicio de datos...');
    
    // 1. Limpiar colecciones existentes (opcional, usar con cuidado)
    // Nota: En producción esto no se haría así, es solo para demo
    final units = await db.collection('game_units').get();
    for (var doc in units.docs) await doc.reference.delete();
    
    final glossary = await db.collection('glossary_terms').get();
    for (var doc in glossary.docs) await doc.reference.delete();

    final classes = await db.collection('classes').get();
    for (var doc in classes.docs) await doc.reference.delete();

    print('🗑️ Datos antiguos eliminados.');
    
    // 2. Crear Unidades Globales (Exploración) - classId = null
    print('🌍 Creando unidades de exploración...');
    
    // Unidad 1: VeracidadVille (Fake News)
    final unit1Ref = await db.collection('game_units').add({
      'title': 'VeracidadVille',
      'subtitle': 'Detectives de la verdad',
      'description': 'Aprende a identificar noticias falsas y protege la ciudad de la desinformación.',
      'status': 'available', // Siempre disponible en exploración
      'progress': 0.0,
      'order': 1,
      'color': 0xFFFBBF24, // Amber
      'icon': 'security',
      'classId': null, // ESENCIAL: Null para exploración global
      'activities': [
        {
          'id': 'act_fake_1',
          'title': 'El Gato Volador',
          'type': 'fake_news_detector',
          'status': 'available',
          'isReal': false,
          'content': 'Científicos afirman que los gatos han desarrollado alas invisibles.',
          'author': 'MundoLoco.com',
          'clues': ['Titular imposible', 'Fuente no científica', 'Sin pruebas visuales'],
          'instructions': 'Analiza la noticia y decide si es Real o Falsa basándote en las pistas.'
        },
        {
           'id': 'act_quiz_1',
           'title': 'Quiz de Verificación',
           'type': 'quiz',
           'status': 'locked',
           'questions': [
             {'q': '¿Qué es lo primero que debes chequear?', 'options': ['Fuente', 'La foto', 'Los likes'], 'correct': 0}
           ]
        }
      ]
    });

    // Unidad 2: Rompe Estereotipos
    await db.collection('game_units').add({
      'title': 'Rompe Estereotipos',
      'subtitle': 'Héroes de la inclusión',
      'description': 'Descubre cómo los prejuicios nos limitan y cómo superarlos.',
      'status': 'available',
      'progress': 0.0,
      'order': 2,
      'color': 0xFFAB47BC, // Purple
      'icon': 'diversity_3',
      'classId': null, // Global
      'activities': [
        {
          'id': 'act_stereo_1',
          'title': 'Gafas de la Realidad',
          'type': 'stereotype_breaker',
          'status': 'available',
          'instructions': 'Toca las imágenes que representan estereotipos injustos.',
          'scenarios': [
            {'title': 'Solo los niños juegan fútbol', 'isStereotype': true, 'icon': 57946}, // Icons.sports_soccer
            {'title': 'Las niñas son buenas en matemáticas', 'isStereotype': false, 'icon': 63529}, // Icons.calculate
            {'title': 'Los hombres no lloran', 'isStereotype': true, 'icon': 58051}, // Icons.face
          ]
        }
      ]
    });

    // 3. Crear Clase Demo y Unidades de Clase
    print('📚 Creando clases y contenido académico...');
    
    final classRef = await db.collection('classes').add({
      'name': 'Ética Digital 101',
      'code': 'ETICA1',
      'tutorId': 'demo_tutor',
      'description': 'Curso introductorio sobre ciudadanía digital.',
      'studentCount': 12,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Unidad Exclusiva de la Clase
    await db.collection('game_units').add({
      'title': 'Ciberbullying: Módulo de Clase',
      'subtitle': 'Tarea asignada: Empatía',
      'description': 'Unidad especial para discutir en clase sobre el acoso digital.',
      'status': 'available',
      'progress': 0.0,
      'order': 1,
      'color': 0xFF4CAF50, // Green
      'icon': 'chat',
      'classId': classRef.id, // ESENCIAL: Linked to class ID
      'activities': [
        {
          'id': 'act_class_1',
          'title': 'Palabras que Duelen',
          'type': 'word_selection',
          'status': 'available',
          'instructions': 'Selecciona las palabras que construyen en lugar de destruir.',
        }
      ]
    });

    // 4. Crear Glosario Global
    print('📖 Generando glosario...');
    final glossaryTerms = [
      {'term': 'Fake News', 'definition': 'Noticias falsas creadas para engañar.', 'category': 'Medios'},
      {'term': 'Ciberbullying', 'definition': 'Acoso entre menores usando medios digitales.', 'category': 'Seguridad'},
      {'term': 'Huella Digital', 'definition': 'Rastro de información que dejas al usar internet.', 'category': 'Privacidad'},
      {'term': 'Clickbait', 'definition': 'Titulares exagerados para ganar clics.', 'category': 'Medios'},
      {'term': 'Netiqueta', 'definition': 'Normas de comportamiento en internet.', 'category': 'Social'},
    ];
    
    for (final term in glossaryTerms) {
      await db.collection('glossary_terms').add(term);
    }
    
    print('✅ Datos reiniciados y sembrados con éxito.');
  }
}
