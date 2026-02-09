// import 'dart:convert';

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
  final String? password;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'Sales'),
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.label,
      if (password != null) 'password': password,
    };
  }
}

class Product {
  final String id;
  final String skuCode;
  final String name;
  final double price;
  final int stock;

  Product({
    required this.id,
    required this.skuCode,
    required this.name,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? json['skuCode'] ?? '',
      skuCode: json['skuCode'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skuCode': skuCode,
      'name': name,
      'price': price,
      'stock': stock,
    };
  }
}

class OrderItem {
  final String skuCode;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.skuCode,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      skuCode: json['skuCode'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skuCode': skuCode,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderItem> items;
  final String? salespersonId;
  final String? deliveryAddress;
  final bool? isSTN;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
    this.salespersonId,
    this.deliveryAddress,
    this.isSTN,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List? ?? [])
        .map((item) => OrderItem.fromJson(item))
        .toList();
    
    final calculatedTotal = itemsList.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Order(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      status: json['status'] ?? 'Pending',
      total: json['total']?.toDouble() ?? calculatedTotal,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      items: itemsList,
      salespersonId: json['salespersonId'],
      deliveryAddress: json['deliveryAddress'] ?? json['customerAddress'] ?? 'Address not provided',
      isSTN: json['isSTN'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'status': status,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      if (salespersonId != null) 'salespersonId': salespersonId,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (isSTN != null) 'isSTN': isSTN,
    };
  }
}

class Customer {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final String? gst;

  Customer({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    this.gst,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? json['location'] ?? 'Address not provided',
      phone: json['phone'],
      email: json['email'],
      gst: json['gst'] ?? json['gstNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (gst != null) 'gst': gst,
    };
  }
}
