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
    await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(docId)
        .set({
          'userId': userId,
          'unitId': unitId,
          'activityId': activityId,
          ...progressData,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  static Stream<QuerySnapshot> getUserProgress(String userId) {
    return FirebaseFirestore.instance
        .collection('user_progress')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
