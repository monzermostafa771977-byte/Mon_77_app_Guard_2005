import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/hares_database.dart';
import 'screens/hares_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HaresDatabase.instance.database;
  runApp(const HaresApp());
}

class HaresApp extends StatelessWidget {
  const HaresApp({super.key});

  static const navy = Color(0xFF101B35);
  static const navy2 = Color(0xFF172746);
  static const gold = Color(0xFFD6AE59);
  static const ivory = Color(0xFFF4F0E5);

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
      surface: navy2,
    ).copyWith(primary: gold, secondary: gold, surface: navy2);

    return MaterialApp(
      title: 'حارس - HARES',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: scheme,
        scaffoldBackgroundColor: navy,
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: ivory,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: navy2,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: navy2,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const HaresShell(),
    );
  }
}
