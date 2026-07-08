import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dummy_data.dart';
import '../services/favorites_provider.dart';
import '../services/destinations_provider.dart';
import '../widgets/destination_card.dart';
import 'explore_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final destProvider = Provider.of<DestinationsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Match favorite IDs with dummy data destinations
    final favDestinations = destProvider.destinations.where((dest) {
      return favoritesProvider.favoriteIds.contains(dest.id);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Destinasi Favorit',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: favDestinations.isEmpty
          ? _buildEmptyState(context, isDark)
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              itemCount: favDestinations.length,
              itemBuilder: (context, index) {
                return DestinationCard(
                  destination: favDestinations[index],
                  isHorizontal: false,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glassmorphic icon badge
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFF0B63E5).withOpacity(0.06),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF0B63E5).withOpacity(0.12),
                  ),
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 70,
                  color: isDark ? Colors.white54 : const Color(0xFF0B63E5).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum Ada Favorit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kumpulkan destinasi impian Anda di Pulau Bengkalis di sini. Cukup ketuk ikon hati pada kartu objek wisata.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Switch page or open explore screen directly as a stack
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExploreScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.explore_rounded),
                label: const Text('Jelajahi Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
