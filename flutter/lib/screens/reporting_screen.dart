import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import '../widgets/advanced_filters_widget.dart';
import '../utils/report_exporter.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  String _selectedReportType = 'Sales Report';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  // Advanced Filters
  List<String> _selectedCategories = [];
  List<String> _selectedRegions = [];
  List<String> _selectedSalespersons = [];
  List<String> _selectedStatuses = [];
  
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
                const SizedBox(height: 20),
                
                // Advanced Filters
                AdvancedFiltersWidget(
                  selectedCategories: _selectedCategories,
                  selectedRegions: _selectedRegions,
                  selectedSalespersons: _selectedSalespersons,
                  selectedStatuses: _selectedStatuses,
                  onCategoriesChanged: (val) => setState(() => _selectedCategories = val),
                  onRegionsChanged: (val) => setState(() => _selectedRegions = val),
                  onSalespersonsChanged: (val) => setState(() => _selectedSalespersons = val),
                  onStatusesChanged: (val) => setState(() => _selectedStatuses = val),
                  onClearAll: () => setState(() {
                    _selectedCategories.clear();
                    _selectedRegions.clear();
                    _selectedSalespersons.clear();
                    _selectedStatuses.clear();
                  }),
                ),
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

  // New enhanced export dialog is below (line 623+)
  
  }

  void _showExportDialog(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.file_download, color: NexusTheme.emerald600),
            SizedBox(width: 12),
            Text('Export Report', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select export format:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildExportOption(
              context,
              'Excel (.xlsx)',
              'Formatted spreadsheet with styling',
              Icons.table_chart,
              NexusTheme.emerald600,
              () => _exportReport(context, provider, 'excel'),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              context,
              'CSV (.csv)',
              'Comma-separated values',
              Icons.description,
              NexusTheme.indigo600,
              () => _exportReport(context, provider, 'csv'),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              context,
              'PDF (.pdf)',
              'Portable document format (Coming Soon)',
              Icons.picture_as_pdf,
              NexusTheme.slate400,
              null, // Disabled for now
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    final isDisabled = onTap == null;
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled ? NexusTheme.slate50 : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled ? NexusTheme.slate200 : color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDisabled ? NexusTheme.slate200 : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDisabled ? NexusTheme.slate400 : color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDisabled ? NexusTheme.slate400 : NexusTheme.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDisabled ? NexusTheme.slate300 : NexusTheme.slate500,
                    ),
                  ),
                ],
              ),
            ),
            if (!isDisabled)
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Future<void> _exportReport(BuildContext context, NexusProvider provider, String format) async {
    Navigator.pop(context); // Close dialog

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: NexusTheme.emerald600),
                SizedBox(height: 16),
                Text('Generating report...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Filter orders based on selected filters
      var filteredOrders = provider.orders.where((order) {
        // Date range filter
        if (order.createdAt.isBefore(_startDate) || order.createdAt.isAfter(_endDate)) {
          return false;
        }

        // Status filter
        if (_selectedStatuses.isNotEmpty && !_selectedStatuses.contains(order.status)) {
          return false;
        }

        // Salesperson filter
        if (_selectedSalespersons.isNotEmpty && 
            (order.salespersonId == null || !_selectedSalespersons.contains(order.salespersonId))) {
          return false;
        }

        // Add more filters as needed (category, region, etc.)
        return true;
      }).toList();

      // Export based on format
      if (format == 'excel') {
        await ReportExporter.exportToExcel(
          orders: filteredOrders,
          reportType: _selectedReportType,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else if (format == 'csv') {
        await ReportExporter.exportToCSV(
          orders: filteredOrders,
          reportType: _selectedReportType,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      // Close loading
      if (context.mounted) Navigator.pop(context);

      // Show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Report exported successfully!', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${filteredOrders.length} orders exported as ${format.toUpperCase()}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: NexusTheme.emerald600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (context.mounted) Navigator.pop(context);

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

