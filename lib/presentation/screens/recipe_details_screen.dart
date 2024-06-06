import 'package:flutter/material.dart';
import 'package:expiremind/domain/models/recipe.dart';
import 'package:intl/intl.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;

  RecipeDetailsScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final formattedTimestamp =
    DateFormat.yMMMEd().add_jms().format(recipe.timestamp.toDate());

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.image.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    recipe.image,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            Text(
              recipe.description,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              formattedTimestamp,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Card(
              elevation: 4.0,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingredients:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    ...recipe.ingredients.asMap().entries.map(
                          (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key + 1}.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              elevation: 4.0,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Steps:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    ...recipe.steps.asMap().entries.map(
                          (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Step ${entry.key + 1}: ${entry.value}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
