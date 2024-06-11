import 'package:expiremind/data/repositories/recipe_repository.dart';

class RecipeService {
  final RecipeRepository _recipeRepository = RecipeRepository();

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
    await _recipeRepository.addRecipe(
      title: title,
      description: description,
      ingredients: ingredients,
      steps: steps,
      image: image,
      numberOfPeople: numberOfPeople,
      cookingTime: cookingTime,
      cookingLevel: cookingLevel,
    );
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _recipeRepository.deleteRecipe(recipeId);
  }
}