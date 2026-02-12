import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class BulkOrderScreen extends StatefulWidget {
  const BulkOrderScreen({Key? key}) : super(key: key);

  @override
  State<BulkOrderScreen> createState() => _BulkOrderScreenState();
}

class _BulkOrderScreenState extends State<BulkOrderScreen> {
  static const String serverAddress = 'nexus-oms-backend.onrender.com';
  final String _baseUrl = 'https://$serverAddress/api';

  bool _isLoading = false;
  List<Map<String, dynamic>> _previewOrders = [];
  String? _selectedFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Order Upload'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step 1: Download Template
                  _buildStepCard(
                    step: '1',
                    title: 'Download Template',
                    child: ElevatedButton.icon(
                      onPressed: _downloadTemplate,
                      icon: const Icon(Icons.download),
                      label: const Text('Download Excel Template'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Step 2: Pick File
                  _buildStepCard(
                    step: '2',
                    title: 'Select Excel File',
                    child: ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.file_upload),
                      label: Text(_selectedFilePath == null
                          ? 'Pick Excel File (.xlsx, .xls)'
                          : 'File Selected: ${_selectedFilePath!.split('/').last}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Step 3: Preview
                  if (_previewOrders.isNotEmpty) ...[
                    _buildStepCard(
                      step: '3',
                      title: 'Preview Orders (First 5)',
                      child: _buildPreviewTable(),
                    ),
                    const SizedBox(height: 16),

                    // Step 4: Upload
                    ElevatedButton.icon(
                      onPressed: _uploadOrders,
                      icon: const Icon(Icons.cloud_upload),
                      label: Text('Upload ${_previewOrders.length} Orders'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.all(20),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Text(step, style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTable() {
    final preview = _previewOrders.take(5).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Customer ID')),
          DataColumn(label: Text('Customer Name')),
          DataColumn(label: Text('SKU Code')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Price')),
        ],
        rows: preview.map((order) {
          final item = order['items'][0]; // First item
          return DataRow(cells: [
            DataCell(Text(order['customerId'] ?? '')),
            DataCell(Text(order['customerName'] ?? '')),
            DataCell(Text(item['skuCode'] ?? '')),
            DataCell(Text(item['quantity'].toString())),
            DataCell(Text('₹${item['price']}')),
          ]);
        }).toList(),
      ),
    );
  }

  Future<void> _downloadTemplate() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/bulk/template'),
        headers: authProvider.authHeaders,
      );

      if (response.statusCode == 200) {
        // Save file (simplified - in production use path_provider)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Template downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to download template');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _isLoading = true;
        });

        await _parseExcel(result.files.single.path!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error picking file: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _parseExcel(String filePath) async {
    try {
      final bytes = File(filePath).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) throw Exception('No sheet found');

      final orders = <Map<String, dynamic>>[];

      // Skip header row (row 0)
      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty || row[0]?.value == null) continue;

        orders.add({
          'customerId': row[0]?.value.toString() ?? '',
          'customerName': row[1]?.value.toString() ?? '',
          'items': [
            {
              'skuCode': row[2]?.value.toString() ?? '',
              'productName': row[3]?.value.toString() ?? '',
              'quantity': int.tryParse(row[4]?.value.toString() ?? '0') ?? 0,
              'price': double.tryParse(row[5]?.value.toString() ?? '0') ?? 0.0,
            }
          ],
        });
      }

      setState(() {
        _previewOrders = orders;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Parsed ${orders.length} orders'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error parsing Excel: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _uploadOrders() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.post(
        Uri.parse('$_baseUrl/orders/bulk'),
        headers: authProvider.authHeaders,
        body: jsonEncode({'orders': _previewOrders}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${data['created']} orders created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear preview
        setState(() {
          _previewOrders = [];
          _selectedFilePath = null;
        });
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Upload error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
