import 'package:expiremind/domain/enums/product_category.dart';
import 'package:expiremind/domain/enums/storage_location.dart';
import 'package:expiremind/domain/enums/unit.dart';

class Product {
  final String? image;
  final String name;
  final double quantity;
  final Unit unit;
  final Category category;
  final StorageLocation storage;
  final DateTime? buyDate;
  final DateTime expiryDate;

  Product({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.storage,
    required this.expiryDate,
    this.image,
    this.buyDate,
  });
}
