import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/product_category.dart';
import '../../domain/enums/storage_location.dart';
import '../../domain/enums/unit.dart';
import '../../domain/models/product.dart';

class AddProductForm extends StatefulWidget {
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  Unit _unit = Unit.unit;
  Category _category = Category.other;
  StorageLocation _storage = StorageLocation.cabinet;
  DateTime? _buyDate; // Nullable DateTime for optional buy date
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Form field and validation logic here (omitted for brevity)

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      // Use the values from the controllers
      final name = _nameController.text;
      final quantity = double.parse(_quantityController.text);

      final product = Product(
        id: Uuid().v4(),
        name: name,
        // Use the name from the controller
        quantity: quantity,
        // Use the quantity from the controller
        unit: _unit,
        category: _category,
        storage: _storage,
        expiryDate: _expiryDate,
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      // Add product to Firestore
      await _addProductToFirestore(product);

      Navigator.of(context).pop(product);
    }
  }

  Future<void> _addProductToFirestore(Product product) async {
    await Firebase.initializeApp();

    final collection = FirebaseFirestore.instance.collection('products');

    await collection.add({
      'id': product.id,
      'name': product.name,
      'quantity': product.quantity,
      'unit': product.unit.name,
      'category': product.category.name,
      'storage': product.storage.name,
      'expiryDate': product.expiryDate.toIso8601String(),
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                key: ValueKey('nameInput'),
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name.';
                  }
                  return null;
                },
                controller: _nameController,
              ),

              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      key: ValueKey('quantityInput'),
                      decoration: InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity.';
                        } else if (double.tryParse(value) == null) {
                          return 'Please enter a valid quantity.';
                        }
                        return null;
                      },
                      controller: _quantityController,
                    ),
                  ),
                  SizedBox(
                    width: 100.0,
                    child: DropdownButtonFormField<Unit>(
                      value: _unit,
                      items: Unit.values
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit.name),
                              ))
                          .toList(),
                      onChanged: (unit) => setState(() => _unit = unit!),
                      validator: (value) =>
                          value == null ? 'Please select a unit.' : null,
                    ),
                  )
                ],
              ),

              DropdownButtonFormField<Category>(
                value: _category, // Set initial category
                items: Category.values
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        ))
                    .toList(),
                onChanged: (category) => setState(() => _category = category!),
                validator: (value) =>
                    value == null ? 'Please select a category.' : null,
              ),

              // Storage location dropdown
              DropdownButtonFormField<StorageLocation>(
                value: _storage, // Set initial storage location
                items: StorageLocation.values
                    .map((storage) => DropdownMenuItem(
                          value: storage,
                          child: Text(storage.name),
                        ))
                    .toList(),
                onChanged: (storage) => setState(() => _storage = storage!),
                validator: (value) =>
                    value == null ? 'Please select a storage location.' : null,
              ),

              // Optional buy date picker
              // You might need to install a date picker package for this
              Text('Buy Date (Optional)'),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _buyDate ?? DateTime.now(),
                        firstDate: DateTime(2015, 8),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() => _buyDate = pickedDate);
                      }
                    },
                  ),
                  Text(_buyDate?.toString() ?? 'No buy date selected'),
                ],
              ),

              // Expiry date picker
              Text('Expiry Date'),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _expiryDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(
                            days: 365 * 10)), // Allow future dates for a year
                      );
                      if (pickedDate != null) {
                        setState(() => _expiryDate = pickedDate);
                      }
                    },
                  ),
                  Text(_expiryDate?.toString() ?? 'No expiry date selected'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addProduct,
          child: Text('Add'),
        ),
      ],
    );
  }
}
