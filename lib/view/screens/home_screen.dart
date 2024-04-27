import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Hello, Christie Doe',
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle scan new product button press
                  },
                  icon: Icon(Icons.qr_code_scanner),
                  label: Text('Scan new product'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle add new product button press
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add new product'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'My products',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            // List or grid to display products here
            Text(
              'Recommendations',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            // List or grid to display recommendations here
          ],
        ),
      ),
    );
  }
}