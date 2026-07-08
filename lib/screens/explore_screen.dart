import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dummy_data.dart';
import '../widgets/destination_card.dart';
import '../services/destinations_provider.dart';

class ExploreScreen extends StatefulWidget {
  final bool autoFocusSearch;

  const ExploreScreen({
    super.key,
    this.autoFocusSearch = false,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Pantai', 'Budaya', 'Religi', 'Sejarah', 'Taman Margasatwa', 'Wisata Tani'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destProvider = Provider.of<DestinationsProvider>(context);
    
    // Check if we can pop (opened as independent search screen)
    final canPop = Navigator.canPop(context);

    // Apply search filter and category filter
    final filteredDestinations = destProvider.destinations.where((d) {
      final matchesSearch = d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.address.toLowerCase().contains(_searchQuery.toLowerCase());
          
      final matchesCategory = _activeCategory == 'Semua' || d.category == _activeCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Jelajah Bengkalis',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: _searchController,
              autofocus: widget.autoFocusSearch,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari pantai, kuliner, situs sejarah...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF161E31) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Category Selector Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _activeCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _activeCategory = cat;
                        });
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                    checkmarkColor: Colors.white,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),

          // Search Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Menampilkan ${filteredDestinations.length} Hasil',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Destination list
          Expanded(
            child: filteredDestinations.isEmpty
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Destinasi Tidak Ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba periksa kata kunci Anda atau ganti kategori pencarian.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filteredDestinations.length,
                    itemBuilder: (context, index) {
                      return DestinationCard(
                        destination: filteredDestinations[index],
                        isHorizontal: false,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
