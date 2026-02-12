# 🎯 FLUTTER INTEGRATION GUIDE - REMAINING WORK
**Date**: 2026-02-12  
**Estimated Time**: 4-6 hours  
**Priority**: HIGH

---

## 📋 OVERVIEW

Backend me **18 new API endpoints** add hue hain. Ab Flutter app me inhe integrate karna hai.

---

## ✅ TASK 1: UPDATE AUTH PROVIDER (1 HOUR)

### File: `flutter/lib/providers/auth_provider.dart`

### Changes Required:

#### 1.1 Store JWT Token
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();
  String? _jwtToken;
  
  // Login method update
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['success']) {
        _jwtToken = data['token'];
        await _storage.write(key: 'jwt_token', value: _jwtToken);
        
        // Store user data
        _currentUser = User.fromJson(data['user']);
        await _storage.write(key: 'user_data', value: jsonEncode(data['user']));
        
        notifyListeners();
        return true;
      }
    }
    return false;
  }
  
  // Auto-login on app start
  Future<void> tryAutoLogin() async {
    _jwtToken = await _storage.read(key: 'jwt_token');
    final userData = await _storage.read(key: 'user_data');
    
    if (_jwtToken != null && userData != null) {
      _currentUser = User.fromJson(jsonDecode(userData));
      notifyListeners();
    }
  }
  
  // Logout
  Future<void> logout() async {
    _jwtToken = null;
    _currentUser = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_data');
    notifyListeners();
  }
  
  // Get headers with JWT token
  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_jwtToken',
  };
}
```

#### 1.2 Handle Token Expiry
```dart
// Add to all API calls
Future<dynamic> _makeAuthenticatedRequest(String url, {String method = 'GET', Map<String, dynamic>? body}) async {
  final response = await http.post(
    Uri.parse(url),
    headers: authHeaders,
    body: body != null ? jsonEncode(body) : null,
  );
  
  // Handle 401 Unauthorized (token expired)
  if (response.statusCode == 401) {
    await logout();
    // Navigate to login screen
    return null;
  }
  
  return jsonDecode(response.body);
}
```

---

## ✅ TASK 2: BULK ORDER UPLOAD (2 HOURS)

### Files to Create/Modify:

#### 2.1 Create Bulk Order Screen
**File**: `flutter/lib/screens/bulk_order_screen.dart`

```dart
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:convert';
import 'dart:io';

class BulkOrderScreen extends StatefulWidget {
  @override
  _BulkOrderScreenState createState() => _BulkOrderScreenState();
}

class _BulkOrderScreenState extends State<BulkOrderScreen> {
  List<Map<String, dynamic>> _parsedOrders = [];
  List<Map<String, dynamic>> _validationErrors = [];
  bool _isLoading = false;
  
  // Download template
  Future<void> _downloadTemplate() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/bulk/template'),
        headers: authProvider.authHeaders,
      );
      
      if (response.statusCode == 200) {
        // Save file to Downloads
        final directory = await getDownloadsDirectory();
        final file = File('${directory.path}/NexusOMS_BulkOrder_Template.xlsx');
        await file.writeAsBytes(response.bodyBytes);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Template downloaded to Downloads folder')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading template: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Pick and parse Excel file
  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    
    if (result != null) {
      File file = File(result.files.single.path!);
      await _parseExcelFile(file);
    }
  }
  
  // Parse Excel file
  Future<void> _parseExcelFile(File file) async {
    setState(() => _isLoading = true);
    
    try {
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      
      _parsedOrders.clear();
      _validationErrors.clear();
      
      var sheet = excel['Bulk Orders'];
      
      // Skip header row, start from row 2
      for (var row in sheet.rows.skip(1)) {
        if (row[0]?.value == null) continue; // Skip empty rows
        
        _parsedOrders.add({
          'customerId': row[0]?.value.toString() ?? '',
          'skuCode': row[1]?.value.toString() ?? '',
          'quantity': int.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
          'appliedRate': double.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
          'remarks': row[4]?.value.toString() ?? '',
        });
      }
      
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error parsing Excel: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Upload bulk orders
  Future<void> _uploadBulkOrders() async {
    setState(() => _isLoading = true);
    
    try {
      // Convert Excel to base64
      final file = File(_selectedFilePath);
      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/bulk'),
        headers: authProvider.authHeaders,
        body: jsonEncode({'excelData': base64Data}),
      );
      
      final data = jsonDecode(response.body);
      
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${data['message']}')),
        );
        Navigator.pop(context);
      } else {
        // Show validation errors
        setState(() {
          _validationErrors = List<Map<String, dynamic>>.from(data['errors'] ?? []);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bulk Order Upload')),
      body: Column(
        children: [
          // Download template button
          ElevatedButton.icon(
            icon: Icon(Icons.download),
            label: Text('Download Template'),
            onPressed: _downloadTemplate,
          ),
          
          // Pick file button
          ElevatedButton.icon(
            icon: Icon(Icons.file_upload),
            label: Text('Select Excel File'),
            onPressed: _pickExcelFile,
          ),
          
          // Preview table
          if (_parsedOrders.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Customer ID')),
                    DataColumn(label: Text('SKU Code')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Rate')),
                  ],
                  rows: _parsedOrders.take(5).map((order) {
                    return DataRow(cells: [
                      DataCell(Text(order['customerId'])),
                      DataCell(Text(order['skuCode'])),
                      DataCell(Text(order['quantity'].toString())),
                      DataCell(Text(order['appliedRate'].toString())),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          
          // Validation errors
          if (_validationErrors.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _validationErrors.length,
                itemBuilder: (context, index) {
                  final error = _validationErrors[index];
                  return ListTile(
                    leading: Icon(Icons.error, color: Colors.red),
                    title: Text('Row ${error['row']}: ${error['message']}'),
                    subtitle: Text(error['field']),
                  );
                },
              ),
            ),
          
          // Upload button
          if (_parsedOrders.isNotEmpty && _validationErrors.isEmpty)
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadBulkOrders,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Upload ${_parsedOrders.length} Orders'),
            ),
        ],
      ),
    );
  }
}
```

#### 2.2 Add Dependencies
**File**: `flutter/pubspec.yaml`

```yaml
dependencies:
  file_picker: ^8.1.4
  excel: ^4.0.6
  path_provider: ^2.1.5
```

---

## ✅ TASK 3: WEBSOCKET INTEGRATION (1.5 HOURS)

### Files to Create/Modify:

#### 3.1 Create Socket Service
**File**: `flutter/lib/services/socket_service.dart`

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();
  
  IO.Socket? socket;
  Function(Map<String, dynamic>)? onOrderCreated;
  Function(Map<String, dynamic>)? onOrderUpdated;
  Function(Map<String, dynamic>)? onStatusChanged;
  
  void connect(String token) {
    socket = IO.io('https://nexus-oms-backend.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {'token': token},
    });
    
    socket!.on('connected', (data) {
      print('✅ WebSocket connected: ${data['message']}');
    });
    
    socket!.on('order:created', (data) {
      print('📢 New order created: ${data['orderId']}');
      if (onOrderCreated != null) {
        onOrderCreated!(data);
      }
    });
    
    socket!.on('order:updated', (data) {
      print('📢 Order updated: ${data['orderId']}');
      if (onOrderUpdated != null) {
        onOrderUpdated!(data);
      }
    });
    
    socket!.on('order:status-changed', (data) {
      print('📢 Status changed: ${data['orderId']} → ${data['newStatus']}');
      if (onStatusChanged != null) {
        onStatusChanged!(data);
      }
    });
    
    socket!.on('disconnect', (_) {
      print('🔌 WebSocket disconnected');
    });
    
    socket!.on('error', (error) {
      print('❌ WebSocket error: $error');
    });
  }
  
  void disconnect() {
    socket?.disconnect();
    socket = null;
  }
  
  void emit(String event, dynamic data) {
    socket?.emit(event, data);
  }
}
```

#### 3.2 Update NexusProvider
**File**: `flutter/lib/providers/nexus_provider.dart`

```dart
class NexusProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();
  
  // Initialize WebSocket after login
  void initializeWebSocket(String token) {
    _socketService.connect(token);
    
    _socketService.onOrderCreated = (data) {
      // Add new order to list
      final newOrder = Order.fromJson(data);
      _orders.insert(0, newOrder);
      notifyListeners();
      
      // Show snackbar
      _showNotification('New Order: ${data['orderId']}');
    };
    
    _socketService.onOrderUpdated = (data) {
      // Update order in list
      final index = _orders.indexWhere((o) => o.id == data['orderId']);
      if (index != -1) {
        _orders[index] = Order.fromJson(data);
        notifyListeners();
      }
    };
    
    _socketService.onStatusChanged = (data) {
      // Update order status
      final index = _orders.indexWhere((o) => o.id == data['orderId']);
      if (index != -1) {
        _orders[index].status = data['newStatus'];
        notifyListeners();
      }
      
      _showNotification('Order ${data['orderId']}: ${data['oldStatus']} → ${data['newStatus']}');
    };
  }
  
  void _showNotification(String message) {
    // Show snackbar or local notification
  }
  
  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
```

#### 3.3 Add Dependency
**File**: `flutter/pubspec.yaml`

```yaml
dependencies:
  socket_io_client: ^3.0.2
```

---

## ✅ TASK 4: AI CREDIT INSIGHTS (1 HOUR)

### Files to Modify:

#### 4.1 Update NexusProvider
**File**: `flutter/lib/providers/nexus_provider.dart`

```dart
class NexusProvider with ChangeNotifier {
  String? _creditInsight;
  bool _isLoadingInsight = false;
  
  String? get creditInsight => _creditInsight;
  bool get isLoadingInsight => _isLoadingInsight;
  
  Future<void> fetchCreditInsight(String orderId, String customerId) async {
    _isLoadingInsight = true;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/ai/credit-insight'),
        headers: authProvider.authHeaders,
        body: jsonEncode({
          'orderId': orderId,
          'customerId': customerId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _creditInsight = data['insight'];
        }
      }
    } catch (e) {
      print('Error fetching AI insight: $e');
      _creditInsight = 'AI service unavailable. Please review manually.';
    } finally {
      _isLoadingInsight = false;
      notifyListeners();
    }
  }
}
```

#### 4.2 Update Order Details Screen
**File**: `flutter/lib/screens/order_details_screen.dart`

```dart
class OrderDetailsScreen extends StatefulWidget {
  final Order order;
  
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch AI insight on screen load
    if (widget.order.status == 'Pending Credit Approval') {
      Provider.of<NexusProvider>(context, listen: false)
          .fetchCreditInsight(widget.order.id, widget.order.customerId);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: ListView(
        children: [
          // ... existing order details ...
          
          // AI Credit Insight Card
          if (widget.order.status == 'Pending Credit Approval')
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('AI Credit Insight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    provider.isLoadingInsight
                        ? Center(child: CircularProgressIndicator())
                        : Text(provider.creditInsight ?? 'No insight available'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## ✅ TASK 5: PERFORMANCE MANAGEMENT SYSTEM (1 HOUR)

### Files to Create/Modify:

#### 5.1 Create PMS Screen
**File**: `flutter/lib/screens/pms_screen.dart`

```dart
class PMSScreen extends StatefulWidget {
  @override
  _PMSScreenState createState() => _PMSScreenState();
}

class _PMSScreenState extends State<PMSScreen> {
  Map<String, dynamic>? _performanceData;
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _fetchPerformanceData();
    _fetchLeaderboard();
  }
  
  Future<void> _fetchPerformanceData() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = authProvider.currentUser.id;
      final response = await http.get(
        Uri.parse('$baseUrl/api/pms/$userId?month=Feb\'26'),
        headers: authProvider.authHeaders,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _performanceData = data['data'];
          });
        }
      }
    } catch (e) {
      print('Error fetching PMS data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _fetchLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/pms/leaderboard?period=month'),
        headers: authProvider.authHeaders,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _leaderboard = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Performance Management')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Score Card
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Total Score', style: TextStyle(fontSize: 18)),
                          Text(
                            '${_performanceData?['totalScore']?.toStringAsFixed(2) ?? '0'}%',
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                          Text('Incentive: ₹${_performanceData?['incentiveAmount'] ?? 0}'),
                        ],
                      ),
                    ),
                  ),
                  
                  // KRAs
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('KRAs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ...(_performanceData?['kras'] ?? []).map<Widget>((kra) {
                            return ListTile(
                              title: Text(kra['name']),
                              subtitle: Text('${kra['achieved']}/${kra['target']}'),
                              trailing: Text('${kra['score']?.toStringAsFixed(1)}%'),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Leaderboard
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ..._leaderboard.take(5).map((entry) {
                            return ListTile(
                              leading: CircleAvatar(child: Text('#${entry['rank']}')),
                              title: Text(entry['userName']),
                              trailing: Text('${entry['totalScore']?.toStringAsFixed(1)}%'),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
```

---

## 📊 SUMMARY - FLUTTER REMAINING WORK

| Task | Estimated Time | Priority | Status |
|------|----------------|----------|--------|
| 1. Update Auth Provider | 1 hour | HIGH | ⏳ Pending |
| 2. Bulk Order Upload | 2 hours | HIGH | ⏳ Pending |
| 3. WebSocket Integration | 1.5 hours | HIGH | ⏳ Pending |
| 4. AI Credit Insights | 1 hour | MEDIUM | ⏳ Pending |
| 5. PMS Screen | 1 hour | MEDIUM | ⏳ Pending |
| **TOTAL** | **6.5 hours** | - | **0% Done** |

---

## 🎯 RECOMMENDED EXECUTION ORDER

1. **Auth Provider** (1 hour) - Foundation for all other tasks
2. **WebSocket** (1.5 hours) - Real-time updates
3. **Bulk Upload** (2 hours) - High-value feature
4. **AI Insights** (1 hour) - Quick win
5. **PMS Screen** (1 hour) - Nice to have

---

**Last Updated**: 2026-02-12 13:15 IST
