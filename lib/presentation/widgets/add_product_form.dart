import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../application/services/product_service.dart';
import '../../domain/enums/product_category.dart';
import '../../domain/enums/storage_location.dart';
import '../../domain/enums/unit.dart';
import '../../domain/models/env.dart';
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

  File? _image;
  String _detectedText = '';
  bool _isLoading = false;

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

      await _scanText();

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanText() async {
    if (_image == null) return;

    final inputImage = InputImage.fromFile(_image!);
    final textDetector = TextRecognizer();
    final RecognizedText recognisedText =
    await textDetector.processImage(inputImage);

    String detectedText = recognisedText.text;

    setState(() {
      _detectedText = detectedText;
    });
    print('Detected text: $_detectedText');

    _extractDateFromText(detectedText);

    textDetector.close();
  }

  void _extractDateFromText(String text) {
    // Comprehensive regex pattern to capture various date formats
    final datePattern = RegExp(
      r'\b(?:'
      r'(\d{1,2}[./-]\d{1,2}[./-]\d{2,4})|' // Matches 01.01.27, 01/01/2027, etc.
      r'(\d{1,2}\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\s+\d{2,4})|' // Matches 01 jan 27, 01 jan 2027, etc.
      r'(\d{4}[./-]\d{1,2})|' // Matches 2027.01, 2027-01, etc.
      r'(\d{1,2}\s+\d{4})|' // Matches 01 2027
      r'(\d{1,2}[./-]\d{4})|' // Matches 01.2027
      r'(\d{1,2}[./-]\d{1,2}[./-]\d{4})|' // Matches 05/02/2026
      r'(\d{1,2}\s+\d{1,2}\s+\d{4})|' // Matches 24 06 2024
      r'(\d{2}[./-\s]\d{4})|' // Matches 13-2024, 13/2024, 13.2024
      r'(\d{4}[./-\s]\d{2})|' // Matches 2024-12, 2024/12, 2024.12
      r'(\d{1,2}[./\s]\d{4})' // Matches 12 2024
      r')\b',
      caseSensitive: false,
    );

    final match = datePattern.firstMatch(text);

    if (match != null) {
      final dateString = match.group(0);

      if (dateString != null) {
        try {
          // Handle "dd-MM-yyyy" and "dd.MM.yyyy" format
          final parsedDate1 = DateFormat('dd-MM-yyyy').parseStrict(dateString.replaceAll(RegExp(r'[./\s]'), '-'));
          setState(() {
            _expiryDate = parsedDate1;
          });
          print('Parsed date (dd-MM-yyyy): $_expiryDate');
          return;
        } catch (e) {}

        try {
          // Handle "MM-dd-yyyy" format
          final parsedDate2 = DateFormat('MM-dd-yyyy').parseStrict(dateString.replaceAll(RegExp(r'[./\s]'), '-'));
          setState(() {
            _expiryDate = parsedDate2;
          });
          print('Parsed date (MM-dd-yyyy): $_expiryDate');
          return;
        } catch (e) {}

        try {
          // Handle "MM/yyyy" and "MM.yyyy" by assuming the first day of the month
          final partialDatePattern = RegExp(r'(\d{1,2})[./\s](\d{4})');
          final partialMatch = partialDatePattern.firstMatch(dateString);
          if (partialMatch != null) {
            int? month;
            int? year;

            if (partialMatch.group(1) != null && partialMatch.group(2) != null) {
              // Matches MM/yyyy or MM.yyyy
              month = int.parse(partialMatch.group(1)!);
              year = int.parse(partialMatch.group(2)!);
            }

            if (month != null && year != null) {
              final parsedDate3 = DateTime(year, month, 1);
              setState(() {
                _expiryDate = parsedDate3;
              });
              print('Parsed partial date: $_expiryDate');
              return;
            } else {
              print('Failed to parse date: $dateString');
              return;
            }
          }
        } catch (e) {}

        try {
          // Handle "yyyy/MM"  by assuming the first day of the month
          final partialDatePattern = RegExp(r'(\d{4})[./\s](\d{1,2})');
          final partialMatch = partialDatePattern.firstMatch(dateString);
          if (partialMatch != null) {
            int? month;
            int? year;

            if (partialMatch.group(1) != null && partialMatch.group(2) != null) {
              // Matches MM/yyyy or MM.yyyy
              month = int.parse(partialMatch.group(2)!);
              year = int.parse(partialMatch.group(1)!);
            }

            if (month != null && year != null) {
              final parsedDate3 = DateTime(year, month, 1);
              setState(() {
                _expiryDate = parsedDate3;
              });
              print('Parsed partial date: $_expiryDate');
              return;
            } else {
              print('Failed to parse date: $dateString');
              return;
            }
          }
        } catch (e) {}


        try {
          // Handle "MM/dd/yyyy" format for 05/02/2026
          final parsedDate4 = DateFormat('MM/dd/yyyy').parseStrict(dateString);
          setState(() {
            _expiryDate = parsedDate4;
          });
          print('Parsed date (MM/dd/yyyy): $_expiryDate');
          return;
        } catch (e) {}

        _showPopup('Failed to parse date: $dateString');
        print('Failed to parse date: $dateString');
      }
    } else {
      _showPopup('No valid date found in the text.');
    }
  }

  Future<void> _scanBarcode() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);

    if (barcodeScanResult != '-1') {
      await _fetchProductInfo(barcodeScanResult);
    }
  }

  Future<void> _fetchProductInfo(String barcode) async {
    String apiKey = Env.barcodeLookupApiKey;
    final url =
        'https://api.barcodelookup.com/v3/products?barcode=$barcode&formatted=y&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['products'] != null && data['products'].isNotEmpty) {
          final product = data['products'][0];
          setState(() {
            _nameController.text = product['manufacturer'] + ' - ' + product['title'] ?? '';
            _category = _mapCategory(product['category']);
          });
        } else {
          _showSnackBar('No product information found for this barcode');
        }
      } else {
        _showSnackBar('Failed to fetch product information');
      }
    } catch (e) {
      _showSnackBar('Error fetching product information: $e');
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
        title: Text('Add Product',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(color: Color(0xFF0D47A1)),
          ),),
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
                                setState(() => _expiryDate =
                                    pickedDate.toUtc().toLocal());
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
                    textStyle: const TextStyle(fontSize: 16.0, ),
                    minimumSize: const Size(double.infinity, 40.0),
                  ),
                  child: Text('Add Product',
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
