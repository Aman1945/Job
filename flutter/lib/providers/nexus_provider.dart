import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../config/api_config.dart';
import '../services/downloader_service.dart';

class NexusProvider with ChangeNotifier {
  // Use centralized configuration
  String get _baseUrl => ApiConfig.baseUrl;
  String get _socketUrl => ApiConfig.socketUrl;
  
  User? _currentUser;




  List<Order> _orders = [];
  List<Customer> _customers = [];
  List<Product> _products = [];
  List<User> _users = [];
  List<ProcurementItem> _procurementItems = [];
  List<DistributorPrice> _distributorPrices = [];
  List<Warehouse> _warehouses = [];
  bool _isLoading = false;
  String? _token; // Auth token stored here so all fetch methods use it automatically

  User? get currentUser => _currentUser;
  List<Order> get orders => _orders;
  List<Customer> get customers => _customers;
  List<Product> get products => _products;
  List<User> get users => _users;
  List<ProcurementItem> get procurementItems => _procurementItems;
  List<DistributorPrice> get distributorPrices => _distributorPrices;
  List<Warehouse> get warehouses => _warehouses;
  bool get isLoading => _isLoading;

  /// Returns orders visible to [user] based on sales hierarchy:
  /// Admin → all | RSM → team (ASM + their Sales) | ASM → their Sales | Sales → own
  List<Order> getVisibleOrdersFor(User? user) {
    if (user == null || user.role == UserRole.admin) return _orders;
    if (user.role == UserRole.rsm || user.role == UserRole.asm) {
      final teamIds = getTeamMemberIds(user);
      return _orders.where((o) => teamIds.contains(o.salespersonId)).toList();
    }
    // Sales / others — only own orders
    return _orders.where((o) => o.salespersonId == user.id).toList();
  }

  /// Returns customers visible to [user] — RSM/ASM see all; reserved for future salespersonId linking
  List<Customer> getVisibleCustomersFor(User? user) {
    if (user == null || user.role == UserRole.admin) return _customers;
    // Customers currently don't have salespersonId; RSM/ASM see all customers in their zone
    return _customers;
  }

  /// Recursively collects IDs of [manager] + all team members below (public for hierarchy screen)
  Set<String> getTeamMemberIds(User manager) {
    final Set<String> ids = {manager.id};
    for (final u in _users.where((u) => u.managerId == manager.id)) {
      ids.addAll(getTeamMemberIds(u));
    }
    return ids;
  }


  NexusProvider() {
    // Initial fetch
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    // Check for saved user session (Legacy: use user object only; AuthProvider is source of truth)
    final prefs = await SharedPreferences.getInstance();
    final String? savedUser = prefs.getString('user_session');
    if (savedUser != null) {
      try {
        final decoded = jsonDecode(savedUser);
        final userMap = decoded is Map && decoded['user'] != null
            ? decoded['user'] as Map<String, dynamic>
            : decoded as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
      } catch (_) {
        _currentUser = null;
      }
    }

    await refreshData();
    _isLoading = false;
    notifyListeners();
  }

  /// Public method to refresh all data from server
  Future<void> refreshData() async {
    await Future.wait([
      fetchUsers(),
      fetchCustomers(),
      fetchProducts(),
      fetchOrders(),
      fetchProcurementItems(),
      fetchDistributorPrices(),
      fetchWarehouses(),
    ]);
    notifyListeners();
  }

  // --- MOCK NOTIFICATION ENGINE ---
  Future<void> sendEmailNotification({
    required String recipient, 
    required String subject, 
    required String body
  }) async {
    // Simulate SMTP Latency
    await Future.delayed(const Duration(milliseconds: 800));
    print('------------------------------------------');
    print('📧 EMAIL TRIGGERED: $recipient');
    print('📝 SUBJECT: $subject');
    print('📄 BODY: $body');
    print('------------------------------------------');
  }

  // --- Auth ---

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userMap = data['user'];
        if (userMap != null && userMap is Map<String, dynamic>) {
          _currentUser = User.fromJson(userMap);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_session', jsonEncode(userMap));
        }
      } else {
        final data = jsonDecode(response.body);
        final errorMsg = data['message'] ?? data['error'] ?? 'Invalid credentials';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    notifyListeners();
  }

  /// Sync current user from AuthProvider after login so both providers show same user.
  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Store auth token so all fetch calls are automatically authenticated.
  void setToken(String? token) {
    _token = token;
  }

  // --- Fetching Data ---

  Future<void> fetchOrders({String? token}) async {
    try {
      final effectiveToken = token ?? _token;
      debugPrint('🛰️ Fetching orders from: $_baseUrl/orders');
      final response = await http.get(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          if (effectiveToken != null) 'Authorization': 'Bearer $effectiveToken',
        },
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _orders = data.map((json) => Order.fromJson(json)).toList();
        debugPrint('✅ Fetched ${_orders.length} orders');
        notifyListeners();
      } else {
        debugPrint('❌ Orders API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  Future<void> fetchProducts({String? token}) async {
    try {
      final effectiveToken = token ?? _token;
      debugPrint('🛰️ Fetching products...');
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: {
          if (effectiveToken != null) 'Authorization': 'Bearer $effectiveToken',
        },
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _products = data.map((json) => Product.fromJson(json)).toList();
        debugPrint('✅ Fetched ${_products.length} products');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
  }

  Future<void> fetchCustomers({String? token}) async {
    try {
      final effectiveToken = token ?? _token;
      debugPrint('🛰️ Fetching customers...');
      final response = await http.get(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          if (effectiveToken != null) 'Authorization': 'Bearer $effectiveToken',
        },
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _customers = data.map((json) => Customer.fromJson(json)).toList();
        debugPrint('✅ Fetched ${_customers.length} customers');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching customers: $e');
    }
  }

  Future<void> fetchDistributorPrices() async {
    try {
      debugPrint('🛰️ Fetching distributor prices...');
      final response = await http.get(
        Uri.parse('$_baseUrl/distributor-prices'),
        headers: {
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _distributorPrices = data.map((json) => DistributorPrice.fromJson(json)).toList();
        debugPrint('✅ Fetched ${_distributorPrices.length} distributor price entries');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ fetchDistributorPrices error (non-fatal): $e');
      // Keep existing (or empty) list on error — screen falls back to static data
    }
  }

  Future<void> fetchUsers() async {
    try {
      debugPrint('🛰️ Fetching users...');
      final response = await http.get(
        Uri.parse('$_baseUrl/users'),
        headers: {
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _users = data.map((json) => User.fromJson(json)).toList();
        debugPrint('✅ Fetched ${_users.length} users');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserAuditLogs(String userId, {String? token}) async {
    return fetchAuditLogs(userId: userId, token: token);
  }

  Future<List<Map<String, dynamic>>> fetchAuditLogs({
    String? userId, 
    String? entityType, 
    String? role,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
    String? token,         // JWT token from AuthProvider
  }) async {
    try {
      String url = '$_baseUrl/audit/logs?limit=$limit';
      if (userId != null && userId.isNotEmpty) url += '&userId=$userId';
      if (entityType != null && entityType.isNotEmpty) url += '&entityType=$entityType';
      if (role != null && role.isNotEmpty) url += '&role=$role';
      if (fromDate != null) url += '&fromDate=${fromDate.toIso8601String()}';
      if (toDate != null) url += '&toDate=${toDate.toIso8601String()}';
      
      debugPrint('🛰️ Fetching audit logs: $url');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null && data['data']['logs'] is List) {
          return List<Map<String, dynamic>>.from(data['data']['logs']);
        }
      } else {
        debugPrint('❌ Audit logs API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching audit logs: $e');
    }
    return [];
  }

  // --- Operations & Workflow ---

  Future<bool> updateOrderStatus(String orderId, String newStatus, {String? token}) async {
    // Decision Engine Logic
    String effectiveStatus = newStatus;
    if (newStatus == 'Credit Approved') {
      effectiveStatus = 'Pending WH Selection';
    } else if (newStatus == 'Warehouse Assigned') {
      effectiveStatus = 'Pending Packing';
    } else if (newStatus == 'Packed') {
      effectiveStatus = 'Cost Added';
    } else if (newStatus == 'Ready for Invoice') {
      effectiveStatus = 'Pending Invoicing';
    } else if (newStatus == 'Invoiced') {
      effectiveStatus = 'Ready for Dispatch';
    } else if (newStatus == 'Picked Up') {
      effectiveStatus = 'Out for Delivery';
    }

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': effectiveStatus}),
      );

      if (response.statusCode == 200) {
        await fetchOrders(token: token); // Refresh local list
        return true;
      } else {
        debugPrint('Failed to update status: ${response.statusCode} - ${response.body}');
        throw Exception('Server rejected status update: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow; // Do not use local fallback anymore
    }
  }

  Future<double> fetchLastRate(String customerId, String skuCode, {String? token}) async {
    try {
        final Map<String, String> headers = {};
        if (token != null) {
            headers['Authorization'] = 'Bearer $token';
        } else if (_token != null) {
            headers['Authorization'] = 'Bearer $_token';
        }

        final response = await http.get(
            Uri.parse('$_baseUrl/orders/last-rate/$customerId/$skuCode'),
            headers: headers,
        );
        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            return (data['rate'] ?? 0.0).toDouble();
        }
    } catch (e) {
        debugPrint('Error fetching last rate: $e');
    }
    return 0.0;
  }

  Future<Order?> fetchOrderById(String orderId, {String? token}) async {
    try {
      final Map<String, String> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return Order.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching order by ID: $e');
    }
    return null;
  }

  Future<bool> updateOrderItems(String orderId, List<OrderItem> items, {double? total, double? subTotal, double? gstAmount, String? token}) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/orders/$orderId/items'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': items.map((i) => i.toJson()).toList(),
          if (total != null) 'total': total,
          if (subTotal != null) 'subTotal': subTotal,
          if (gstAmount != null) 'gstAmount': gstAmount,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        await fetchOrders(token: token);
        return true;
      }
    } catch (e) {
      debugPrint('Error updating order items: $e');
    }
    return false;
  }

  /// Patches specific fields on an order (e.g., qcPhoto, salesPhotos URLs).
  Future<bool> patchOrderField(String orderId, Map<String, dynamic> fields, {String? token}) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(fields),
      );
      if (response.statusCode == 200) {
        await fetchOrders(token: token);
        return true;
      }
    } catch (e) {
      debugPrint('patchOrderField error: $e');
    }
    return false;
  }

  Future<bool> createOrder(
    String customerId,
    String customerName,
    List<Map<String, dynamic>> items, {
    List<File> photos = const [],
    String? remarks,
    String? token, // Added token parameter for auth
  }) async {
    double subTotal = 0;
    for (var item in items) {
      subTotal += (item['price'] as num) * (item['quantity'] as num);
    }
    double total = subTotal * 1.18; // Added 18% GST

    // Upload sales photos to DO Spaces first
  final List<String> photoUrls = [];
  if (photos.isNotEmpty) {
    // Build organized folder: Orders/CustomerName/SalespersonName_Date
    final dateStr = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final safeCustomer = customerName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final safeSales = (_currentUser?.name ?? 'Unknown').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final folder = 'Orders/$safeCustomer/${safeSales}_$dateStr';
    for (final photo in photos) {
      final url = await uploadPhoto(photo, folder: folder, token: token); // Passed token here
      if (url != null) photoUrls.add(url);
    }
  }

    final orderData = {
      'customerId': customerId,
      'customerName': customerName,
      'status': 'Pending Credit Approval',
      'total': total,
      'subTotal': subTotal,
      'gstAmount': subTotal * 0.18,
      'items': items,
      'salespersonId': _currentUser?.id,
      'createdAt': DateTime.now().toIso8601String(),
      if (photoUrls.isNotEmpty) 'salesPhotos': photoUrls,
      if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        await fetchOrders();
        return true;
      } else {
        debugPrint('Failed to create order: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create order: Server responded with ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      throw Exception('Network or server error while creating order.');
    }
  }

  /// Uploads a single image [File] to DigitalOcean Spaces via backend.
  /// Returns the public CDN URL or null on failure.
  Future<String?> uploadPhoto(File file, {String folder = 'uploads', String? token}) async {
    try {
      debugPrint('📸 [uploadPhoto] START — file: ${file.path}');
      final bytes = await file.readAsBytes();
      debugPrint('📸 [uploadPhoto] File size: ${bytes.length} bytes');
      final base64Image = base64Encode(bytes);
      final fileName = file.path.split(Platform.pathSeparator).last;
      debugPrint('📸 [uploadPhoto] Sending to: $_baseUrl/upload-photo — fileName: $fileName, folder: $folder');

      final response = await http.post(
        Uri.parse('$_baseUrl/upload-photo'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'base64Image': base64Image,
          'fileName': fileName,
          'folder': folder,
        }),
      );

      debugPrint('📸 [uploadPhoto] Response status: ${response.statusCode}');
      debugPrint('📸 [uploadPhoto] Response body: ${response.body.substring(0, response.body.length.clamp(0, 200))}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('📸 [uploadPhoto] SUCCESS — URL: ${data['url']}');
        return data['url'] as String?;
      } else {
        debugPrint('📸 [uploadPhoto] FAILED — status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('📸 [uploadPhoto] EXCEPTION: $e');
    }
    return null;
  }


  Future<bool> createSTN(Map<String, dynamic> stnData, {String? token}) async {
    final payload = {
      ...stnData,
      'isSTN': true,
      'status': 'In Transit',
      'createdAt': DateTime.now().toIso8601String(),
      'salespersonId': _currentUser?.id,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        await fetchOrders();
        return true;
      } else {
        debugPrint('Failed to create STN: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create STN: Server responded with ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating STN: $e');
      throw Exception('Network or server error while creating STN.');
    }
  }

  Future<bool> createCustomer(Map<String, dynamic> customerData, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(customerData),
      );

      if (response.statusCode == 201) {
        await fetchCustomers();
        return true;
      } else {
        debugPrint('Failed to create customer: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create customer: Server responded with ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating customer: $e');
      throw Exception('Network or server error while creating customer.');
    }
  }

  Future<bool> updateCustomer(String customerId, Map<String, dynamic> updates, {String? token}) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/customers/$customerId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        await fetchCustomers();
        return true;
      } else {
        debugPrint('Failed to update customer: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating customer: $e');
      return false;
    }
  }

  Future<bool> createProduct(Map<String, dynamic> productData, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201) {
        await fetchProducts();
        return true;
      } else {
        debugPrint('Failed to create product: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create product: Server responded with ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating product: $e');
      throw Exception('Network or server error while creating product.');
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        await fetchUsers();
        return true;
      } else {
        debugPrint('Failed to create user: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create user: Server responded with ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating user: $e');
      throw Exception('Network or server error while creating user.');
    }
  }

  // --- Analytics ---

  Future<Map<String, dynamic>?> fetchSalesHubData({String period = 'month', String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics/sales-hub?period=$period'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching sales hub data: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchReportData({required String type, String? startDate, String? endDate, String? token}) async {
    try {
      final queryParams = 'type=$type${startDate != null ? "&startDate=$startDate" : ""}${endDate != null ? "&endDate=$endDate" : ""}';
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics/reports?$queryParams'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching report data: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchPMSData({String? userId, String period = 'month', String? token}) async {
    try {
      final queryParams = 'period=$period' + (userId != null && userId.isNotEmpty ? '&userId=$userId' : '');
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics/pms?$queryParams'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching PMS data: $e');
    }
    return {};
  }

  Future<void> downloadReport({required String type, required String format, String? token}) async {
    final queryParams = 'type=${type.toLowerCase().replaceAll(' ', '_')}&format=${format.toLowerCase()}';
    final url = '$_baseUrl/analytics/export?$queryParams';
    
    await DownloaderService().downloadFile(
      url: url,
      fileName: "${type.replaceAll(' ', '_')}_Report.${format.toLowerCase()}",
      token: token,
    );
  }


  Future<void> fetchProcurementItems({String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/procurement'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _procurementItems = data.map((json) => ProcurementItem.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching procurement: $e');
    }
  }

  Future<bool> createProcurementEntry(Map<String, dynamic> data, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/procurement'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        await fetchProcurementItems(token: token);
        return true;
      } else {
        debugPrint('Failed to create procurement: ${response.statusCode}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating procurement: $e');
      throw Exception('Procurement creation failed - Connectivity issue.');
    }
  }

  Future<bool> updateProcurementItem(String id, Map<String, dynamic> updates, {String? token}) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/procurement/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      );
      if (response.statusCode == 200) {
        await fetchProcurementItems(token: token);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating procurement: $e');
      throw Exception('Failed to update procurement item.');
    }
  }

  Future<bool> deleteProcurementItem(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/procurement/$id'));
      if (response.statusCode == 200) {
        await fetchProcurementItems();
        return true;
      }
      return false;
    } catch (e) {
      _procurementItems.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    }
  }

  Future<Map<String, dynamic>> fetchCategorySplitData({String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics/category-split'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching category split data: $e');
    }
    return {};
  }

  Future<Map<String, dynamic>> fetchFleetIntelligenceData({String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics/fleet'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching fleet data: $e');
    }
    return {};
  }

  Future<bool> assignLogistics(List<String> orderIds, Map<String, dynamic> logisticsData, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/logistics/bulk-assign'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'orderIds': orderIds,
          'logisticsData': logisticsData,
        }),
      );

      if (response.statusCode == 200) {
        await fetchOrders();
        return true;
      } else {
        debugPrint('Failed to assign logistics: ${response.statusCode}');
        throw Exception('Logistics assignment failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error assigning logistics: $e');
      throw Exception('Network or server error during logistics assignment.');
    }
  }

  // Calculate logistics cost
  Future<Map<String, dynamic>?> calculateLogisticsCost({
    required String origin,
    required String destination,
    required String vehicleType,
    double? distance,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/logistics/calculate-cost'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'origin': origin,
          'destination': destination,
          'vehicleType': vehicleType,
          if (distance != null) 'distance': distance,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
    } catch (e) {
      debugPrint('Cost calculation error: $e');
    }
    return null;
  }

  Future<bool> importCustomers(String filePath, {String? token}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/customers/bulk-import'),
      );
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await fetchCustomers(token: token);
        return true;
      } else {
        debugPrint('Import error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error importing customers: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadCustomerTemplate() async {
    final url = '$_baseUrl/customers/import-template';
    await DownloaderService().downloadFile(
      url: url,
      fileName: "Customer_Master_Template.xlsx",
    );
  }

  Future<bool> importProducts(String filePath, {String? token}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/products/bulk-import'),
      );
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        await fetchProducts(token: token);
        return true;
      } else {
        debugPrint('Product import error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error importing products: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadProductTemplate() async {
    final url = '$_baseUrl/products/import-template';
    await DownloaderService().downloadFile(
      url: url,
      fileName: "Material_Master_Template.xlsx",
    );
  }

  Future<void> fetchWarehouses({String? token}) async {
    try {
      final effectiveToken = token ?? _token;
      debugPrint('🛰️ Fetching warehouses...');
      final response = await http.get(
        Uri.parse('$_baseUrl/warehouse/list'),
        headers: {
          if (effectiveToken != null) 'Authorization': 'Bearer $effectiveToken',
        },
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['warehouses'] ?? [];
        _warehouses = list.map((json) => Warehouse.fromJson(json)).toList();
        debugPrint('✅ Fetched ${_warehouses.length} warehouses');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching warehouses: $e');
    }
  }

  Future<bool> assignWarehouseToOrder(String orderId, String warehouseId, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/warehouse/assign-to-order'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'orderId': orderId,
          'warehouseId': warehouseId,
        }),
      );

      if (response.statusCode == 200) {
        await fetchOrders(token: token); // Refresh orders to get updated status and allocated batches
        return true;
      } else {
        debugPrint('Failed to assign warehouse: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error assigning warehouse: $e');
    }
    return false;
  }
}


