import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class RecipeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addRecipe({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> steps,
    required String image,
    required int numberOfPeople,
    required String cookingTime,
    required String cookingLevel,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(message: 'User not authenticated', code: '');
    }

    await _firestore.collection('recipes').add({
      'userId': user.uid,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'image': image,
      'timestamp': Timestamp.now(),
      'numberOfPeople': numberOfPeople,
      'cookingTime': cookingTime,
      'cookingLevel': cookingLevel,
    });
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _firestore.collection('recipes').doc(recipeId).delete();
  }
}