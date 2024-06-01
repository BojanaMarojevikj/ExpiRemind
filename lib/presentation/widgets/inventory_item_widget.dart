import 'package:flutter/material.dart';
import 'package:expiremind/domain/models/product.dart';
import 'package:intl/intl.dart';



class InventoryItemWidget extends StatelessWidget {
  final Product product;

  InventoryItemWidget({required this.product});

  @override
  Widget build(BuildContext context) {
    final formattedExpiryDate = DateFormat('y MMMM d').format(product.expiryDate);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Circle avatar for image
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            backgroundImage: product.image != null ? NetworkImage(product.image!) : null,
            child: product.image == null ? Icon(Icons.image_not_supported_outlined) : null,
          ),
          SizedBox(width: 16.0),
          // Column for details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name (first row)
                Text(
                  product.name,
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 4.0),  // Add a small spacing between rows
                // Storage and quantity (second row)
                Row(
                  children: [
                    Text('${product.storage.name}  |  ${product.quantity} ${product.unit.name}'),
                  ],
                ),
              ],
            ),
          ),
          // Expiry date on the right
          Text(
            formattedExpiryDate,
            style: TextStyle(
              color: product.expiryDate.isBefore(DateTime.now()) ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}