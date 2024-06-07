import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpiRemindSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ExpiRemindSearchBar({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Inventory...',
          prefixIcon: const Icon(Icons.search),
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
        onChanged: onChanged,
      ),
    );
  }
}
