import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../domain/models/recipe.dart';

class RecipeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addRecipe(String title, String description, List<String> ingredients, List<String> steps, String image) async {
    await Firebase.initializeApp();
    final collection = _firestore.collection('recipes');
    collection.add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'image': image,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteRecipe(String recipeId) async {
    final collection = _firestore.collection('recipes');
    await collection.doc(recipeId).delete();
  }
}