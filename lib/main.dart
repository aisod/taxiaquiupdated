import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'services/game_service.dart';
import 'pages/landing_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          final service = GameService();
          service.initialize();
          return service;
        }),
      ],
      child: MaterialApp(
        title: 'Caça Taxas - Jogo Educativo sobre Impostos',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const LandingPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}