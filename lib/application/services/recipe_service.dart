import 'package:expiremind/data/repositories/recipe_repository.dart';

import '../../domain/models/recipe.dart';

class RecipeService {
  final RecipeRepository _recipeRepository = RecipeRepository();

  Future<void> deleteRecipe(String recipeId) async {
    await _recipeRepository.deleteRecipe(recipeId);
  }
}