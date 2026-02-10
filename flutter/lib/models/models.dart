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
  final String? partnerType;
  final String? intelligenceInsight;
  final List<Map<String, dynamic>>? statusHistory;
  final String? sourceWarehouse;
  final String? destinationWarehouse;
  final String? remarks;

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
    this.partnerType,
    this.intelligenceInsight,
    this.statusHistory,
    this.sourceWarehouse,
    this.destinationWarehouse,
    this.remarks,
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
      partnerType: json['partnerType'] ?? 'Distributor',
      intelligenceInsight: json['intelligenceInsight'],
      statusHistory: (json['statusHistory'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
      sourceWarehouse: json['sourceWarehouse'],
      destinationWarehouse: json['destinationWarehouse'],
      remarks: json['remarks'],
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
      if (partnerType != null) 'partnerType': partnerType,
      if (intelligenceInsight != null) 'intelligenceInsight': intelligenceInsight,
      if (statusHistory != null) 'statusHistory': statusHistory,
      if (sourceWarehouse != null) 'sourceWarehouse': sourceWarehouse,
      if (destinationWarehouse != null) 'destinationWarehouse': destinationWarehouse,
      if (remarks != null) 'remarks': remarks,
    };
  }
}

class Customer {
  final String id;
  final String name;
  final String address;
  final String city;
  final String status;
  final String? phone;
  final String? email;
  final String? gst;
  final double limit;
  final double osBalance;
  final double overdue;
  final int exposureDays;
  final Map<String, dynamic>? agingData;

  Customer({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.status = 'Active',
    this.phone,
    this.email,
    this.gst,
    this.limit = 1500000,
    this.osBalance = 890000,
    this.overdue = 0,
    this.exposureDays = 15,
    this.agingData,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? json['location'] ?? 'Address not provided',
      city: json['city'] ?? (json['address'] != null ? json['address'].split(',').last.trim() : 'NA'),
      status: json['status'] ?? 'Active',
      phone: json['phone'],
      email: json['email'],
      gst: json['gst'] ?? json['gstNumber'],
      limit: (json['limit'] ?? 1500000).toDouble(),
      osBalance: (json['osBalance'] ?? 890000).toDouble(),
      overdue: (json['overdue'] ?? 0).toDouble(),
      exposureDays: json['exposureDays'] ?? 15,
      agingData: json['agingData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'status': status,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (gst != null) 'gst': gst,
      'limit': limit,
      'osBalance': osBalance,
      'overdue': overdue,
      'exposureDays': exposureDays,
      if (agingData != null) 'agingData': agingData,
    };
  }
}
