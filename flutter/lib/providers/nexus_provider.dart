import 'dart:convert';
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
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  List<Order> get orders => _orders;
  List<Customer> get customers => _customers;
  List<Product> get products => _products;
  List<User> get users => _users;
  List<ProcurementItem> get procurementItems => _procurementItems;
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

    // Check for saved user session (Legacy support - will eventually use AuthProvider)
    final prefs = await SharedPreferences.getInstance();
    final String? savedUser = prefs.getString('user_session');
    if (savedUser != null) {
      _currentUser = User.fromJson(jsonDecode(savedUser));
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
      debugPrint('🛰️ Fetching orders from: $_baseUrl/orders');
      final response = await http.get(Uri.parse('$_baseUrl/orders')).timeout(const Duration(seconds: 30));
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

  Future<void> fetchProducts() async {
    try {
      debugPrint('🛰️ Fetching products...');
      final response = await http.get(Uri.parse('$_baseUrl/products')).timeout(const Duration(seconds: 30));
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

  Future<void> fetchCustomers() async {
    try {
      debugPrint('🛰️ Fetching customers...');
      final response = await http.get(Uri.parse('$_baseUrl/customers')).timeout(const Duration(seconds: 30));
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

  Future<void> fetchUsers() async {
    try {
      debugPrint('🛰️ Fetching users...');
      final response = await http.get(Uri.parse('$_baseUrl/users')).timeout(const Duration(seconds: 30));
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
    double subTotal = 0;
    for (var item in items) {
      subTotal += (item['price'] as num) * (item['quantity'] as num);
    }
    double total = subTotal * 1.18; // Added 18% GST

    final orderData = {
      'customerId': customerId,
      'customerName': customerName,
      'status': 'Pending Credit Approval',
      'total': total,
      'subTotal': subTotal,
      'gstValue': subTotal * 0.18,
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
      return false;
    } catch (e) {
      debugPrint('Error creating customer: $e');
      // Local fallback
      final newCustomer = Customer.fromJson({
        ...customerData,
        'id': customerData['id'] ?? 'CUST-${_customers.length + 1}',
      });
      _customers.insert(0, newCustomer);
      notifyListeners();
      return true;
    }
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
      return false;
    } catch (e) {
      debugPrint('Error creating product: $e');
      // Local fallback for materiality
      final newProduct = Product.fromJson({
        ...productData,
        'id': productData['id'] ?? productData['skuCode'] ?? 'PROD-${DateTime.now().millisecondsSinceEpoch}',
      });
      _products.insert(0, newProduct);
      notifyListeners();
      return true;
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        await fetchUsers();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating user: $e');
      // Local fallback
      final newUser = User.fromJson({
        ...userData,
        'id': userData['id'] ?? 'USER-${_users.length + 1}',
        'role': userData['role'] ?? 'Sales',
      });
      _users.insert(0, newUser);
      notifyListeners();
      return true;
    }
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


  Future<void> fetchProcurementItems() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/procurement'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _procurementItems = data.map((json) => ProcurementItem.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching procurement: $e');
    }
  }

  Future<bool> createProcurementEntry(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/procurement'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        await fetchProcurementItems();
        return true;
      }
      return false;
    } catch (e) {
      // Local fallback
      final newItem = ProcurementItem(
        id: 'PRC-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
        supplierName: data['supplierName'] ?? data['vendor'] ?? '',
        skuCode: data['skuCode'] ?? data['code'] ?? '',
        skuName: data['skuName'] ?? data['sku'] ?? 'Unknown SKU',
        createdAt: DateTime.now(),
      );
      _procurementItems.insert(0, newItem);
      notifyListeners();
      return true;
    }
  }

  Future<bool> updateProcurementItem(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/procurement/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updates),
      );
      if (response.statusCode == 200) {
        await fetchProcurementItems();
        return true;
      }
      return false;
    } catch (e) {
      final index = _procurementItems.indexWhere((i) => i.id == id);
      if (index != -1) {
        final current = _procurementItems[index];
        final json = current.toJson();
        updates.forEach((key, value) => json[key] = value);
        _procurementItems[index] = ProcurementItem.fromJson(json);
        notifyListeners();
      }
      return true;
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

  Future<bool> assignLogistics(List<String> orderIds, Map<String, dynamic> logisticsData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/logistics/bulk-assign'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderIds': orderIds,
          'logisticsData': logisticsData,
        }),
      );

      if (response.statusCode == 200) {
        await fetchOrders();
        return true;
      }
    } catch (e) {
      // Local fallback
      for (var id in orderIds) {
        final index = _orders.indexWhere((o) => o.id == id);
        if (index != -1) {
          final old = _orders[index];
          _orders[index] = Order(
            id: old.id, customerId: old.customerId, customerName: old.customerName,
            status: 'In Transit', total: old.total, createdAt: old.createdAt,
            items: old.items, salespersonId: old.salespersonId,
            logistics: LogisticsData.fromJson(logisticsData),
          );
        }
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Calculate logistics cost
  Future<Map<String, dynamic>?> calculateLogisticsCost({
    required String origin,
    required String destination,
    required String vehicleType,
    double? distance,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/logistics/calculate-cost'),
        headers: {'Content-Type': 'application/json'},
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
      print('Cost calculation error: $e');
    }
    return null;
  }

  Future<bool> importCustomers(String filePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/customers/bulk-import'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await fetchCustomers();
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

  Future<bool> importProducts(String filePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/products/bulk-import'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        await fetchProducts();
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
}


