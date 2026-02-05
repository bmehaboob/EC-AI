import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/search_screen.dart';
import 'services/ec_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ECService()),
      ],
      child: const ECOpenApp(),
    ),
  );
}

class ECOpenApp extends StatelessWidget {
  const ECOpenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EC AI Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // Vibrant Violet/Blue
          brightness: Brightness.light,
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF00BFA6), // Teal accent
          surface: const Color(0xFFF8F9FA),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const SearchScreen(),
    );
  }
}
