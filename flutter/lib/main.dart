import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/nexus_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/new_customer_screen.dart';
import 'screens/book_order_screen.dart';
import 'screens/material_master_screen.dart';
import 'screens/distributor_price_screen.dart';
import 'screens/customer_master_screen.dart';
import 'screens/od_master_screen.dart';
import 'screens/user_master_screen.dart';
import 'screens/delivery_master_screen.dart';
import 'screens/user_credentials_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/main_navigation_screen.dart';
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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
    // Attempt auto-login
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.tryAutoLogin();
    
    // If logged in, sync user to NexusProvider and refresh data
    if (authProvider.isAuthenticated && mounted) {
      final nexusProvider = Provider.of<NexusProvider>(context, listen: false);
      nexusProvider.setCurrentUser(authProvider.currentUser);
      nexusProvider.setToken(authProvider.token);  // ← store token so all fetches are authenticated
      nexusProvider.refreshData();
    }
    
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
        '/material-master': (context) => const MaterialMasterScreen(),
        '/distributor-price': (context) => const DistributorPriceScreen(),
        '/customer-master': (context) => const CustomerMasterScreen(),
        '/od-master': (context) => const OdMasterScreen(),
        '/user-master': (context) => const UserMasterScreen(),
        '/delivery-master': (context) => const DeliveryMasterScreen(),
        '/user-credentials': (context) => const UserCredentialsScreen(),
        '/attendance': (context) => const AttendanceScreen(),

      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (_isInitializing) {
            return const SplashScreen();
          }
          
          if (!auth.isAuthenticated) {
            return LoginScreen();
          } else {
            return const MainNavigationScreen();
          }
        },
      ),
    );
  }
}
