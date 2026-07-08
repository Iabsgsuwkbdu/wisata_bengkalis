import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/destination_model.dart';
import '../services/favorites_provider.dart';
import '../widgets/glass_container.dart';

class DetailScreen extends StatefulWidget {
  final Destination destination;

  const DetailScreen({
    super.key,
    required this.destination,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _currentImageIndex = 0;
  bool _hasClaimedVisit = false;

  Future<void> _openMap() async {
  final lat = widget.destination.latitude;
  final lng = widget.destination.longitude;

  final Uri googleMapsUri = Uri.parse(
    'google.navigation:q=$lat,$lng'
  );

  if (await canLaunchUrl(googleMapsUri)) {
    await launchUrl(
      googleMapsUri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    final Uri webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'
    );

    await launchUrl(
      webUri,
      mode: LaunchMode.externalApplication,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFav = favoritesProvider.isFavorite(widget.destination.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Sliver App Bar containing Image Gallery
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? const Color(0xFF0A0F1D) : Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.4),
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border_rounded,
                          color: isFav ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          favoritesProvider.toggleFavorite(widget.destination.id);
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // PageView for Gallery Images
                      PageView.builder(
                        itemCount: widget.destination.galleryUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final imagePath = widget.destination.galleryUrls[index];
                          final isNetworkImage = imagePath.startsWith('http');

                          // Image loader widget helper
                          Widget buildImageWidget() {
                            if (isNetworkImage) {
                              return Image.network(imagePath, fit: BoxFit.cover);
                            } else {
                              return Image.asset(imagePath, fit: BoxFit.cover);
                            }
                          }

                          return buildImageWidget().buildWithErrorAndLoading(context);
                        },
                      ),
                      // Top gradient for app bar icons visibility
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bottom gradient for indicator visibility
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Image Count Indicator
                      Positioned(
                        bottom: 16,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${widget.destination.galleryUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Detail Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 120.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.destination.category,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Name
                      Text(
                        widget.destination.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),

                      // Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.destination.address,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // Description
                      Text(
                        'Deskripsi Wisata',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.destination.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Facilities
                      Text(
                        'Fasilitas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.destination.facilities.map((fac) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161E31) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getFacilityIcon(fac),
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  fac,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[300] : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Travel Details (Ticket & Hours)
                      Text(
                        'Informasi Tambahan',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        opacity: isDark ? 0.05 : 0.4,
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.schedule_rounded,
                              'Jam Buka',
                              widget.destination.openingHours,
                              isDark,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(thickness: 0.5),
                            ),
                            _buildInfoRow(
                              Icons.local_play_rounded,
                              'Tiket Masuk',
                              widget.destination.ticketPrice,
                              isDark,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(thickness: 0.5),
                            ),
                            _buildInfoRow(
                              Icons.phone_rounded,
                              'Kontak Layanan',
                              widget.destination.contact,
                              isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gamified Visited Button
                      if (!_hasClaimedVisit)
                        ElevatedButton.icon(
                          onPressed: () {
                            favoritesProvider.incrementVisited();
                            setState(() {
                              _hasClaimedVisit = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Kunjungan diklaim! +100 Koin Wisata ditambahkan ke profil Anda.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.stars_rounded, color: Colors.amber),
                          label: const Text('Saya Sedang Mengunjungi Tempat Ini!'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[800],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            border: Border.all(color: Colors.green.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Kunjungan Telah Diklaim ✅ (+100 Poin)',
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              opacity: isDark ? 0.15 : 0.8,
              borderWidth: 1.0,
              borderColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Estimasi Biaya',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.destination.ticketPrice.split('/')[0].trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _openMap,
                    icon: const Icon(Icons.directions_rounded),
                    label: const Text('Rute Peta'),
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
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getFacilityIcon(String facility) {
    final clean = facility.toLowerCase();
    if (clean.contains('parkir')) return Icons.local_parking_rounded;
    if (clean.contains('mushola') || clean.contains('ibadah')) return Icons.account_balance;
    if (clean.contains('toilet') || clean.contains('wc')) return Icons.wc_rounded;
    if (clean.contains('warung') || clean.contains('makan') || clean.contains('kuliner')) return Icons.restaurant_rounded;
    if (clean.contains('foto') || clean.contains('sunset')) return Icons.camera_alt_rounded;
    if (clean.contains('gajebo') || clean.contains('istirahat') || clean.contains('kursi')) return Icons.deck_rounded;
    if (clean.contains('pemandu')) return Icons.person_search_rounded;
    if (clean.contains('homestay') || clean.contains('hotel')) return Icons.hotel_rounded;
    if (clean.contains('jembatan') || clean.contains('susur')) return Icons.directions_walk_rounded;
    return Icons.check_circle_outline_rounded;
  }
}

// Extension Helper untuk menghindari duplikasi penulisan penanganan error gambar
extension ImageExtension on Widget {
  Widget buildWithErrorAndLoading(BuildContext context) {
    if (this is Image) {
      final img = this as Image;
      return Image(
        image: img.image,
        fit: img.fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator.adaptive()),
          );
        },
      );
    }
    return this;
  }
}