import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expiremind/domain/models/recipe.dart';
import 'package:expiremind/presentation/screens/recipe_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../widgets/recipe_widget.dart';

class RecipesScreen extends StatefulWidget {
  @override
  _RecipesScreenState createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  late StreamSubscription<ConnectivityResult> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;


  late List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    getConnectivity();
    _getRecipes();
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

  Future<void> _getRecipes() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _recipes =
            querySnapshot.docs.map((doc) => Recipe.fromSnapshot(doc)).toList();
      });
    } catch (error) {
      print("Error fetching recipes: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
      ),
      body: ListView.builder(
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailsScreen(recipe: recipe),
                ),
              ).then((value) {
                _getRecipes();
              });
            },
            child: RecipeWidget(recipe: recipe),
          );
        },
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
