import 'package:expiremind/application/services/product_service.dart';
import 'package:expiremind/domain/models/product.dart';
import 'package:expiremind/presentation/screens/product_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/enums/product_category.dart';
import '../widgets/add_product_form.dart';
import '../widgets/category_icon_selector.dart';
import '../widgets/inventory_item_widget.dart';
import 'package:expiremind/presentation/widgets/search_bar.dart';
import 'login_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ProductService _productService = ProductService();

  List<Product> _productList = [];
  List<Product> _filteredList = [];
  String _searchText = '';
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _updateProductList();
  }

  void _updateProductList() async {
    final products = await _productService.getProducts();
    setState(() {
      _productList = products;
      _filterProducts();
    });
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _searchText = text;
      _filterProducts();
    });
  }

  void _onCategorySelected(Category? category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? null : category;
      _filterProducts();
    });
  }

  void _filterProducts() {
    setState(() {
      _filteredList = _productList.where((product) {
        final matchesCategory =
            _selectedCategory == null || product.category == _selectedCategory;
        final matchesSearchText =
            product.name.toLowerCase().contains(_searchText.toLowerCase());
        return matchesCategory && matchesSearchText;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final product = await showDialog<Product>(
                context: context,
                builder: (context) => const AddProductForm(),
              );

              if (product != null) {
                _updateProductList();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product added successfully!'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ExpiRemindSearchBar(onChanged: _onSearchTextChanged),
          CategoryIconSelector(
            categoryIconMap: categoryIconMap,
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                final product = _filteredList[index];
                return InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailsScreen(product: product),
                      ),
                    );

                    if (result == true) {
                      _updateProductList();
                    }
                  },
                  child: InventoryItemWidget(product: product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
