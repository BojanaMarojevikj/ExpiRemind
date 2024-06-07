import 'package:flutter/material.dart';
import '../../domain/enums/product_category.dart';

class CategoryIconSelector extends StatelessWidget {
  final Map<Category?, IconData> categoryIconMap;
  final Category? selectedCategory;
  final ValueChanged<Category?> onCategorySelected;

  const CategoryIconSelector({
    Key? key,
    required this.categoryIconMap,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SizedBox(
        height: 55.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: categoryIconMap.entries.map((entry) {
            final category = entry.key;
            final icon = entry.value;
            final isSelected = selectedCategory == category;

            return GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 10),
                      Icon(
                        icon,
                        color: isSelected ? Colors.blue : Colors.black,
                        size: 36,
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      child: Container(
                        height: 3,
                        width: 36,
                        color: Colors.blue,
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
