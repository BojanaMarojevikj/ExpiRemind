import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum StorageLocation {
  fridge,
  freezer,
  cabinet,
  other,
}

final Map<StorageLocation?, IconData> storageIconMap = {
  null: Icons.all_inclusive,
  StorageLocation.fridge: Icons.kitchen,
  StorageLocation.cabinet: Icons.shelves,
  StorageLocation.freezer: Icons.ac_unit,
  StorageLocation.other: Icons.category,
};