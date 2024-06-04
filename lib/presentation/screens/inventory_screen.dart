import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiremind/domain/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/enums/product_category.dart';
import '../../domain/enums/storage_location.dart';
import '../../domain/enums/unit.dart';
import '../widgets/add_product_form.dart';
import '../widgets/inventory_item_widget.dart';
import 'login_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}
class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> _productList = []; // Initialize empty product list
  String? _highlightedProductId; // Optional variable for highlighting

  @override
  void initState() {
    super.initState();
    _updateProductList(); // Fetch products on screen initialization
  }

  void _updateProductList() async {
    // Get a reference to the Firestore collection
    final collection = FirebaseFirestore.instance.collection('products');

    // Query products for the current user
    final querySnapshot = await collection
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    // Update product list state (replace with your state management solution)
    setState(() {
      _productList =
          querySnapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
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
              // Get the added product from the form
              final product = await showDialog<Product>(
                context: context,
                builder: (context) => AddProductForm(),
              );

              // Check if product is not null (user might cancel the form)
              if (product != null) {
                // Update product list in InventoryScreen
                // (You'll need to implement this logic based on your data fetching approach)
                _updateProductList(); // Example function call (replace with your implementation)

                // Show success message (optional)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product added successfully!'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out the user
              Navigator.of(context).pushReplacement( // Navigate to LoginScreen
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
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
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _productList.length, // Use _productList state
              itemBuilder: (context, index) {
                final product = _productList[index];
                return InventoryItemWidget(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}
