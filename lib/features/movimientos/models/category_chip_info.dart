import 'package:flutter/material.dart';

class CategoryChipInfo {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final int categoryID;

  const CategoryChipInfo({
    required this.categoryIcon,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryID,
  });
}
