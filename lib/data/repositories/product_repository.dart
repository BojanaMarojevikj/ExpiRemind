import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../domain/models/product.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Product>> fetchProducts() async {
    final collection = _firestore.collection('products');
    final querySnapshot = await collection
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .get();

    final products =
        querySnapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    products.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return products;
  }

  Future<void> addProduct(Product product) async {
    await Firebase.initializeApp();
    final collection = _firestore.collection('products');

    final productData = {
      'id': product.id,
      'name': product.name,
      'quantity': product.quantity,
      'unit': product.unit.name,
      'category': product.category.name,
      'storage': product.storage.name,
      'expiryDate': product.expiryDate.toIso8601String(),
      'userId': _auth.currentUser!.uid,
    };

    if (product.buyDate != null) {
      productData['buyDate'] = product.buyDate!.toIso8601String();
    }

    await collection.add(productData);
  }


  Future<void> updateProduct(Product product) async {
    final collection = _firestore.collection('products');

    final updateData = {
      'name': product.name,
      'quantity': product.quantity,
      'unit': product.unit.name,
      'category': product.category.name,
      'storage': product.storage.name,
      'expiryDate': product.expiryDate.toIso8601String(),
    };

    if (product.buyDate != null) {
      updateData['buyDate'] = product.buyDate!.toIso8601String();
    }

    await collection.doc(product.id).update(updateData);
  }


  Future<void> deleteProduct(String productId) async {
    final collection = _firestore.collection('products');
    await collection.doc(productId).delete();
  }
}
