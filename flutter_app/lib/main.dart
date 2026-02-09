import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/nexus_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NexusProvider()),
      ],
      child: const NexusApp(),
    ),
  );
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexusOMS',
      debugShowCheckedModeBanner: false,
      theme: NexusTheme.lightTheme,
      darkTheme: NexusTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: Consumer<NexusProvider>(
        builder: (context, provider, child) {
          if (provider.currentUser == null) {
            return LoginScreen();
          } else {
            return DashboardScreen();
          }
        },
      ),
    );
  }
}
