import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Category {
  food,
  beverage,
  medicine,
  cleaning,
  other,
}
final Map<Category?, IconData> categoryIconMap = {
  null: Icons.all_inclusive,
  Category.food: Icons.fastfood,
  Category.beverage: Icons.emoji_food_beverage_rounded,
  Category.medicine: Icons.medication,
  Category.cleaning: Icons.clean_hands_rounded,
  Category.other: Icons.more_horiz,
};
