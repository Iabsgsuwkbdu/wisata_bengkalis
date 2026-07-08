import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/favorites_provider.dart';
import 'services/destinations_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  print("========== MAIN BERJALAN ==========");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            print("CREATE DestinationsProvider");
            return DestinationsProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return MaterialApp(
      title: 'Eksplorasi Wisata Pulau Bengkalis',
      debugShowCheckedModeBanner: false,
      themeMode: favoritesProvider.isDarkTheme
          ? ThemeMode.dark
          : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}