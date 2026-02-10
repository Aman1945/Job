import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

import '../services/downloader_service.dart';

class NexusProvider with ChangeNotifier {
  // Production Render URL
  static const String serverAddress = 'nexus-oms-backend.onrender.com';
  final String _baseUrl = 'https://$serverAddress/api';
  final String _socketUrl = 'https://$serverAddress';
  
  User? _currentUser;




  List<Order> _orders = [];
  List<Customer> _customers = [];
  List<Product> _products = [];
  List<User> _users = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  List<Order> get orders => _orders;
  List<Customer> get customers => _customers;
  List<Product> get products => _products;
  List<User> get users => _users;
  bool get isLoading => _isLoading;

  NexusProvider() {
    // Initial fetch
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    // Check for saved user session
    final prefs = await SharedPreferences.getInstance();
    final String? savedUser = prefs.getString('user_session');
    if (savedUser != null) {
      _currentUser = User.fromJson(jsonDecode(savedUser));
    }

    await Future.wait([
      fetchUsers(),
      fetchCustomers(),
      fetchProducts(),
      fetchOrders(),
    ]);
    _isLoading = false;
    notifyListeners();
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
        final userData = jsonDecode(response.body);
        _currentUser = User.fromJson(userData);
        
        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_session', jsonEncode(userData));
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

  // --- Fetching Data ---

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/orders')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _orders = data.map((json) => Order.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _products = data.map((json) => Product.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
  }

  Future<void> fetchCustomers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/customers')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _customers = data.map((json) => Customer.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching customers: $e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _users = data.map((json) => User.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  // --- Operations & Workflow ---

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': effectiveStatus}),
      );

      if (response.statusCode == 200) {
        await fetchOrders(); // Refresh local list
        return true;
      }
    } catch (e) {
      // Local fallback for demo
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final old = _orders[index];
        _orders[index] = Order(
          id: old.id, customerId: old.customerId, customerName: old.customerName,
          status: effectiveStatus, total: old.total, createdAt: old.createdAt,
          items: old.items, salespersonId: old.salespersonId,
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> createOrder(String customerId, String customerName, List<Map<String, dynamic>> items) async {
    double total = 0;
    for (var item in items) {
      total += (item['price'] as num) * (item['quantity'] as num);
    }

    final orderData = {
      'customerId': customerId,
      'customerName': customerName,
      'status': 'Pending Credit Approval',
      'total': total,
      'items': items,
      'salespersonId': _currentUser?.id,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        await fetchOrders();
        return true;
      }
    } catch (e) {
      // Local fallback
      final newOrder = Order(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        customerId: customerId,
        customerName: customerName,
        status: 'Pending Credit Approval',
        total: total,
        createdAt: DateTime.now(),
        items: items.map((i) => OrderItem(
          skuCode: i['skuCode'] ?? '',
          name: i['productName'] ?? '',
          quantity: i['quantity'] ?? 0,
          price: (i['price'] as num).toDouble(),
        )).toList(),
        salespersonId: _currentUser?.id,
      );
      _orders.insert(0, newOrder);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> createSTN(Map<String, dynamic> stnData) async {
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        await fetchOrders();
        return true;
      }
    } catch (e) {
      // Local fallback
      final newSTN = Order(
        id: 'STN-${DateTime.now().millisecondsSinceEpoch}',
        customerId: stnData['destinationWarehouse'] ?? 'WH-O',
        customerName: stnData['destinationWarehouse'] ?? 'Warehouse',
        status: 'In Transit',
        total: 0,
        createdAt: DateTime.now(),
        items: (stnData['items'] as List).map((i) => OrderItem(
          skuCode: i['skuCode'] ?? '',
          name: i['productName'] ?? '',
          quantity: i['quantity'] ?? 0,
          price: 0,
        )).toList(),
        isSTN: true,
        sourceWarehouse: stnData['sourceWarehouse'],
        destinationWarehouse: stnData['destinationWarehouse'],
        remarks: stnData['remarks'],
      );
      _orders.insert(0, newSTN);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> createCustomer(Map<String, dynamic> customerData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(customerData),
      );

      if (response.statusCode == 201) {
        await fetchCustomers();
        return true;
      }
    } catch (e) {
      final newCustomer = Customer.fromJson({
        ...customerData,
        'id': customerData['id'] ?? 'CUST-${_customers.length + 1}',
      });
      _customers.insert(0, newCustomer);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201) {
        await fetchProducts();
        return true;
      }
    } catch (e) {
      debugPrint('Error creating product: $e');
    }
    return false;
  }

  // --- Analytics ---

  Future<Map<String, dynamic>?> fetchSalesHubData({String period = 'month'}) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/analytics/sales-hub?period=$period'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching sales hub data: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchReportData({required String type, String? startDate, String? endDate}) async {
    try {
      final queryParams = 'type=$type${startDate != null ? "&startDate=$startDate" : ""}${endDate != null ? "&endDate=$endDate" : ""}';
      final response = await http.get(Uri.parse('$_baseUrl/analytics/reports?$queryParams'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching report data: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchPMSData({String? userId, String period = 'month'}) async {
    try {
      final queryParams = 'period=$period' + (userId != null && userId.isNotEmpty ? '&userId=$userId' : '');
      final response = await http.get(Uri.parse('$_baseUrl/analytics/pms?$queryParams'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching PMS data: $e');
    }
    return {};
  }

  Future<void> downloadReport({required String type, required String format}) async {
    final queryParams = 'type=${type.toLowerCase().replaceAll(' ', '_')}&format=${format.toLowerCase()}';
    final url = '$_baseUrl/analytics/export?$queryParams';
    
    await DownloaderService().downloadFile(
      url: url,
      fileName: "${type.replaceAll(' ', '_')}_Report.${format.toLowerCase()}",
    );
  }


  Future<List<dynamic>> fetchProcurementData() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/procurement'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching procurement data: $e');
    }
    return [];
  }

  Future<bool> createProcurementEntry(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/procurement'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating procurement entry: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchCategorySplitData() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/analytics/category-split'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching category split data: $e');
    }
    return {};
  }

  Future<Map<String, dynamic>> fetchFleetIntelligenceData() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/analytics/fleet'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching fleet data: $e');
    }
    return {};
  }
}

