import 'package:flutter/material.dart';
import '../../domain/enums/storage_location.dart';

class StorageIconSelector extends StatelessWidget {
  final Map<StorageLocation?, IconData> storageIconMap;
  final StorageLocation? selectedStorage;
  final ValueChanged<StorageLocation?> onStorageSelected;

  const StorageIconSelector({
    Key? key,
    required this.storageIconMap,
    required this.selectedStorage,
    required this.onStorageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xFFe7edf6),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SizedBox(
        height: 55.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: storageIconMap.entries.map((entry) {
            final storage = entry.key;
            final icon = entry.value;
            final isSelected = selectedStorage == storage;

            return GestureDetector(
              onTap: () => onStorageSelected(storage),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 10),
                      Icon(
                        icon,
                        color: isSelected ? Color(0xFF0D47A1) : Colors.black,
                        size: 36,
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      child: Container(
                        height: 3,
                        width: 36,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
