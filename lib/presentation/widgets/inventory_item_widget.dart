import 'package:flutter/material.dart';
import 'package:expiremind/domain/models/product.dart';

import '../../domain/enums/product_category.dart';



class InventoryItemWidget extends StatelessWidget {
  final Product product;

  InventoryItemWidget({required this.product});

  @override
  Widget build(BuildContext context) {
    final daysRemaining = _getDaysRemaining(product.expiryDate);
    final expiryLabel = _getExpiryLabel(daysRemaining);
    final expiryColor = _getExpiryColor(daysRemaining);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            backgroundImage: product.image != null ? NetworkImage(product.image!) : null,
            child: product.image == null
                ? (product.category != null ? Icon(categoryIconMap[product.category]!) : null)
                : null,
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 4.0),
                Row(
                  children: [
                    Text('${product.storage.name}  |  ${product.quantity} ${product.unit.name}'),
                  ],
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Container(
              color: expiryColor,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              child: Text(
                expiryLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getDaysRemaining(DateTime expiryDate) {
    final today = DateTime.now();
    final difference = expiryDate.difference(today).inDays;
    return difference;
  }

  String _getExpiryLabel(int daysRemaining) {
    if (daysRemaining <= 0) {
      return 'Expired';
    } else if (daysRemaining == 1) {
      return '1 Day Left';
    } else {
      return '$daysRemaining Days Left';
    }
  }

  Color _getExpiryColor(int daysRemaining) {
    if (daysRemaining <= 0) {
      return Colors.redAccent;
    } else if (daysRemaining <= 3) {
      return Colors.deepOrangeAccent;
    } else {
      return Colors.green;
    }
  }

}