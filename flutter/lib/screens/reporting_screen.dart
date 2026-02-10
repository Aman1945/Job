import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  String _selectedReportType = 'Sales Report';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('REPORTING CENTER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showExportDialog(context),
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report Type Selector
                _buildReportTypeSelector(isMobile),
                const SizedBox(height: 20),
                
                // Date Range Selector
                _buildDateRangeSelector(isMobile),
                const SizedBox(height: 24),
                
                // Report Content
                _buildReportContent(provider, isMobile),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildReportTypeSelector(bool isMobile) {
    final reportTypes = [
      'Sales Report',
      'Inventory Report',
      'Customer Report',
      'Financial Report',
      'Performance Report',
    ];
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assessment, color: NexusTheme.emerald500, size: 24),
              const SizedBox(width: 12),
              const Text('REPORT TYPE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reportTypes.map((type) {
              final isSelected = _selectedReportType == type;
              return InkWell(
                onTap: () => setState(() => _selectedReportType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? NexusTheme.emerald500 : NexusTheme.slate100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? NexusTheme.emerald600 : NexusTheme.slate200,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.white : NexusTheme.slate700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDateRangeSelector(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range, color: NexusTheme.emerald500, size: 24),
              const SizedBox(width: 12),
              const Text('DATE RANGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateButton('From', _startDate, () => _selectDate(true)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton('To', _endDate, () => _selectDate(false)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDateButton(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: NexusTheme.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NexusTheme.slate200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: NexusTheme.slate500, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy').format(date),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReportContent(NexusProvider provider, bool isMobile) {
    switch (_selectedReportType) {
      case 'Sales Report':
        return _buildSalesReport(provider, isMobile);
      case 'Inventory Report':
        return _buildInventoryReport(provider, isMobile);
      case 'Customer Report':
        return _buildCustomerReport(provider, isMobile);
      case 'Financial Report':
        return _buildFinancialReport(provider, isMobile);
      case 'Performance Report':
        return _buildPerformanceReport(provider, isMobile);
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildSalesReport(NexusProvider provider, bool isMobile) {
    final orders = provider.orders;
    final totalSales = orders.fold(0.0, (sum, o) => sum + o.total);
    final totalOrders = orders.length;
    final avgOrderValue = totalOrders > 0 ? (totalSales / totalOrders).toDouble() : 0.0;
    
    return Column(
      children: [
        _buildSectionHeader('SALES SUMMARY'),
        const SizedBox(height: 16),
        _buildSummaryCard([
          {'label': 'Total Sales', 'value': '₹${NumberFormat('#,##,###').format(totalSales)}', 'color': Colors.green},
          {'label': 'Total Orders', 'value': '$totalOrders', 'color': Colors.blue},
          {'label': 'Avg Order Value', 'value': '₹${NumberFormat('#,##,###').format(avgOrderValue)}', 'color': Colors.purple},
        ], isMobile),
        const SizedBox(height: 24),
        _buildSectionHeader('ORDER BREAKDOWN'),
        const SizedBox(height: 16),
        _buildOrderBreakdown(orders, isMobile),
      ],
    );
  }
  
  Widget _buildInventoryReport(NexusProvider provider, bool isMobile) {
    final products = provider.products;
    final totalProducts = products.length;
    final totalValue = products.fold(0.0, (sum, p) => sum + (p.price * (p.stock ?? 0)));
    
    return Column(
      children: [
        _buildSectionHeader('INVENTORY SUMMARY'),
        const SizedBox(height: 16),
        _buildSummaryCard([
          {'label': 'Total Products', 'value': '$totalProducts', 'color': Colors.blue},
          {'label': 'Total Value', 'value': '₹${NumberFormat('#,##,###').format(totalValue)}', 'color': Colors.green},
          {'label': 'Low Stock Items', 'value': '${products.where((p) => (p.stock ?? 0) < 10).length}', 'color': Colors.red},
        ], isMobile),
        const SizedBox(height: 24),
        _buildSectionHeader('PRODUCT LIST'),
        const SizedBox(height: 16),
        _buildProductList(products, isMobile),
      ],
    );
  }
  
  Widget _buildCustomerReport(NexusProvider provider, bool isMobile) {
    final customers = provider.customers;
    final activeCustomers = customers.where((c) => c.status == 'Active').length;
    
    return Column(
      children: [
        _buildSectionHeader('CUSTOMER SUMMARY'),
        const SizedBox(height: 16),
        _buildSummaryCard([
          {'label': 'Total Customers', 'value': '${customers.length}', 'color': Colors.blue},
          {'label': 'Active', 'value': '$activeCustomers', 'color': Colors.green},
          {'label': 'Inactive', 'value': '${customers.length - activeCustomers}', 'color': Colors.orange},
        ], isMobile),
        const SizedBox(height: 24),
        _buildSectionHeader('CUSTOMER LIST'),
        const SizedBox(height: 16),
        _buildCustomerList(customers, isMobile),
      ],
    );
  }
  
  Widget _buildFinancialReport(NexusProvider provider, bool isMobile) {
    final orders = provider.orders;
    final revenue = orders.where((o) => o.status == 'Delivered').fold(0.0, (sum, o) => sum + o.total);
    final pending = orders.where((o) => o.status != 'Delivered').fold(0.0, (sum, o) => sum + o.total);
    
    return Column(
      children: [
        _buildSectionHeader('FINANCIAL SUMMARY'),
        const SizedBox(height: 16),
        _buildSummaryCard([
          {'label': 'Total Revenue', 'value': '₹${NumberFormat('#,##,###').format(revenue)}', 'color': Colors.green},
          {'label': 'Pending Amount', 'value': '₹${NumberFormat('#,##,###').format(pending)}', 'color': Colors.orange},
          {'label': 'Total Transactions', 'value': '${orders.length}', 'color': Colors.blue},
        ], isMobile),
      ],
    );
  }
  
  Widget _buildPerformanceReport(NexusProvider provider, bool isMobile) {
    final orders = provider.orders;
    final deliveryRate = orders.isNotEmpty 
      ? (orders.where((o) => o.status == 'Delivered').length / orders.length * 100).toDouble() 
      : 0.0;
    
    return Column(
      children: [
        _buildSectionHeader('PERFORMANCE METRICS'),
        const SizedBox(height: 16),
        _buildSummaryCard([
          {'label': 'Delivery Rate', 'value': '${deliveryRate.toStringAsFixed(1)}%', 'color': Colors.green},
          {'label': 'On-Time Delivery', 'value': '92%', 'color': Colors.blue},
          {'label': 'Customer Satisfaction', 'value': '4.5/5', 'color': Colors.purple},
        ], isMobile),
      ],
    );
  }
  
  Widget _buildSummaryCard(List<Map<String, dynamic>> items, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['label'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(
                  item['value'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: item['color'],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildOrderBreakdown(List<Order> orders, bool isMobile) {
    final statusCounts = <String, int>{};
    for (var order in orders) {
      statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
    }
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        children: statusCounts.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text('${entry.value}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: NexusTheme.emerald600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildProductList(List<Product> products, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        children: products.take(10).map((product) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('Stock: ${product.stock ?? 0}', style: const TextStyle(fontSize: 11, color: NexusTheme.slate500)),
                    ],
                  ),
                ),
                Text('₹${product.price}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: NexusTheme.emerald600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildCustomerList(List<Customer> customers, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        children: customers.take(10).map((customer) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: NexusTheme.emerald100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, color: NexusTheme.emerald600, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(customer.city, style: const TextStyle(fontSize: 11, color: NexusTheme.slate500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: customer.status == 'Active' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    customer.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: customer.status == 'Active' ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: NexusTheme.emerald500,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    );
  }
  
  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
  
  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Export Report', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExportOption('PDF', Icons.picture_as_pdf, Colors.red),
            const SizedBox(height: 12),
            _buildExportOption('Excel', Icons.table_chart, Colors.green),
            const SizedBox(height: 12),
            _buildExportOption('CSV', Icons.description, Colors.blue),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExportOption(String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _exportData(label);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  void _exportData(String format) {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    String content = "Report: $_selectedReportType\nGenerated: ${DateTime.now()}\n\n";
    
    if (_selectedReportType == 'Sales Report') {
      content += "Order ID,Customer,Status,Total,Date\n";
      for (var order in provider.orders) {
        content += "${order.id},${order.customerName},${order.status},${order.total},${order.createdAt}\n";
      }
    } else if (_selectedReportType == 'Inventory Report') {
      content += "SKU,Product Name,Price,Stock\n";
      for (var product in provider.products) {
        content += "${product.skuCode},${product.name},${product.price},${product.stock}\n";
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Data Exported ($format)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The report has been successfully generated.', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Data Preview:', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: SingleChildScrollView(
                child: Text(content.split('\n').take(10).join('\n') + "\n...", 
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DONE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.downloadReport(
                type: _selectedReportType,
                format: format,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Starting download for $format report...')),
              );
            },
            child: const Text('DOWNLOAD'),
          ),

        ],
      ),
    );
  }
}
