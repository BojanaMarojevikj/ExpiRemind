import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expiremind/application/services/product_service.dart';
import 'package:expiremind/domain/models/product.dart';
import 'package:expiremind/presentation/screens/product_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
  late StreamSubscription<ConnectivityResult> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  final ProductService _productService = ProductService();

  List<Product> _productList = [];
  List<Product> _filteredList = [];
  String _searchText = '';
  Category? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getConnectivity();
    _updateProductList();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
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

  void _updateProductList() async {
    setState(() {
      _isLoading = true;
    });
    final products = await _productService.getProducts();
    if (!mounted) return;
    setState(() {
      _productList = products;
      _filterProducts();
      _isLoading = false;
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
        title: const Text('Inventory',
          style: TextStyle(
            color: Color(0xFF0D47A1),
          ),),
        iconTheme: const IconThemeData(
          color: Color(0xFF0D47A1),
        ),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
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
