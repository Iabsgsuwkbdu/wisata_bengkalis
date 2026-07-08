import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Pesona Pesisir Selat Malaka',
      'subtitle': 'Jelajahi keindahan pantai eksotis seperti Pantai Selatbaru dan Pantai Prapat Tunggal yang berhadapan langsung dengan jalur internasional.',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Kekayaan Sejarah & Budaya Melayu',
      'subtitle': 'Saksikan keagungan Tari Zapin di Desa Meskom dan warisan cagar budaya bernilai sejarah tinggi dari era kolonial Belanda.',
      'image': 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Petualangan Kuliner & Religi',
      'subtitle': 'Nikmati kelezatan Lempuk Durian legendaris dan rasakan ketenteraman spiritual di Masjid Istiqomah serta Vihara Hok Ann Kiong tertua.',
      'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&auto=format&fit=crop&q=80',
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Images PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _onboardingData[index]['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.blue[900],
                    ),
                  ),
                  // Dark Linear Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                  // Content Layout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 100),
                        // Title
                        Text(
                          _onboardingData[index]['title']!,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
                        Text(
                          _onboardingData[index]['subtitle']!,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 140), // Reserved space for controls
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Skip Button at Top Right
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _navigateToMain,
              child: Text(
                'Lewati',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bottom Controls (Dots & Action Button)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dot Indicators
                Row(
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? const Color(0xFF00D1FF) // Turquoise
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                // Next/Get Started Button
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _onboardingData.length - 1) {
                      _navigateToMain();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B63E5), // Deep Blue
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage == _onboardingData.length - 1 ? 'Mulai' : 'Lanjut',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentPage == _onboardingData.length - 1 
                            ? Icons.check_circle_rounded 
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
