import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

import '../../application/services/product_service.dart';
import '../../domain/enums/product_category.dart';
import '../../domain/enums/storage_location.dart';
import '../../domain/enums/unit.dart';
import '../../domain/models/product.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late StreamSubscription<ConnectivityResult> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  final _formKey = GlobalKey<FormState>();

  final ProductService _productService = ProductService();

  bool _isEditEnabled = false;

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  Unit _unit = Unit.unit;
  Category _category = Category.other;
  StorageLocation _storage = StorageLocation.cabinet;
  DateTime? _buyDate;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    getConnectivity();
    _nameController.text = widget.product.name;
    _quantityController.text = widget.product.quantity.toString();
    _unit = widget.product.unit;
    _category = widget.product.category;
    _storage = widget.product.storage;
    _buyDate = widget.product.buyDate;
    _expiryDate = widget.product.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    subscription.cancel();
    super.dispose();
  }

  void getConnectivity() {
    subscription = Connectivity().onConnectivityChanged
        .asyncMap((results) => results.first)
        .listen((ConnectivityResult result) {
      isDeviceConnected = result != ConnectivityResult.none;
      if (!isDeviceConnected && !isAlertSet) {
        showDialogBox();
        setState(() => isAlertSet = true);
      } else if (isDeviceConnected && isAlertSet) {
        setState(() => isAlertSet = false);
      }
    });
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final quantity = double.parse(_quantityController.text);

      final product = Product(
        id: widget.product.id,
        name: name,
        quantity: quantity,
        unit: _unit,
        category: _category,
        storage: _storage,
        expiryDate: _expiryDate,
        buyDate: _buyDate,
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      await _productService.updateProduct(product);
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteProduct() async {
    await _productService.deleteProduct(widget.product.id);
    Navigator.of(context).pop();
    Navigator.pop(context, true);
  }

  void _toggleEditMode() => setState(() => _isEditEnabled = !_isEditEnabled);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details',style: GoogleFonts.poppins(
        textStyle: TextStyle(color: Color(0xFF0D47A1)),
    ),),
        actions: [
          IconButton(
            icon: Icon(_isEditEnabled ? Icons.save : Icons.edit),
            onPressed: _toggleEditMode,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Delete Product', style: GoogleFonts.poppins()),
                content:
                    const Text('Are you sure you want to delete this product?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',style: GoogleFonts.poppins(
    textStyle: TextStyle(color: Color(0xFF0D47A1)),
                  ),),
                  ),
                  TextButton(
                    onPressed: _deleteProduct,
                    child: Text('Delete', style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.red))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                enabled: _isEditEnabled,
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
                    enabled: _isEditEnabled,
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
                  const SizedBox(width: 10.0),
                  DropdownButtonFormField<Unit>(
                    value: _unit,
                    disabledHint: Text(_unit.name,
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        )),
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
                    onChanged: _isEditEnabled
                        ? (value) => setState(() => _unit = value!)
                        : null,
                    validator: (value) =>
                        value == null ? 'Please select a value.' : null,
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
                disabledHint: Text(_category.name,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                    )),
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
                onChanged: _isEditEnabled
                    ? (value) => setState(() => _category = value!)
                    : null,
                validator: (value) =>
                    value == null ? 'Please select a value.' : null,
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
                disabledHint: Text(_storage.name,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                    )),
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
                onChanged: _isEditEnabled
                    ? (value) => setState(() => _storage = value!)
                    : null,
                validator: (value) =>
                    value == null ? 'Please select a value.' : null,
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
                  _isEditEnabled
                      ? IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _buyDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() =>
                                  _buyDate = pickedDate.toUtc().toLocal());
                            }
                          },
                        )
                      : const IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed:
                              null, // Set onPressed to null when editing is disabled
                        ),
                  Text(
                    _buyDate != null
                        ? DateFormat('dd-MM-yyyy').format(_buyDate!)
                        : 'No buy date available',
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
                  _isEditEnabled
                      ? IconButton(
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
                              setState(() =>
                                  _expiryDate = pickedDate.toUtc().toLocal());
                            }
                          },
                        )
                      : const IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed:
                              null, // Set onPressed to null when editing is disabled
                        ),
                  Text(
                    DateFormat('dd-MM-yyyy').format(_expiryDate),
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

              _isEditEnabled
                  ? ElevatedButton(
                      onPressed: _updateProduct,
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16.0),
                        minimumSize: const Size(double.infinity, 40.0),
                      ),
                      child: Text('Save',style: GoogleFonts.poppins(
                        textStyle: TextStyle(color: Color(0xFF0D47A1)),
                      ),),
                    )
                  : ElevatedButton(
                      onPressed: _toggleEditMode,
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16.0),
                        minimumSize: const Size(double.infinity, 40.0),
                      ),
                      child: Text('Edit',style: GoogleFonts.poppins(
                      textStyle: TextStyle(color: Color(0xFF0D47A1)),
        ),),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
            'Your device is currently offline. Please check your internet connection and try again.',
            style: TextStyle(fontSize: 16.0),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
