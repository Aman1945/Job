import 'dart:convert';

enum UserRole {
  admin('Admin'),
  sales('Sales'),
  finance('Credit Control'),
  approver('Approving Authority'),
  logistics('Logistics Team'),
  billing('Billing Team'),
  warehouse('Warehouse/Packing'),
  delivery('Delivery Team'),
  procurement('Procurement Team'),
  procurementHead('Procurement Head');

  final String label;
  const UserRole(this.label);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere((e) => e.label == value, orElse: () => UserRole.sales);
  }
}

class User {
  final String id;
  final String name;
  final UserRole role;

  User({required this.id, required this.name, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      role: UserRole.fromString(json['role']),
    );
  }
}

class Product {
  final String id;
  final String skuCode;
  final String name;
  final double price;
  final int stock;

  Product({required this.id, required this.skuCode, required this.name, required this.price, required this.stock});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      skuCode: json['skuCode'],
      name: json['name'],
      price: json['price'].toDouble(),
      stock: json['stock'],
    );
  }
}

class Order {
  final String id;
  final String customerName;
  final String status;
  final double total;
  final DateTime createdAt;

  Order({required this.id, required this.customerName, required this.status, required this.total, required this.createdAt});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customerName'],
      status: json['status'],
      total: (json['items'] as List).fold(0, (sum, item) => sum + (item['price'] * item['quantity'])),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Customer {
  final String id;
  final String name;

  Customer({required this.id, required this.name});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

