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

  /// Validates tutor credentials.
  static Future<String?> validateTutor(String username, String password) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tutors')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
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
  
  /// Fetches all game units.
  static Stream<QuerySnapshot> getGameUnits() {
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
  
  /// Creates demo data if it doesn't exist
  static Future<void> initializeDemoData() async {
    final db = FirebaseFirestore.instance;
    
    // Check if demo data already exists
    final unitsSnapshot = await db.collection('game_units').limit(1).get();
    if (unitsSnapshot.docs.isNotEmpty) {
      print('Demo data already exists, skipping initialization');
      return;
    }
    
    print('Creating demo data...');
    
    // 1. Create tutor account
    await db.collection('tutors').doc('demo_tutor').set({
      'username': 'tutor',
      'password': '123456',
      'name': 'Profesor Demo',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // 2. Create game units
    final unit1Ref = await db.collection('game_units').add({
      'title': 'VeracidadVille',
      'subtitle': '¿Estás listo para convertirte en un detective digital?',
      'description': 'Aprende a identificar información falsa',
      'status': 'in_progress',
      'progress': 0.0,
      'order': 1,
      'color': 0xFFFBBF24,
      'icon': 'security',
    });
    
    await db.collection('game_units').add({
      'title': 'Detective de Noticias',
      'subtitle': 'Aprende a identificar noticias falsas y fuentes confiables',
      'description': 'Desarrolla tu pensamiento crítico',
      'status': 'locked',
      'progress': 0.0,
      'order': 2,
      'color': 0xFF42A5F5,
      'icon': 'search',
    });
    
    await db.collection('game_units').add({
      'title': 'Rompe Estereotipos',
      'subtitle': 'Identifica y transforma estereotipos negativos',
      'description': 'Promueve la inclusión y respeto',
      'status': 'locked',
      'progress': 0.0,
      'order': 3,
      'color': 0xFFAB47BC,
      'icon': 'diversity_3',
    });
    
    await db.collection('game_units').add({
      'title': 'Camino de Palabras',
      'subtitle': 'Clasifica palabras constructivas o hirientes',
      'description': 'Aprende sobre ciberbullying',
      'status': 'locked',
      'progress': 0.0,
      'order': 4,
      'color': 0xFF4CAF50,
      'icon': 'chat',
    });
    
    // 3. Create activities for unit 1
    await unit1Ref.collection('activities').add({
      'title': 'Cazadores de Noticias Falsas',
      'subtitle': 'Detecta si la noticia es real o falsa',
      'type': 'fake_news_detector',
      'order': 1,
      'color': 0xFFF9879B,
      'icon': 'fact_check',
      'content': {
        'postTitle': 'ÚLTIMA HORA: Los gatos pueden volar',
        'postContent': 'Científicos descubren que los gatos tienen alas invisibles que les permiten volar cuando nadie los ve.',
        'postAuthor': 'Noticias Inventadas',
        'postFooter': 'Publicado hace 2 horas',
        'correctAnswer': 'fake',
        'clues': [
          'El título es muy sensacionalista',
          'No hay fuentes científicas verificables',
          'La información contradice la biología conocida'
        ],
      },
    });
    
    await unit1Ref.collection('activities').add({
      'title': 'Quiz de Verificación',
      'subtitle': 'Responde preguntas sobre cómo verificar información',
      'type': 'quiz',
      'order': 2,
      'color': 0xFF87CEEB,
      'icon': 'quiz',
      'content': {
        'questions': [
          {
            'question': '¿Qué debes hacer antes de compartir una noticia?',
            'options': ['Compartirla inmediatamente', 'Verificar la fuente', 'Agregarle emojis', 'Nada'],
            'correctIndex': 1,
          },
          {
            'question': '¿Cuál es una señal de noticia falsa?',
            'options': ['Tiene autor', 'Cita fuentes', 'Título muy exagerado', 'Fecha reciente'],
            'correctIndex': 2,
          }
        ],
      },
    });
    
    await unit1Ref.collection('activities').add({
      'title': 'Memoria de Conceptos',
      'subtitle': 'Encuentra las parejas de conceptos relacionados',
      'type': 'memory',
      'order': 3,
      'color': 0xFFBDB76B,
      'icon': 'psychology',
      'content': {
        'pairs': [
          {'term': 'Fake News', 'definition': 'Noticia Falsa'},
          {'term': 'Verificar', 'definition': 'Comprobar'},
          {'term': 'Fuente', 'definition': 'Origen'},
          {'term': 'Viral', 'definition': 'Se comparte mucho'},
        ],
      },
    });
    
    // 4. Create glossary terms
    final glossaryTerms = [
      {'term': 'Fake News', 'definition': 'Noticias falsas diseñadas para engañar o manipular a las personas.', 'category': 'Medios'},
      {'term': 'Ciberbullying', 'definition': 'Acoso o intimidación a través de medios digitales.', 'category': 'Seguridad'},
      {'term': 'Verificar', 'definition': 'Comprobar que la información es verdadera antes de creerla o compartirla.', 'category': 'Habilidades'},
      {'term': 'Fuente', 'definition': 'El origen de donde proviene una información o noticia.', 'category': 'Medios'},
      {'term': 'Estereotipo', 'definition': 'Idea generalizada y simplificada sobre un grupo de personas.', 'category': 'Sociedad'},
      {'term': 'Privacidad', 'definition': 'Derecho a mantener información personal protegida.', 'category': 'Seguridad'},
    ];
    
    for (final term in glossaryTerms) {
      await db.collection('glossary_terms').add(term);
    }
    
    print('Demo data created successfully!');
  }
}
