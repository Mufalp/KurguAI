import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/story_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'mydatabase');

  // Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      print("SUCCESS: Signed in anonymously with UID: \${userCredential.user?.uid}");
      return userCredential.user;
    } catch (e) {
      print("CRITICAL ERROR signing in anonymously: $e");
      return null;
    }
  }

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Save or update a story
  Future<void> saveStory(StoryModel story) async {
    if (currentUserId == null) {
      print("ERROR: Cannot save story, currentUserId is NULL. Did Anonymous Auth fail?");
      return;
    }
    
    DocumentReference docRef;
    if (story.id.isEmpty) {
      docRef = _firestore.collection('users').doc(currentUserId).collection('stories').doc();
      story.id = docRef.id;
    } else {
      docRef = _firestore.collection('users').doc(currentUserId).collection('stories').doc(story.id);
    }

    story.lastUpdated = DateTime.now();
    print("Saving story '${story.title}' to Firebase...");
    try {
      await docRef.set(story.toJson(), SetOptions(merge: true));
      print("Story saved successfully!");
    } catch (e) {
      print("ERROR saving story to Firestore: $e");
    }
  }

  // Get all stories for the current user
  Stream<List<StoryModel>> getUserStories() async* {
    if (currentUserId == null) {
      yield [];
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('stories')
          .orderBy('lastUpdated', descending: true)
          .get();
          
      yield snapshot.docs.map((doc) => StoryModel.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error loading stories: $e");
      yield [];
    }
  }
  // Delete a story
  Future<void> deleteStory(String storyId) async {
    if (currentUserId == null || storyId.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('stories')
          .doc(storyId)
          .delete();
      print("Story deleted successfully!");
    } catch (e) {
      print("Error deleting story: $e");
    }
  }
}
