import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../application/services/product_service.dart';
import '../../domain/enums/product_category.dart';
import '../../domain/enums/storage_location.dart';
import '../../domain/enums/unit.dart';
import '../../domain/models/product.dart';
import '../../application/services/notification_service.dart';


class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();

  final ProductService _productService = ProductService();
  final NotificationService _notificationService = NotificationService();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  Unit _unit = Unit.unit;
  Category _category = Category.other;
  StorageLocation _storage = StorageLocation.cabinet;
  DateTime? _buyDate;
  DateTime _expiryDate = DateTime.now();

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
      final name = _nameController.text;
      final quantity = double.parse(_quantityController.text);

      final buyDate = _buyDate;

      final product = Product(
        id: const Uuid().v4(),
        name: name,
        quantity: quantity,
        unit: _unit,
        category: _category,
        storage: _storage,
        expiryDate: _expiryDate,
        buyDate: buyDate,
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      await _productService.addProduct(product);

      _notificationService.scheduleNotification(product.id.hashCode, 'Product expired', 'Your product ${product.name} has expired.', _expiryDate);
      _notificationService.scheduleNotification(product.id.hashCode + 1, 'Product Expiring Soon', 'Your product ${product.name} is expiring today.', _expiryDate.subtract(const Duration(days: 1)).add(const Duration(hours: 12)));
      _notificationService.scheduleNotification(product.id.hashCode + 2, 'Product Expiring Soon', 'Your product ${product.name} is expiring soon.', _expiryDate.subtract(const Duration(days: 3)).add(const Duration(hours: 12)));

      Navigator.of(context).pop(product);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  'Product Name',
                  style: GoogleFonts.poppins(
                      textStyle:
                          const TextStyle(color: Colors.black, fontSize: 18.0)),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  key: const ValueKey('nameInput'),
                  decoration: InputDecoration(
                    hintText: 'Name',
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
                  controller: _nameController,
                ),

                const SizedBox(height: 20.0),

                // Quantity
                Text(
                  'Total Product',
                  style: GoogleFonts.poppins(
                      textStyle:
                      const TextStyle(color: Colors.black, fontSize: 18.0)),
                ),
                const SizedBox(height: 5.0),
                Column(
                  children: [
                    TextFormField(
                      key: const ValueKey('quantityInput'),
                      decoration: InputDecoration(
                        hintText: '1.0',
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

                    const SizedBox(height: 5.0),

                    DropdownButtonFormField<Unit>(
                      value: _unit,
                      items: Unit.values
                          .map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(
                          unit.name,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => _unit = value!),
                      validator: (value) => value == null ? 'Please select a value.' : null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(8.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),

                // Category
                Text(
                  'Product Category',
                  style: GoogleFonts.poppins(
                      textStyle:
                      const TextStyle(color: Colors.black, fontSize: 18.0)),
                ),
                const SizedBox(height: 5.0),
                DropdownButtonFormField<Category>(
                  value: _category,
                  items: Category.values
                      .map((unit) => DropdownMenuItem(
                    value: unit,
                    child: Text(
                      unit.name,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                  validator: (value) => value == null ? 'Please select a value.' : null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(8.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),

                // Storage Location
                Text(
                  'Storage Location',
                  style: GoogleFonts.poppins(
                      textStyle:
                      const TextStyle(color: Colors.black, fontSize: 18.0)),
                ),
                const SizedBox(height: 5.0),
                DropdownButtonFormField<StorageLocation>(
                  value: _storage,
                  items: StorageLocation.values
                      .map((unit) => DropdownMenuItem(
                    value: unit,
                    child: Text(
                      unit.name,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _storage = value!),
                  validator: (value) => value == null ? 'Please select a value.' : null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(8.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),

                // Date Information
                Text(
                  'Date Information',
                  style: GoogleFonts.poppins(
                      textStyle:
                      const TextStyle(color: Colors.black, fontSize: 18.0)),
                ),
                const SizedBox(height: 5.0),

                // Buy Date
                Text(
                  'Buy Date',
                  style: GoogleFonts.poppins(
                      textStyle:
                      const TextStyle(color: Colors.black, fontSize: 14.0)),
                ),
                const SizedBox(height: 2.0),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _buyDate ?? DateTime.now(),
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() => _buyDate = pickedDate.toUtc().toLocal());
                        }
                      },
                    ),
                    Text(
                      _buyDate != null
                          ? DateFormat('dd-MM-yyyy').format(_buyDate!)
                          : 'No buy date selected',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),

                // Expiry Date
                Text(
                  'Expiry Date',
                  style: GoogleFonts.poppins(
                      textStyle:
                      const TextStyle(color: Colors.black, fontSize: 14.0)),
                ),
                const SizedBox(height: 2.0),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _expiryDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365 * 10)),
                        );
                        if (pickedDate != null) {
                          setState(() => _expiryDate = pickedDate.toUtc().toLocal());
                        }
                      },
                    ),
                    Text(DateFormat('dd-MM-yyyy').format(_expiryDate),
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                ElevatedButton(
                  onPressed: _addProduct,
                  child: const Text('Add Product'),
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16.0),
                    minimumSize: const Size(double.infinity, 40.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
