import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expiremind/application/services/recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:expiremind/domain/models/recipe.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  _RecipeDetailsScreenState createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late StreamSubscription<ConnectivityResult> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  final RecipeService _recipeService = RecipeService();

  @override
  void initState() {
    getConnectivity();
    super.initState();
  }

  void getConnectivity() {
    subscription = Connectivity().onConnectivityChanged
        .asyncMap((results) => results.first)
        .listen((ConnectivityResult result) {
      isDeviceConnected = result != ConnectivityResult.none;
      if (!isDeviceConnected && !isAlertSet) {
        showDialogBox();
        setState(() => isAlertSet = true);
      } else if (isDeviceConnected && isAlertSet) {
        setState(() => isAlertSet = false);
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> _deleteRecipe() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _recipeService.deleteRecipe(widget.recipe.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe deleted successfully'),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTimestamp =
    DateFormat.yMMMEd().add_jms().format(widget.recipe.timestamp.toDate());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.recipe.image.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    widget.recipe.image,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            Text(
              widget.recipe.description,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              formattedTimestamp,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ingredients:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    ...widget.recipe.ingredients.asMap().entries.map(
                          (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key + 1}.',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 16.0),
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
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Steps:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    ...widget.recipe.steps.asMap().entries.map(
                          (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Step ${entry.key + 1}: ${entry.value}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _deleteRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete Recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
            'Your device is currently offline. Please check your internet connection and try again.',
            style: TextStyle(fontSize: 16.0),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
