import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../domain/models/recipe.dart';

class RecipeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> deleteRecipe(String recipeId) async {
    final collection = _firestore.collection('recipes');
    await collection.doc(recipeId).delete();
  }
}