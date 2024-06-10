import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiremind/domain/enums/product_category.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expiremind/domain/models/product.dart';
import 'package:expiremind/presentation/widgets/inventory_item_widget.dart';
import 'package:expiremind/application/services/openai_service.dart';

import '../../application/services/product_service.dart';
import '../widgets/search_bar.dart';

class PrepareScreen extends StatefulWidget {
  @override
  _PrepareScreenState createState() => _PrepareScreenState();
}

class _PrepareScreenState extends State<PrepareScreen> {
  final ProductService _productService = ProductService();

  List<Product> _productList = [];
  List<Product> _selectedProducts = [];
  List<Product> _filteredList = [];
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final products = await _productService.getProducts();


    setState(() {
      _productList = products
          .where((product) =>
      product.category == Category.food ||
          product.category == Category.beverage)
          .toList();
      _filteredList = _productList;
    });
  }

  void _toggleProductSelection(Product product) {
    setState(() {
      if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _searchText = text;
      if (text.isEmpty) {
        _filteredList = _productList;
      } else {
        _filteredList = _productList
            .where((product) =>
            product.name.toLowerCase().contains(text.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _getRecipes() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Generating recipe..."),
            ],
          ),
        ),
      ),
    );

    OpenAIService openAIService = OpenAIService();
    String productNames = _selectedProducts.map((p) => p.name).join(', ');
    String prompt =
        "I have the following products: $productNames. Can you suggest a recipe using them? Follow this format:\n\nTitle: <title>\nDescription: <one sentence description>\nIngredients: <comma-separated ingredients>\nSteps: <numbered steps>";

    final recommendation = await openAIService.getRecommendations(prompt: prompt);
    if (recommendation != null) {
      final titlePattern = RegExp(r"Title:\s*(.*?)\s*Description:", caseSensitive: false);
      final descriptionPattern = RegExp(r"Description:\s*(.*?)\s*Ingredients:", caseSensitive: false);
      final ingredientsPattern = RegExp(r"Ingredients:\s*(.*?)\s*Steps:", caseSensitive: false);
      final stepsPattern = RegExp(r"Steps:\s*([\s\S]*)", caseSensitive: false);

      final titleMatch = titlePattern.firstMatch(recommendation);
      final descriptionMatch = descriptionPattern.firstMatch(recommendation);
      final ingredientsMatch = ingredientsPattern.firstMatch(recommendation);
      final stepsMatch = stepsPattern.firstMatch(recommendation);

      if (titleMatch != null && descriptionMatch != null && ingredientsMatch != null && stepsMatch != null) {
        final title = titleMatch.group(1);
        final description = descriptionMatch.group(1);
        final ingredientsString = ingredientsMatch.group(1);
        final stepsString = stepsMatch.group(1);

        if (title != null && description != null && ingredientsString != null && stepsString != null) {
          final ingredients = ingredientsString.split(',').map((e) => e.trim()).toList();
          final steps = stepsString.split(RegExp(r'\d+\.\s')).where((s) => s.isNotEmpty).map((s) => s.trim()).toList();

          final imagePrompt = "Generate an image for $title";
          final imageUrl = await openAIService.generateImage(imagePrompt);

          if (imageUrl != null) {
            FirebaseFirestore.instance.collection('recipes').add({
              'userId': FirebaseAuth.instance.currentUser!.uid,
              'title': title,
              'description': description,
              'ingredients': ingredients,
              'steps': steps,
              'image': imageUrl,
              'timestamp': Timestamp.now(),
            });

            Navigator.of(context).pop();

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Recipe generated successfully!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to generate recipe image')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to parse recommendation')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to parse recommendation')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get recommendation')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prepare'),
      ),
      body: Column(
        children: [
          ExpiRemindSearchBar(onChanged: _onSearchTextChanged),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                final product = _filteredList[index];
                return InkWell(
                  onTap: () => _toggleProductSelection(product),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectedProducts.contains(product),
                        onChanged: (bool? value) {
                          _toggleProductSelection(product);
                        },
                      ),
                      Expanded(child: InventoryItemWidget(product: product)),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed:
              _selectedProducts.isNotEmpty ? _getRecipes : null,
              child: const Text('Generate Recipe'),
            ),
          ),
        ],
      ),
    );
  }
}