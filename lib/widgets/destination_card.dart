import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination_model.dart';
import '../services/favorites_provider.dart';
import '../screens/detail_screen.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final bool isHorizontal;

  const DestinationCard({
    super.key,
    required this.destination,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFav = favoritesProvider.isFavorite(destination.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildImage() {
      return Stack(
        children: [
          Hero(
  tag: 'dest_img_${destination.id}',
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: destination.imageUrl.startsWith('http')
        ? Image.network(
            destination.imageUrl,
            height: isHorizontal ? 150 : 200,
            width: isHorizontal ? 260 : double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50),
                ),
              );
            },
          )
        : Image.asset(
            destination.imageUrl,
            height: isHorizontal ? 150 : 200,
            width: isHorizontal ? 260 : double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50),
                ),
              );
            },
          ),
  ),
),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          // Favorite Button
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.black87,
                  size: 20,
                ),
                onPressed: () {
                  favoritesProvider.toggleFavorite(destination.id);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav 
                            ? '${destination.name} dihapus dari Favorit' 
                            : '${destination.name} ditambahkan ke Favorit',
                      ),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Batal',
                        textColor: Colors.amber,
                        onPressed: () => favoritesProvider.toggleFavorite(destination.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Category Tag
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(destination.category).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                destination.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (isHorizontal) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(destination: destination),
            ),
          );
        },
        child: Container(
          width: 260,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildImage(),
              const SizedBox(width: 8, height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  destination.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        destination.address.split(',')[1].trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Vertical Layout (Standard Card)
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(destination: destination),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildImage(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    destination.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pantai':
        return const Color(0xFF00B2FF);
      case 'Budaya':
        return const Color(0xFFE040FB);
      case 'Religi':
        return const Color(0xFF00E676);
      case 'Sejarah':
        return const Color(0xFFFF1744);
      case 'Taman Margasatwa':
        return const Color(0xFF8D6E63);
      case 'Wisata Tani':
        return const Color(0xFF8BC34A);
      default:
        return Colors.blue;
    }
  }
}
