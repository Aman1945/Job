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
  final String category;

  Product({
    required this.id,
    required this.skuCode,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? json['skuCode'] ?? '',
      skuCode: json['skuCode'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skuCode': skuCode,
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
    };
  }
}

class OrderItem {
  final String skuCode;
  final String name;
  final int quantity;
  final double price;
  final String? unit;

  OrderItem({
    required this.skuCode,
    required this.name,
    required this.quantity,
    required this.price,
    this.unit,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      skuCode: json['skuCode'] ?? '',
      name: json['name'] ?? json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skuCode': skuCode,
      'name': name,
      'quantity': quantity,
      'price': price,
      if (unit != null) 'unit': unit,
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
  final LogisticsData? logistics;

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
    this.logistics,
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
      logistics: json['logistics'] != null ? LogisticsData.fromJson(json['logistics']) : null,
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
      if (logistics != null) 'logistics': logistics!.toJson(),
    };
  }
}

class LogisticsData {
  final String? deliveryAgentId;
  final String? vehicleNo;
  final String? vehicleProvider;
  final double? distanceKm;

  LogisticsData({
    this.deliveryAgentId,
    this.vehicleNo,
    this.vehicleProvider,
    this.distanceKm,
  });

  factory LogisticsData.fromJson(Map<String, dynamic> json) {
    return LogisticsData(
      deliveryAgentId: json['deliveryAgentId'],
      vehicleNo: json['vehicleNo'],
      vehicleProvider: json['vehicleProvider'],
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (deliveryAgentId != null) 'deliveryAgentId': deliveryAgentId,
      if (vehicleNo != null) 'vehicleNo': vehicleNo,
      if (vehicleProvider != null) 'vehicleProvider': vehicleProvider,
      if (distanceKm != null) 'distanceKm': distanceKm,
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
class ProcurementItem {
  final String id;
  final String supplierName;
  final String skuName;
  final String skuCode;
  bool sipChecked;
  bool labelsChecked;
  bool docsChecked;
  String status;
  final DateTime createdAt;
  String? attachment;
  String? attachmentName;
  String? clearedBy;
  String? approvedBy;

  ProcurementItem({
    required this.id,
    required this.supplierName,
    required this.skuName,
    required this.skuCode,
    this.sipChecked = false,
    this.labelsChecked = false,
    this.docsChecked = false,
    this.status = 'Pending',
    required this.createdAt,
    this.attachment,
    this.attachmentName,
    this.clearedBy,
    this.approvedBy,
  });

  factory ProcurementItem.fromJson(Map<String, dynamic> json) {
    // Smart mapping for legacy data keys
    final String id = json['id'] ?? json['ref'] ?? '';
    final String supplier = json['supplierName'] ?? json['vendor'] ?? '';
    final String sku = json['skuName'] ?? json['sku'] ?? '';
    final String code = json['skuCode'] ?? json['code'] ?? '';
    
    // Legacy status mapping
    String currentStatus = json['status'] ?? json['stage'] ?? 'Pending';
    if (currentStatus == 'PENDING') currentStatus = 'Pending';
    
    // Legacy checks mapping (if checks was an array)
    bool sip = json['sipChecked'] ?? false;
    bool lbl = json['labelsChecked'] ?? false;
    bool doc = json['docsChecked'] ?? false;
    
    if (json['checks'] is List && (json['checks'] as List).length >= 3) {
      final List checks = json['checks'];
      sip = checks[0] ?? false;
      lbl = checks[1] ?? false;
      doc = checks[2] ?? false;
    }

    return ProcurementItem(
      id: id,
      supplierName: supplier,
      skuName: sku,
      skuCode: code,
      sipChecked: sip,
      labelsChecked: lbl,
      docsChecked: doc,
      status: currentStatus,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : (json['date'] != null ? DateTime.now() : DateTime.now()), // Fallback for date string if needed
      attachment: json['attachment'],
      attachmentName: json['attachmentName'],
      clearedBy: json['clearedBy'],
      approvedBy: json['approvedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierName': supplierName,
      'skuName': skuName,
      'skuCode': skuCode,
      'sipChecked': sipChecked,
      'labelsChecked': labelsChecked,
      'docsChecked': docsChecked,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (attachment != null) 'attachment': attachment,
      if (attachmentName != null) 'attachmentName': attachmentName,
      if (clearedBy != null) 'clearedBy': clearedBy,
      if (approvedBy != null) 'approvedBy': approvedBy,
    };
  }
}
