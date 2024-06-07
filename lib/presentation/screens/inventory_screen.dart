import 'package:expiremind/application/services/product_service.dart';
import 'package:expiremind/domain/models/product.dart';
import 'package:expiremind/presentation/screens/product_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/add_product_form.dart';
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

  @override
  void initState() {
    super.initState();
    _updateProductList();
  }

  void _updateProductList() async {
    final products = await _productService.getProducts();
    setState(() {
      _productList = products;
      _filteredList = _productList;
    });
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      if (text.isEmpty) {
        _filteredList = _productList;
      } else {
        _filteredList = _productList.where((product) => product.name.toLowerCase().contains(text.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventory',
          style: GoogleFonts.poppins(
              textStyle: const TextStyle(color: Colors.black, fontSize: 20.0)),
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
                        builder: (context) => ProductDetailsScreen(product: product),
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


