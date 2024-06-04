import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiremind/domain/enums/product_category.dart';
import 'package:expiremind/domain/enums/storage_location.dart';
import 'package:expiremind/domain/enums/unit.dart';

class Product {
  final String id;
  final String? image;
  final String name;
  final double quantity;
  final Unit unit;
  final Category category;
  final StorageLocation storage;
  final DateTime? buyDate;
  final DateTime expiryDate;
  final String userId;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.storage,
    required this.expiryDate,
    this.image,
    this.buyDate,
    required this.userId,
  });

  factory Product.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Product(
      id: snapshot.id,
      name: snapshot.get('name') as String,
      quantity: snapshot.get('quantity')! as double,
      unit: unitFromString(snapshot.get('unit')),
      category: categoryFromString(snapshot.get('category')),
      storage: storageFromString(snapshot.get('storage')),
      expiryDate: DateTime.parse(snapshot.get('expiryDate')),
      userId: snapshot.get('userId') as String,
    );
  }
}

Unit unitFromString(String unit) {
  return Unit.values.firstWhere((e) => e.toString().split('.').last == unit);
}

Category categoryFromString(String category) {
  return Category.values.firstWhere((e) => e.toString().split('.').last == category);
}

StorageLocation storageFromString(String storage) {
  return StorageLocation.values.firstWhere((e) => e.toString().split('.').last == storage);
}
