// import 'dart:convert';

enum UserRole {
  admin('Admin'),
  sales('Sales'),
  rsm('RSM'),
  asm('ASM'),
  salesExecutive('Sales Executive'),
  creditControl('Credit Control'),
  whManager('WH Manager'),
  whHouse('WH House'),
  warehouse('Warehouse'),
  qcHead('QC Head'),
  logisticsLead('Logistics Lead'),
  logisticsTeam('Logistics Team'),
  billing('Billing'),
  atlExecutive('ATL Executive'),
  hubLead('Hub Lead'),
  deliveryTeam('Delivery Team'),
  procurement('Procurement'),
  procurementHead('Procurement Head');

  final String label;
  const UserRole(this.label);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere((e) => e.label == value, orElse: () => UserRole.sales);
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
  final Map<String, dynamic> agingData;
  final int exposureDays;
  final String? salesManager;
  final String? employeeResponsible;
  final String? distributionChannel;
  final String? customerClass;
  final String? location;
  final String securityChq;
  final double diffYesterdayToday;
  final double odAmt;
  final List<CustomerAddress>? addresses;
  final String? fssaiLicenseNo;
  final String? panCard;
  final String? postalCode;
  final String? customerEmail;
  final String? gstPhotoUrl;
  final String? panPhotoUrl;
  final String? chequePhotoUrl;

  Customer({
    required this.id,
    required this.name,
    required this.address,
    this.city = '',
    this.status = 'Active',
    this.phone,
    this.email,
    this.gst,
    this.limit = 1500000,
    this.osBalance = 0,
    this.overdue = 0,
    this.agingData = const {},
    this.exposureDays = 15,
    this.salesManager,
    this.employeeResponsible,
    this.distributionChannel,
    this.customerClass,
    this.location,
    this.securityChq = '-',
    this.diffYesterdayToday = 0,
    this.odAmt = 0,
    this.addresses,
    this.fssaiLicenseNo,
    this.panCard,
    this.postalCode,
    this.customerEmail,
    this.gstPhotoUrl,
    this.panPhotoUrl,
    this.chequePhotoUrl,
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
      gst: json['gst'] ?? json['gstNo'] ?? json['gstNumber'],
      limit: (json['limit'] ?? json['creditLimit'] ?? 1500000).toDouble(),
      osBalance: (json['osBalance'] ?? json['outstanding'] ?? 0).toDouble(),
      overdue: (json['overdue'] ?? 0).toDouble(),
      agingData: json['agingData'] ?? json['agingBuckets'] ?? {},
      exposureDays: json['exposureDays'] ?? 15,
      salesManager: json['salesManager'],
      employeeResponsible: json['employeeResponsible'] ?? json['employeeRespons'] ?? json['employeeRespons.'],
      distributionChannel: json['distributionChannel'] ?? json['distChannel'] ?? json['Dist Channel'],
      customerClass: json['customerClass'] ?? json['class'] ?? json['Class'],
      location: json['location'] ?? json['dist'] ?? json['Dist'],
      securityChq: json['securityChq'] ?? json['securityChqStatus'] ?? json['Security Chq'] ?? '-',
      diffYesterdayToday: (json['diffYesterdayToday'] ?? json['diffnBtwYdyTday'] ?? json['Diffn btw ydy & tday'] ?? 0).toDouble(),
      odAmt: (json['odAmt'] ?? json['overdue'] ?? json['OD Amt'] ?? 0).toDouble(),
      addresses: json['addresses'] != null
          ? (json['addresses'] as List).map((a) => CustomerAddress.fromJson(a)).toList()
          : null,
      fssaiLicenseNo: json['fssaiLicenseNo'] ?? json['fssai'],
      panCard: json['panCard'] ?? json['pan'],
      postalCode: json['postalCode'] ?? json['postal'] ?? json['zipCode'],
      customerEmail: json['customerEmail'] ?? json['customerEmailId'] ?? json['email'],
      gstPhotoUrl: json['gstPhotoUrl'],
      panPhotoUrl: json['panPhotoUrl'],
      chequePhotoUrl: json['chequePhotoUrl'],
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
      'agingData': agingData,
      if (exposureDays != null) 'exposureDays': exposureDays,
      if (salesManager != null) 'salesManager': salesManager,
      if (employeeResponsible != null) 'employeeResponsible': employeeResponsible,
      if (distributionChannel != null) 'distributionChannel': distributionChannel,
      if (customerClass != null) 'customerClass': customerClass,
      if (location != null) 'location': location,
      'securityChq': securityChq,
      'diffYesterdayToday': diffYesterdayToday,
      'odAmt': odAmt,
      if (addresses != null) 'addresses': addresses?.map((a) => a.toJson()).toList(),
      if (fssaiLicenseNo != null) 'fssaiLicenseNo': fssaiLicenseNo,
      if (panCard != null) 'panCard': panCard,
      if (postalCode != null) 'postalCode': postalCode,
      if (customerEmail != null) 'customerEmail': customerEmail,
      if (gstPhotoUrl != null) 'gstPhotoUrl': gstPhotoUrl,
      if (panPhotoUrl != null) 'panPhotoUrl': panPhotoUrl,
      if (chequePhotoUrl != null) 'chequePhotoUrl': chequePhotoUrl,
    };
  }
}

class User {
  final String id;
  final String name;
  final UserRole role;
  final String? password;
  final String location;
  final String? department1;
  final String? department2;
  final String? channel;
  final String? whatsappNumber;
  final String zone;
  final List<String> permissions;
  final Map<String, String> stepAccess; // 3-level: 'full', 'view', 'no'
  final String? managerId; // RSM/ASM hierarchy: ID of the manager this user reports to
  final List<String> orgPositions; // Org map slot keys e.g. ['rsm_north_retail', 'asm_south_horeca']

  User({
    required this.id,
    required this.name,
    required this.role,
    this.password,
    this.location = 'Pan India',
    this.zone = 'PAN INDIA',
    this.department1,
    this.department2,
    this.channel,
    this.whatsappNumber,
    this.permissions = const [],
    this.stepAccess = const {},
    this.managerId,
    this.orgPositions = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'Sales'),
      password: json['password'],
      location: json['location'] ?? 'Pan India',
      zone: json['zone'] ?? 'PAN INDIA',
      department1: json['department1'],
      department2: json['department2'],
      channel: json['channel'],
      whatsappNumber: json['whatsappNumber'],
      permissions: json['permissions'] is List
          ? (json['permissions'] as List).map((e) => e.toString()).toList()
          : [],
      stepAccess: json['stepAccess'] is Map
          ? (json['stepAccess'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
          : {},
      managerId: json['managerId'],
      orgPositions: json['orgPositions'] is List 
          ? (json['orgPositions'] as List).map((e) => e.toString()).toList() 
          : (json['orgPosition'] != null ? [json['orgPosition'].toString()] : []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.label,
      'location': location,
      'zone': zone,
      if (department1 != null) 'department1': department1,
      if (department2 != null) 'department2': department2,
      if (channel != null) 'channel': channel,
      if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
      'permissions': permissions,
      'stepAccess': stepAccess,
      if (password != null) 'password': password,
      if (managerId != null) 'managerId': managerId,
      'orgPositions': orgPositions,
    };
  }
}

class Product {
  final String id;
  final String skuCode;
  final String name;
  final String? shortName;
  final double price;
  final int stock;
  final String category;
  final String? distributionChannel;
  final String? specie;
  final String? weightPacking;
  final String? productWeight;
  final String? productPacking;
  final double? mrp;
  final String? hsnCode;
  final double? gst;
  final String? countryOfOrigin;
  final int? shelfLifeDays;
  final String? remarks;
  final double? yc70;
  final double? processingCharges;

  Product({
    required this.id,
    required this.skuCode,
    required this.name,
    this.shortName,
    required this.price,
    required this.stock,
    required this.category,
    this.distributionChannel,
    this.specie,
    this.weightPacking,
    this.productWeight,
    this.productPacking,
    this.mrp,
    this.hsnCode,
    this.gst,
    this.countryOfOrigin,
    this.shelfLifeDays,
    this.remarks,
    this.yc70,
    this.processingCharges,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? json['skuCode'] ?? '',
      skuCode: json['skuCode'] ?? '',
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? json['productShortName'],
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: json['category'] ?? 'General',
      distributionChannel: json['distributionChannel'],
      specie: json['specie'],
      weightPacking: json['weightPacking'],
      productWeight: json['productWeight']?.toString(),
      productPacking: json['productPacking'],
      mrp: (json['mrp'] ?? 0).toDouble(),
      hsnCode: json['hsnCode']?.toString(),
      gst: (json['gst'] ?? 0).toDouble(),
      countryOfOrigin: json['countryOfOrigin'],
      shelfLifeDays: json['shelfLifeDays'] != null ? int.tryParse(json['shelfLifeDays'].toString()) : null,
      remarks: json['remarks'],
      yc70: json['yc70'] != null ? double.tryParse(json['yc70'].toString()) : null,
      processingCharges: json['processingCharges'] != null ? double.tryParse(json['processingCharges'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skuCode': skuCode,
      'name': name,
      if (shortName != null) 'shortName': shortName,
      'price': price,
      'stock': stock,
      'category': category,
      if (distributionChannel != null) 'distributionChannel': distributionChannel,
      if (specie != null) 'specie': specie,
      if (weightPacking != null) 'weightPacking': weightPacking,
      if (productWeight != null) 'productWeight': productWeight,
      if (productPacking != null) 'productPacking': productPacking,
      if (mrp != null) 'mrp': mrp,
      if (hsnCode != null) 'hsnCode': hsnCode,
      if (gst != null) 'gst': gst,
      if (countryOfOrigin != null) 'countryOfOrigin': countryOfOrigin,
      if (shelfLifeDays != null) 'shelfLifeDays': shelfLifeDays,
      if (remarks != null) 'remarks': remarks,
      if (yc70 != null) 'yc70': yc70,
      if (processingCharges != null) 'processingCharges': processingCharges,
    };
  }
}

// Distributor Price List model (maps to /api/distributor-prices)
class DistributorPrice {
  final String id;
  final String? distributorCode;
  final String? distributorName;
  final String code;
  final String name;
  final String? materialNumber;
  final String? inKg;
  final double mrp;
  final double gstPct;
  final double retailerMarginOnMrp;
  final double distMarginOnCost;
  final double distMarginOnMrp;
  final double billingRate;
  final String? category;
  final bool isActive;

  DistributorPrice({
    required this.id,
    this.distributorCode,
    this.distributorName,
    required this.code,
    required this.name,
    this.materialNumber,
    this.inKg,
    required this.mrp,
    required this.gstPct,
    required this.retailerMarginOnMrp,
    required this.distMarginOnCost,
    required this.distMarginOnMrp,
    required this.billingRate,
    this.category,
    this.isActive = true,
  });

  factory DistributorPrice.fromJson(Map<String, dynamic> json) {
    return DistributorPrice(
      id: json['id'] ?? json['code'] ?? '',
      distributorCode: json['distributorCode'],
      distributorName: json['distributorName'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      materialNumber: json['materialNumber'],
      inKg: json['inKg'],
      mrp: (json['mrp'] ?? 0).toDouble(),
      gstPct: (json['gstPct'] ?? 0).toDouble(),
      retailerMarginOnMrp: (json['retailerMarginOnMrp'] ?? 0).toDouble(),
      distMarginOnCost: (json['distMarginOnCost'] ?? 0).toDouble(),
      distMarginOnMrp: (json['distMarginOnMrp'] ?? 0).toDouble(),
      billingRate: (json['billingRate'] ?? 0).toDouble(),
      category: json['category'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (distributorCode != null) 'distributorCode': distributorCode,
    if (distributorName != null) 'distributorName': distributorName,
    'code': code,
    'name': name,
    if (materialNumber != null) 'materialNumber': materialNumber,
    if (inKg != null) 'inKg': inKg,
    'mrp': mrp,
    'gstPct': gstPct,
    'retailerMarginOnMrp': retailerMarginOnMrp,
    'distMarginOnCost': distMarginOnCost,
    'distMarginOnMrp': distMarginOnMrp,
    'billingRate': billingRate,
    if (category != null) 'category': category,
    'isActive': isActive,
  };
}

class OrderItem {
  final String skuCode;
  final String name;
  final int quantity;
  final double price;
  final String? unit;
  final String? batchNo;
  final DateTime? expiryDate;
  final DateTime? mfgDate;
  final String? binLocation;

  OrderItem({
    required this.skuCode,
    required this.name,
    required this.quantity,
    required this.price,
    this.unit,
    this.batchNo,
    this.expiryDate,
    this.mfgDate,
    this.binLocation,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      skuCode: json['skuCode'] ?? '',
      name: json['name'] ?? json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'],
      batchNo: json['batchNo'],
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      mfgDate: json['mfgDate'] != null ? DateTime.parse(json['mfgDate']) : null,
      binLocation: json['binLocation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skuCode': skuCode,
      'name': name,
      'quantity': quantity,
      'price': price,
      if (unit != null) 'unit': unit,
      if (batchNo != null) 'batchNo': batchNo,
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
      if (mfgDate != null) 'mfgDate': mfgDate!.toIso8601String(),
      if (binLocation != null) 'binLocation': binLocation,
    };
  }
}

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String status;
  final double total;
  final double? subTotal;
  final double? gstAmount;
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
  final Map<String, double>? taxBreakdown;
  final double? discountAmount;
  final double? netWeight;
  final double? grossWeight;
  final List<String> salesPhotos;
  final String? qcPhoto;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.total,
    this.subTotal,
    this.gstAmount,
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
    this.taxBreakdown,
    this.discountAmount,
    this.netWeight,
    this.grossWeight,
    this.salesPhotos = const [],
    this.qcPhoto,
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
      total: json['total']?.toDouble() ?? (calculatedTotal * 1.18), // Default to 18% GST if total missing
      subTotal: json['subTotal']?.toDouble() ?? calculatedTotal,
      gstAmount: json['gstAmount']?.toDouble() ?? (calculatedTotal * 0.18),
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
      taxBreakdown: (json['taxBreakdown'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      netWeight: (json['netWeight'] as num?)?.toDouble(),
      grossWeight: (json['grossWeight'] as num?)?.toDouble(),
      salesPhotos: json['salesPhotos'] != null ? List<String>.from(json['salesPhotos']) : [],
      qcPhoto: json['qcPhoto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'status': status,
      'total': total,
      if (subTotal != null) 'subTotal': subTotal,
      if (gstAmount != null) 'gstAmount': gstAmount,
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
      if (taxBreakdown != null) 'taxBreakdown': taxBreakdown,
      if (discountAmount != null) 'discountAmount': discountAmount,
      if (netWeight != null) 'netWeight': netWeight,
      if (grossWeight != null) 'grossWeight': grossWeight,
      'salesPhotos': salesPhotos,
      if (qcPhoto != null) 'qcPhoto': qcPhoto,
    };
  }
}

class LogisticsData {
  final String? deliveryAgentId;
  final String? vehicleNo;
  final String? vehicleProvider;
  final double? distanceKm;
  final String? manifestId;
  final String? ewayBill;
  final String? sealNo;
  final DateTime? bookingDate;
  final DateTime? expectedDeliveryDate;
  final List<Map<String, dynamic>>? trackingHistory;

  LogisticsData({
    this.deliveryAgentId,
    this.vehicleNo,
    this.vehicleProvider,
    this.distanceKm,
    this.manifestId,
    this.ewayBill,
    this.sealNo,
    this.bookingDate,
    this.expectedDeliveryDate,
    this.trackingHistory,
  });

  factory LogisticsData.fromJson(Map<String, dynamic> json) {
    return LogisticsData(
      deliveryAgentId: json['deliveryAgentId'],
      vehicleNo: json['vehicleNo'],
      vehicleProvider: json['vehicleProvider'],
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      manifestId: json['manifestId'],
      ewayBill: json['ewayBill'],
      sealNo: json['sealNo'],
      bookingDate: json['bookingDate'] != null ? DateTime.parse(json['bookingDate']) : null,
      expectedDeliveryDate: json['expectedDeliveryDate'] != null ? DateTime.parse(json['expectedDeliveryDate']) : null,
      trackingHistory: (json['trackingHistory'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (deliveryAgentId != null) 'deliveryAgentId': deliveryAgentId,
      if (vehicleNo != null) 'vehicleNo': vehicleNo,
      if (vehicleProvider != null) 'vehicleProvider': vehicleProvider,
      if (distanceKm != null) 'distanceKm': distanceKm,
      if (manifestId != null) 'manifestId': manifestId,
      if (ewayBill != null) 'ewayBill': ewayBill,
      if (sealNo != null) 'sealNo': sealNo,
      if (bookingDate != null) 'bookingDate': bookingDate!.toIso8601String(),
      if (expectedDeliveryDate != null) 'expectedDeliveryDate': expectedDeliveryDate!.toIso8601String(),
      if (trackingHistory != null) 'trackingHistory': trackingHistory,
    };
  }
}


// Customer Address Model
class CustomerAddress {
  final String id;
  final String label; // e.g., "Main Office", "Warehouse 1"
  final String street;
  final String city;
  final String state;
  final String pincode;
  final String type; // "Billing" or "Delivery"
  final bool isDefault;

  CustomerAddress({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    this.type = 'Delivery',
    this.isDefault = false,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      type: json['type'] ?? 'Delivery',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'type': type,
      'isDefault': isDefault,
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
