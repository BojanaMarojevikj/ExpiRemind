import 'package:expiremind/domain/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/enums/product_category.dart';
import '../../domain/enums/storage_location.dart';
import '../../domain/enums/unit.dart';
import '../widgets/inventory_item_widget.dart';
import 'login_screen.dart';


class InventoryScreen extends StatelessWidget {
  final List<Product> products = [
    Product(
      name: 'T-Shirt',
      quantity: 10,
      unit: Unit.unit,
      category: Category.other,
      storage: StorageLocation.cabinet,
      expiryDate: DateTime.now().add(const Duration(days: 1000)),
    ),
    Product(
      name: 'Water Bottle',
      quantity: 1,
      unit: Unit.unit,
      category: Category.food,
      storage: StorageLocation.pantry,
      expiryDate: DateTime.now().add(const Duration(days: 365)),
    ),
    Product(
      name: 'Coffee Beans',
      quantity: 1,
      unit: Unit.kg,
      category: Category.food,
      storage: StorageLocation.pantry,
      expiryDate: DateTime.now().add(const Duration(days: 365)),
    ),
  ];

  InventoryScreen({super.key});

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
            onPressed: () {
              // Implement functionality to add a new product (later)
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
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return InventoryItemWidget(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}
