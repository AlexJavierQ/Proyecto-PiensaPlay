import 'dart:async';

// Removed unused Flutter imports; no UI or debugPrint needed here.

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // No explicit initialization check needed if we assume main.dart does it.
  // But we can keep a simple check if we want, or just trust main.
  
  /// Creates a user document in `users` collection and returns the document id.
  static Future<String?> createUser(Map<String, dynamic> data) async {
    final coll = FirebaseFirestore.instance.collection('users');
    final doc = await coll.add(data);
    return doc.id;
  }

  /// Validates tutor credentials. Returns tutor ID if valid, null otherwise.
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

  // ==================== GAME UNITS ====================
  
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

  // ==================== GAME PROGRESS ====================
  
  /// Saves or updates game progress for a user.
  static Future<void> saveGameProgress(Map<String, dynamic> data) async {
    final userId = data['userId'];
    final unitId = data['unitId'];
    final gameId = data['gameId'];
    
    final query = await FirebaseFirestore.instance
        .collection('game_progress')
        .where('userId', isEqualTo: userId)
        .where('unitId', isEqualTo: unitId)
        .where('gameId', isEqualTo: gameId)
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('game_progress').add(data);
    } else {
      await FirebaseFirestore.instance
          .collection('game_progress')
          .doc(query.docs.first.id)
          .update(data);
    }
  }

  /// Gets all game progress for a specific user.
  static Stream<QuerySnapshot> getUserProgress(String userId) {
    return FirebaseFirestore.instance
        .collection('game_progress')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
