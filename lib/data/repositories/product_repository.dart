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
    return querySnapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
  }

  Future<void> addProduct(Product product) async {
    await Firebase.initializeApp();
    final collection = _firestore.collection('products');

    await collection.add({
      'id': product.id,
      'name': product.name,
      'quantity': product.quantity,
      'unit': product.unit.name,
      'category': product.category.name,
      'storage': product.storage.name,
      'expiryDate': product.expiryDate.toIso8601String(),
      'userId': _auth.currentUser!.uid,
    });
  }

  Future<void> updateProduct(Product product) async {
    final collection = _firestore.collection('products');
    await collection.doc(product.id).update({
      'name': product.name,
      'quantity': product.quantity,
      'unit': product.unit.name,
      'category': product.category.name,
      'storage': product.storage.name,
      'expiryDate': product.expiryDate.toIso8601String(),
    });
  }

  Future<void> deleteProduct(String productId) async {
    final collection = _firestore.collection('products');
    await collection.doc(productId).delete();
  }
}
