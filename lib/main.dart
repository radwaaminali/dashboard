import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://varadayztibvefnbgjns.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZhcmFkYXl6dGlidmVmbmJnam5zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1NTMwMjYsImV4cCI6MjA3OTEyOTAyNn0.S-sevGaEtQ2sIKoa9Ff5D9hSf93sifjKLjElmGvDYv8',
    );
    debugPrint('✅ Supabase initialized successfully!');
  } catch (e) {
    debugPrint('❌ Failed to initialize Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Luna Store Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF2C3E50),
        textTheme: GoogleFonts.robotoTextTheme(
          textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF34495E),
          elevation: 0,
        ),
        cardColor: const Color(0xFF34495E),
        iconTheme: const IconThemeData(color: Color(0xFF1ABC9C)),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF1ABC9C),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
