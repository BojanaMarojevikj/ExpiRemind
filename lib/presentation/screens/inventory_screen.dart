import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiremind/domain/models/product.dart';
import 'package:expiremind/presentation/screens/product_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/add_product_form.dart';
import '../widgets/inventory_item_widget.dart';
import 'login_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}
class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> _productList = [];

  @override
  void initState() {
    super.initState();
    _updateProductList();
  }

  void _updateProductList() async {
    final collection = FirebaseFirestore.instance.collection('products');

    final querySnapshot = await collection
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

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
              itemCount: _productList.length,
              itemBuilder: (context, index) {
                final product = _productList[index];
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


