import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/nexus_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/new_customer_screen.dart';
import 'screens/book_order_screen.dart';
import 'utils/theme.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'controllers/testdrive/drive_state_manager.dart';

import 'services/downloader_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Storage
  await Hive.initFlutter();
  await DriveStateManager.init();
  
  // Initialize Downloader
  await DownloaderService().initialize();

  runApp(

    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NexusProvider()),
      ],
      child: const NexusApp(),
    ),
  );
}

class NexusApp extends StatefulWidget {
  const NexusApp({super.key});

  @override
  State<NexusApp> createState() => _NexusAppState();
}

class _NexusAppState extends State<NexusApp> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for provider to initialize and check saved session
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexusOMS',
      debugShowCheckedModeBanner: false,
      theme: NexusTheme.lightTheme,
      darkTheme: NexusTheme.darkTheme,
      themeMode: ThemeMode.light,
      routes: {
        '/add-product': (context) => const AddProductScreen(),
        '/new-customer': (context) => const NewCustomerScreen(),
        '/book-order': (context) => const BookOrderScreen(),
      },
      home: Consumer<NexusProvider>(
        builder: (context, provider, child) {
          if (_isInitializing || provider.isLoading) {
            return const SplashScreen();
          }
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
