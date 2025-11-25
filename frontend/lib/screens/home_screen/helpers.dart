import "package:flutter/material.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";

/// Helper method to truncate description text
String getTruncatedDescription(String description, {int maxLength = 200}) {
  if (description.length <= maxLength) return description;
  return '${description.substring(0, maxLength)}...';
}

/// Helper method to convert place categories to chips with colors
List<({String label, Color backgroundColor})> getChipsFromPlace(Place place) {
  return place.categories.map((category) {
    // Map categories to colors
    Color color;
    switch (category.toLowerCase()) {
      case 'historical':
        color = Colors.amber;
        break;
      case 'religious':
        color = Colors.blue;
        break;
      case 'cultural':
        color = Colors.green;
        break;
      case 'most-visited':
      case 'top-rated':
      case 'must-visit':
        color = Colors.red;
        break;
      case 'shopping':
        color = Colors.purple;
        break;
      case 'landmark':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return (label: category, backgroundColor: color);
  }).toList();
}

/// Helper method to get color for a single category
Color getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'historical':
      return Colors.amber;
    case 'religious':
      return Colors.blue;
    case 'cultural':
      return Colors.green;
    case 'most-visited':
    case 'top-rated':
    case 'must-visit':
      return Colors.red;
    case 'shopping':
      return Colors.purple;
    case 'landmark':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

/// Helper method to build a category FilterChip
Widget buildCategoryChip(String category, {bool isSelected = false}) {
  final color = getCategoryColor(category);
  return FilterChip(
    label: Text(
      category,
      style: const TextStyle(
        fontFamily: "BeVietnamPro",
        fontWeight: FontWeight.w500,
      ),
    ),
    backgroundColor: color.withValues(alpha: 0.2),
    selectedColor: color,
    side: BorderSide(
      color: isSelected ? color : Colors.grey.shade300,
      width: 1,
    ),
    selected: isSelected,
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    onSelected: (selected) {
      // Optional: Add filter action here if needed
    },
  );
}
