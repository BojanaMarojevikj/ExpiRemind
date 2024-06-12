import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../application/services/barcode_service.dart';
import '../../application/services/date_scanning_service.dart';
import '../../application/services/notification_service.dart';
import '../../application/services/product_service.dart';
import '../../domain/enums/product_category.dart';
import '../../domain/enums/storage_location.dart';
import '../../domain/enums/unit.dart';
import '../../domain/models/env.dart';
import '../../domain/models/product.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  late StreamSubscription<ConnectivityResult> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  final _formKey = GlobalKey<FormState>();

  final ProductService _productService = ProductService();
  final NotificationService _notificationService = NotificationService();
  final BarcodeService _barcodeService = BarcodeService();
  final DateScanningService _dateScanningService = DateScanningService();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  Unit _unit = Unit.unit;
  Category _category = Category.other;
  StorageLocation _storage = StorageLocation.cabinet;
  DateTime? _buyDate;
  DateTime _expiryDate = DateTime.now();

  File? _image;
  String _detectedText = '';
  bool _isLoading = false;

  @override
  void initState() {
    getConnectivity();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    subscription.cancel();
    super.dispose();
  }

  void getConnectivity() {
    subscription = Connectivity()
        .onConnectivityChanged
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

  // Form field and validation logic here (omitted for brevity)

  Future<void> _getImage() async {
    setState(() {
      _isLoading = true;
    });

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      await _scanDate();

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanDate() async {
    if (_image == null) return;

    try {
      final detectedText =
          await _dateScanningService.scanTextFromImage(_image!);

      setState(() {
        _detectedText = detectedText;
      });
      print('Detected text: $_detectedText');

      final detectedDate =
          _dateScanningService.extractDateFromText(detectedText);

      if (detectedDate != null) {
        setState(() {
          _expiryDate = detectedDate;
        });
        print('Parsed date: $_expiryDate');
      } else {
        _showPopup('No valid date found.');
      }
    } catch (e) {
      _showPopup('No valid date found.');
    }
  }

  Future<void> _scanBarcode() async {
    String barcodeScanResult = await _barcodeService.scanBarcode();

    if (barcodeScanResult != '-1') {
      await _fetchProductInfo(barcodeScanResult);
    }
  }

  Future<void> _fetchProductInfo(String barcode) async {
    try {
      final product = await _barcodeService.fetchProductInfo(
          barcode, Env.barcodeLookupApiKey);
      setState(() {
        _nameController.text = product['title'] ?? '';
        _category = _mapCategory(product['category']);
      });
    } catch (e) {
      _showSnackBar("Product could not be found.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notice'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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

      _notificationService.scheduleNotification(product.id.hashCode, 'Product Expired', 'Your product ${product.name} has expired.', _expiryDate);
      _notificationService.scheduleNotification(product.id.hashCode + 1, 'Product Expiring Today', 'Your product ${product.name} expires today. Check whether it is still usable and use it as soon as possible.', _expiryDate.subtract(const Duration(days: 1)).add(const Duration(hours: 12)));
      _notificationService.scheduleNotification(product.id.hashCode + 2, 'Product Expiring Soon', 'Your product ${product.name} is about to expire. Use it or share it with someone you know.', _expiryDate.subtract(const Duration(days: 3)).add(const Duration(hours: 12)));

      Navigator.of(context).pop(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Product',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(color: Color(0xFF0D47A1)),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner_outlined),
            onPressed: _scanBarcode,
            tooltip: 'Scan Barcode',
          ),
        ],
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
                          setState(
                              () => _buyDate = pickedDate.toUtc().toLocal());
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
                    Expanded(
                      child: Row(
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
                                setState(() =>
                                    _expiryDate = pickedDate.toUtc().toLocal());
                              }
                            },
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
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.document_scanner_outlined),
                      onPressed: _getImage,
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                ElevatedButton(
                  onPressed: _addProduct,
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                    ),
                    minimumSize: const Size(double.infinity, 40.0),
                  ),
                  child: Text(
                    'Add Product',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(color: Color(0xFF0D47A1)),
                    ),
                  ),
                ),
              ],
            ),
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

  Category _mapCategory(String? categoryString) {
    final lowercaseCategory = categoryString?.toLowerCase();

    if (lowercaseCategory?.contains('food') == true) {
      return Category.food;
    } else if (lowercaseCategory?.contains('beverage') == true) {
      return Category.beverage;
    } else if (lowercaseCategory?.contains('medicine') == true) {
      return Category.medicine;
    } else if (lowercaseCategory?.contains('cleaning') == true) {
      return Category.cleaning;
    } else {
      return Category.other;
    }
  }
}
