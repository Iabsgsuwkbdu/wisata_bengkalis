import 'package:flutter/material.dart';

class CategoryPill extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryPill({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final categoryColor = _getCategoryColor(category);
    final iconData = _getCategoryIcon(category);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        avatar: Icon(
          iconData,
          size: 16,
          color: isSelected 
              ? Colors.white 
              : categoryColor,
        ),
        label: Text(
          category,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected 
                ? Colors.white 
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: categoryColor,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        backgroundColor: isDark 
            ? Colors.white.withOpacity(0.05) 
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: isSelected 
                ? Colors.transparent 
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pantai':
        return const Color(0xFF0B63E5); // Sea Blue
      case 'Budaya':
        return const Color(0xFFE040FB); // Orchid/Purple
      case 'Religi':
        return const Color(0xFF00E676); // Emerald Green
      case 'Sejarah':
        return const Color(0xFFFF1744); // Crimson/Red
      case 'Taman Margasatwa':
        return const Color(0xFF8D6E63); // Brown
      case 'Wisata Tani':
        return const Color(0xFF8BC34A); // Light Green
      default:
        return const Color(0xFF0B63E5);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pantai':
        return Icons.beach_access_rounded;
      case 'Budaya':
        return Icons.theater_comedy_rounded;
      case 'Religi':
        return Icons.church;
      case 'Sejarah':
        return Icons.account_balance_rounded; // Museum pillars
      case 'Taman Margasatwa':
        return Icons.pets_rounded;
      case 'Wisata Tani':
        return Icons.agriculture_rounded;
      default:
        return Icons.explore_rounded;
    }
  }
}
