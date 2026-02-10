import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/nexus_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
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
      routes: {
        '/add-product': (context) => const AddProductScreen(),
        '/new-customer': (context) => const NewCustomerScreen(),
        '/book-order': (context) => const BookOrderScreen(),
      },
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
