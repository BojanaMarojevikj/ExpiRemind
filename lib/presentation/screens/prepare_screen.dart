import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiremind/domain/enums/product_category.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expiremind/domain/models/product.dart';
import 'package:expiremind/presentation/widgets/inventory_item_widget.dart';
import 'package:expiremind/service/openai_service.dart';

class PrepareScreen extends StatefulWidget {
  @override
  _PrepareScreenState createState() => _PrepareScreenState();
}

class _PrepareScreenState extends State<PrepareScreen> {
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
    final collection = FirebaseFirestore.instance.collection('products');
    final querySnapshot = await collection
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      _productList = querySnapshot.docs
          .map((doc) => Product.fromSnapshot(doc))
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
    OpenAIService openAIService = OpenAIService();
    String productNames = _selectedProducts.map((p) => p.name).join(', ');
    String prompt =
        "I have the following products: $productNames. Suggest a recipe using them. Use simple words.";

    final recommendation = await openAIService.getRecommendations(prompt: prompt);
    if (recommendation != null) {
      FirebaseFirestore.instance.collection('recommendations').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'recommendation': recommendation,
        'timestamp': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recommendation: $recommendation')),
      );
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Inventory...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
              ),
              onChanged: _onSearchTextChanged,
            ),
          ),
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
              child: const Text('Generate Recipes'),
            ),
          ),
        ],
      ),
    );
  }
}