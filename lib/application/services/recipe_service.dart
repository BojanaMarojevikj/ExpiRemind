import 'package:expiremind/data/repositories/recipe_repository.dart';

import '../../domain/models/recipe.dart';

class RecipeService {
  final RecipeRepository _recipeRepository = RecipeRepository();

  Future<void> addRecipe(String title, String description, List<String> ingredients, List<String> steps, String image) async {
    await _recipeRepository.addRecipe(title, description, ingredients, steps, image);
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _recipeRepository.deleteRecipe(recipeId);
  }
}