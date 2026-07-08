import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'map_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    MapScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      // Extend body behind the floating glass bottom navigation bar
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            borderRadius: BorderRadius.circular(30),
            opacity: isDark ? 0.08 : 0.4,
            blur: 15,
            borderWidth: 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Jelajah'),
                _buildNavItem(2, Icons.map_rounded, Icons.map_outlined, 'Peta'),
                _buildNavItem(3, Icons.favorite_rounded, Icons.favorite_border_rounded, 'Favorit'),
                _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.brightness == Brightness.dark ? Colors.white60 : Colors.black54;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected 
                  ? activeColor.withOpacity(0.12) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
