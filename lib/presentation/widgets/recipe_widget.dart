import 'package:flutter/material.dart';
import 'package:expiremind/domain/models/recipe.dart';
import 'package:intl/intl.dart';

class RecipeWidget extends StatelessWidget {
  final Recipe recipe;

  RecipeWidget({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final formattedTimestamp =
    DateFormat.yMMMEd().add_jms().format(recipe.timestamp.toDate());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.image != null)
              Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        recipe.image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      color: Colors.black54,
                      child: Text(
                        recipe.title,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Color(0xFFe7edf6),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    recipe.title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8.0),
            Text(
              formattedTimestamp,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8.0),
            Text(
              recipe.description,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
