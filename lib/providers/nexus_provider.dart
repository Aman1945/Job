import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class NexusProvider with ChangeNotifier {
  final String baseUrl = 'https://nexus-oms-backend.onrender.com/api';
  
  User? _currentUser;
  List<Order> _orders = [];
  List<Product> _products = [];
  List<Customer> _customers = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  List<Order> get orders => _orders;
  List<Product> get products => _products;
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      print('Login Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _orders = data.map((o) => Order.fromJson(o)).toList();
      }
    } catch (e) {
      print('Fetch Orders Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _products = data.map((p) => Product.fromJson(p)).toList();
      }
    } catch (e) {
      print('Fetch Products Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/customers'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _customers = data.map((c) => Customer.fromJson(c)).toList();
      }
    } catch (e) {
      print('Fetch Customers Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createOrder(String customerId, String customerName, List<Map<String, dynamic>> items) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customerId': customerId,
          'customerName': customerName,
          'items': items,
          'salespersonId': _currentUser?.id,
          'status': 'Pending',
          'isSTN': false,
        }),
      );
      if (response.statusCode == 201) {
        await fetchOrders();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Create Order Error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> createSTN(String fromWH, String toWH, List<Map<String, dynamic>> items) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customerId': 'INTERNAL-TRANSFER',
          'customerName': 'STN: $fromWH -> $toWH',
          'fromWarehouse': fromWH,
          'toWarehouse': toWH,
          'items': items,
          'salespersonId': _currentUser?.id,
          'status': 'In Transit',
          'isSTN': true,
        }),
      );
      if (response.statusCode == 201) {
        await fetchOrders();
        return true;
      }
    } catch (e) {
      print('STN Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> createCustomer(String name, String type) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'type': type}),
      );
      if (response.statusCode == 201) {
        await fetchCustomers();
        return true;
      }
    } catch (e) {
      print('Create Customer Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );
      if (response.statusCode == 200) {
        await fetchOrders();
      }
    } catch (e) {
      print('Update Order Error: $e');
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
