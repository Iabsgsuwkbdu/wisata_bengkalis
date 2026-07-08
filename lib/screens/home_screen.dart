import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/dummy_data.dart';
import '../widgets/category_pill.dart';
import '../widgets/destination_card.dart';
import '../widgets/glass_container.dart';
import '../services/favorites_provider.dart';
import '../services/destinations_provider.dart';
import 'explore_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Pantai',
    'Budaya',
    'Religi',
    'Sejarah',
    'Taman Margasatwa',
    'Wisata Tani'
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DestinationsProvider>()
          .fetchDestinationsFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoritesProvider>(context);
    final destProvider = Provider.of<DestinationsProvider>(context);
    print('Jumlah Destinasi: ${destProvider.destinations.length}');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter featured destinations
    final featuredList = destProvider.destinations.where((d) => d.isFeatured).toList();
    
    // Filter recommendations based on selected category (excluding featured)
    final recommendedList = destProvider.destinations.where((d) {
      if (_selectedCategory == 'Semua') return true;
      return d.category == _selectedCategory;
    }).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100), // Avoid bar overlap
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Greeting & Weather Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.userName,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0B63E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Weather Glass Indicator
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      borderRadius: BorderRadius.circular(16),
                      opacity: isDark ? 0.08 : 0.4,
                      child: Row(
                        children: [
                          const Icon(Icons.wb_cloudy_rounded, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bengkalis',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                '29°C • Cerah',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar redirection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to ExploreScreen (which is at index 1 of MainNavigation)
                    // But here we can just push a search route or open the navigation tab
                    // For the best UX, we push the search page directly or let them tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExploreScreen(autoFocusSearch: true),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161E31) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: isDark ? Colors.white60 : Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          'Cari Pantai Selatbaru, Sejarah...',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.tune_rounded, color: isDark ? const Color(0xFF00D1FF) : const Color(0xFF0B63E5)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Categories Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Kategori Wisata',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category Horizontal List
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return CategoryPill(
                      category: cat == 'Semua' ? 'Jelajah' : cat,
                      isSelected: _selectedCategory == cat,
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Horizontal Featured Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rekomendasi Utama',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExploreScreen(),
                          ),
                        );
                      },
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Featured Horizontal Slide
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 20),
                  itemCount: featuredList.length,
                  itemBuilder: (context, index) {
                    return DestinationCard(
                      destination: featuredList[index],
                      isHorizontal: true,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Dynamic Category Listing
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  _selectedCategory == 'Semua' 
                      ? 'Semua Objek Wisata' 
                      : 'Wisata $_selectedCategory',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Grid or vertical listing
              if (recommendedList.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('Tidak ada destinasi kategori ini.'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: recommendedList.length,
                  itemBuilder: (context, index) {
                    return DestinationCard(
                      destination: recommendedList[index],
                      isHorizontal: false,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
