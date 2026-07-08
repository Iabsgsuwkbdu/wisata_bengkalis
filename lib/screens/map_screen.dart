import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../data/dummy_data.dart';
import '../models/destination_model.dart';
import '../services/favorites_provider.dart';
import '../services/destinations_provider.dart';
import '../widgets/glass_container.dart';
import 'detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final PageController _pageController = PageController(viewportFraction: 0.82);
  
  int _activeCardIndex = 0;
  bool _isMovingMap = false;

  void _onMarkerTapped(int index, List<Destination> listDestinations) {
    setState(() {
      _activeCardIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _moveMapTo(listDestinations[index].latitude, listDestinations[index].longitude);
  }

  void _moveMapTo(double lat, double lng) {
    if (_isMovingMap) return;
    _isMovingMap = true;
    _mapController.move(LatLng(lat, lng), 12.5);
    Future.delayed(const Duration(milliseconds: 400), () {
      _isMovingMap = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destProvider = Provider.of<DestinationsProvider>(context);
    final listDestinations = destProvider.destinations.isNotEmpty 
        ? destProvider.destinations 
        : dummyDestinations;
    final activeIndex = _activeCardIndex.clamp(0, listDestinations.length - 1);

    // Build the Marker widgets list
    final List<Marker> markers = [];
    for (int i = 0; i < listDestinations.length; i++) {
      final dest = listDestinations[i];
      final isSelected = activeIndex == i;
      final catColor = _getCategoryColor(dest.category);

      markers.add(
        Marker(
          point: LatLng(dest.latitude, dest.longitude),
          width: isSelected ? 55 : 42,
          height: isSelected ? 55 : 42,
          child: GestureDetector(
            onTap: () => _onMarkerTapped(i, listDestinations),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? catColor : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? Colors.white : catColor,
                  width: isSelected ? 3.0 : 2.5,
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(dest.category),
                  size: isSelected ? 24 : 18,
                  color: isSelected ? Colors.white : catColor,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Base Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                listDestinations[activeIndex].latitude, 
                listDestinations[activeIndex].longitude,
              ),
              initialZoom: 11.5,
              minZoom: 9.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png' // Beautiful styled dark tile map
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.bengkalis.wisata',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Header Overlay Title
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: BorderRadius.circular(20),
              opacity: isDark ? 0.08 : 0.6,
              child: const Row(
                children: [
                  Icon(Icons.map_rounded, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peta Wisata Bengkalis',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ketuk pin untuk navigasi detail',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Slider Carousel
          Positioned(
            bottom: 110, // Height above bottom navigation bar
            left: 0,
            right: 0,
            height: 120,
            child: PageView.builder(
              controller: _pageController,
              itemCount: listDestinations.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _activeCardIndex = index;
                });
                _moveMapTo(listDestinations[index].latitude, listDestinations[index].longitude);
              },
              itemBuilder: (context, index) {
                final dest = listDestinations[index];
                return _buildMapCard(dest, isDark);
              },
            ),
          ),
          
          // Map Control Buttons (Floating on the right side)
          Positioned(
            right: 16,
            bottom: 245,
            child: Column(
              children: [
                _buildFloatingControl(
                  Icons.add, 
                  () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildFloatingControl(
                  Icons.remove, 
                  () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildFloatingControl(
                  Icons.my_location, 
                  () {
                    // Reset to center of Pulau Bengkalis
                    _mapController.move(LatLng(1.485, 102.115), 11.0);
                  },
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingControl(IconData icon, VoidCallback onPressed, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E31) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildMapCard(Destination dest, bool isDark) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFav = favoritesProvider.isFavorite(dest.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(destination: dest),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161E31).withOpacity(0.95) : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: dest.imageUrl.startsWith('http')
                  ? Image.network(
                      dest.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    )
                  : Image.asset(
                      dest.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dest.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        dest.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getCategoryColor(dest.category),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          dest.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Mini Action Buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => favoritesProvider.toggleFavorite(dest.id),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            )
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pantai':
        return Icons.beach_access_rounded;
      case 'Budaya':
        return Icons.theater_comedy_rounded;
      case 'Religi':
        return Icons.church;
      case 'Sejarah':
        return Icons.account_balance_rounded;
      case 'Taman Margasatwa':
        return Icons.pets_rounded;
      case 'Wisata Tani':
        return Icons.agriculture_rounded;
      default:
        return Icons.explore_rounded;
    }
  }
}
