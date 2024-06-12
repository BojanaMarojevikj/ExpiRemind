import 'dart:convert';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

class BarcodeService {
  Future<String> scanBarcode() async {
    return await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);
  }

  Future<Map<String, dynamic>> fetchProductInfo(
      String barcode, String apiKey) async {
    final url =
        'https://api.barcodelookup.com/v3/products?barcode=$barcode&formatted=y&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['products'] != null && data['products'].isNotEmpty) {
          return data['products'][0];
        } else {
          throw Exception('No product information found for this barcode');
        }
      } else {
        throw Exception('Failed to fetch product information');
      }
    } catch (e) {
      throw Exception('Error fetching product information: $e');
    }
  }
}
