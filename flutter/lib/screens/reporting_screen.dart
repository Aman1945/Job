import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import '../widgets/advanced_filters_widget.dart';
import '../utils/report_exporter.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  String _selectedReportType = 'Sales Report';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59);
  
  // Advanced Filters
  List<String> _selectedCategories = [];
  List<String> _selectedRegions = [];
  List<String> _selectedSalespersons = [];
  List<String> _selectedStatuses = [];
  bool _isInitialLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    await provider.fetchOrders();
    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    
    if (_isInitialLoading || provider.isLoading) {
      return Scaffold(
        backgroundColor: NexusTheme.slate50,
        appBar: AppBar(title: const Text('REPORTING CENTER')),
        body: const Center(child: CircularProgressIndicator(color: NexusTheme.emerald600)),
      );
    }
    
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
                    _selectedCategories = [];
                    _selectedRegions = [];
                    _selectedSalespersons = [];
                    _selectedStatuses = [];
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
    if (provider.orders.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: NexusTheme.slate300),
            const SizedBox(height: 16),
            const Text('NO ORDERS FOUND IN SYSTEM', style: TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
          ],
        ),
      );
    }

    // Apply filters to orders
    var filteredOrders = provider.orders.where((order) {
      // Date range filter
      if (order.createdAt.isBefore(_startDate) || order.createdAt.isAfter(_endDate)) {
        return false;
      }

      // Status filter
      if (_selectedStatuses.isNotEmpty && !_selectedStatuses.contains(order.status)) {
        return false;
      }

      // Salesperson filter (if order has salespersonId)
      if (_selectedSalespersons.isNotEmpty && 
          order.salespersonId != null && 
          !_selectedSalespersons.contains(order.salespersonId)) {
        return false;
      }

      // Category & Region filters would need additional order fields
      // For now, we'll filter based on available data
      
      return true;
    }).toList();

    final totalSales = filteredOrders.fold(0.0, (sum, o) => sum + o.total);
    final totalOrders = filteredOrders.length;
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
        _buildSectionHeader('SALES TREND'),
        const SizedBox(height: 16),
        _buildSalesTrendChart(filteredOrders, isMobile),
        const SizedBox(height: 24),
        _buildSectionHeader('ORDERS DATA TABLE'),
        const SizedBox(height: 16),
        _buildOrdersDataTable(filteredOrders, isMobile),
      ],
    );
  }

  Widget _buildSalesTrendChart(List<Order> orders, bool isMobile) {
    if (orders.isEmpty) return const SizedBox();

    // Group sales by date
    Map<String, double> dailySales = {};
    for (var order in orders) {
      String date = DateFormat('dd/MM').format(order.createdAt);
      dailySales[date] = (dailySales[date] ?? 0) + order.total;
    }

    var sortedDates = dailySales.keys.toList()..sort((a, b) => a.compareTo(b));
    if (sortedDates.length > 7) {
      sortedDates = sortedDates.sublist(sortedDates.length - 7);
    }

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < sortedDates.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailySales[sortedDates[i]]!,
              color: NexusTheme.emerald500,
              width: isMobile ? 12 : 18,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (dailySales.values.isEmpty ? 0 : dailySales.values.reduce((a, b) => a > b ? a : b)) * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => NexusTheme.slate900,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${sortedDates[groupIndex]}\n₹${NumberFormat('#,##,###').format(rod.toY)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < sortedDates.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(sortedDates[index], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: NexusTheme.slate500)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  return Text(
                    '₹${(value / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(fontSize: 8, color: NexusTheme.slate400),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildOrdersDataTable(List<Order> orders, bool isMobile) {
    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NexusTheme.slate200),
        ),
        child: Column(
          children: [
            Icon(Icons.filter_alt_off, size: 48, color: NexusTheme.slate300),
            const SizedBox(height: 16),
            Text(
              'No orders match the selected filters',
              style: TextStyle(color: NexusTheme.slate500, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 520, // Increased from 500 to account for 466px content + 40px padding
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: NexusTheme.slate50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text('ORD\nID', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate600, height: 1.1)),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 130,
                      child: Text('CUSTOMER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate600)),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      child: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate600)),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text('AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate600), textAlign: TextAlign.right),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text('DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate600), textAlign: TextAlign.right),
                    ),
                  ],
                ),
              ),
              
              // Table Rows
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length > 50 ? 50 : orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _CollapsibleOrderRow(order: order, isEven: index % 2 == 0);
                },
              ),
              
              // Footer
              if (orders.length > 50)
                Container(
                  width: 520,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NexusTheme.slate50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Showing 50 of ${orders.length} orders',
                    style: TextStyle(fontSize: 11, color: NexusTheme.slate500, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        break;
      case 'approved':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        break;
      case 'in transit':
        bgColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple.shade700;
        break;
      case 'delivered':
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        break;
      case 'cancelled':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = NexusTheme.slate100;
        textColor = NexusTheme.slate600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
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
        _buildSectionHeader('STOCK DISTRIBUTION'),
        const SizedBox(height: 16),
        _buildInventoryChart(products, isMobile),
        const SizedBox(height: 24),
        _buildSectionHeader('PRODUCT LIST'),
        const SizedBox(height: 16),
        _buildProductList(products, isMobile),
      ],
    );
  }

  Widget _buildInventoryChart(List<Product> products, bool isMobile) {
    int lowStock = products.where((p) => (p.stock ?? 0) < 10).length;
    int optimal = products.where((p) => (p.stock ?? 0) >= 10 && (p.stock ?? 0) < 50).length;
    int surplus = products.where((p) => (p.stock ?? 0) >= 50).length;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: Colors.red.shade400,
              value: lowStock.toDouble(),
              title: isMobile ? '' : 'Low',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.blue.shade400,
              value: optimal.toDouble(),
              title: isMobile ? '' : 'Optimal',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.green.shade400,
              value: surplus.toDouble(),
              title: isMobile ? '' : 'Surplus',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
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
        _buildSectionHeader('REGION DISTRIBUTION'),
        const SizedBox(height: 16),
        _buildCustomerChart(customers, isMobile),
        const SizedBox(height: 24),
        _buildSectionHeader('CUSTOMER LIST'),
        const SizedBox(height: 16),
        _buildCustomerList(customers, isMobile),
      ],
    );
  }

  Widget _buildCustomerChart(List<Customer> customers, bool isMobile) {
    Map<String, int> regionCounts = {};
    for (var c in customers) {
      regionCounts[c.city] = (regionCounts[c.city] ?? 0) + 1;
    }

    var sortedRegions = regionCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (sortedRegions.length > 5) sortedRegions = sortedRegions.sublist(0, 5);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  int idx = val.toInt();
                  if (idx >= 0 && idx < sortedRegions.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(sortedRegions[idx].key, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: sortedRegions.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: NexusTheme.indigo500,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
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

  // Export dialog methods below
  
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
    // Capture state variables before async operation
    final startDate = _startDate;
    final endDate = _endDate;
    final selectedStatuses = List<String>.from(_selectedStatuses);
    final selectedSalespersons = List<String>.from(_selectedSalespersons);
    final reportType = _selectedReportType;
    
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
        if (order.createdAt.isBefore(startDate) || order.createdAt.isAfter(endDate)) {
          return false;
        }

        // Status filter
        if (selectedStatuses.isNotEmpty && !selectedStatuses.contains(order.status)) {
          return false;
        }

        // Salesperson filter
        if (selectedSalespersons.isNotEmpty && 
            (order.salespersonId == null || !selectedSalespersons.contains(order.salespersonId))) {
          return false;
        }

        // Add more filters as needed (category, region, etc.)
        return true;
      }).toList();

      // Export based on format
      if (format == 'excel') {
        await ReportExporter.exportToExcel(
          orders: filteredOrders,
          reportType: reportType,
          startDate: startDate,
          endDate: endDate,
        );
      } else if (format == 'csv') {
        await ReportExporter.exportToCSV(
          orders: filteredOrders,
          reportType: reportType,
          startDate: startDate,
          endDate: endDate,



          
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
}

class _CollapsibleOrderRow extends StatefulWidget {
  final Order order;
  final bool isEven;

  const _CollapsibleOrderRow({required this.order, required this.isEven});

  @override
  State<_CollapsibleOrderRow> createState() => _CollapsibleOrderRowState();
}

class _CollapsibleOrderRowState extends State<_CollapsibleOrderRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: widget.isEven ? Colors.white : NexusTheme.slate50.withOpacity(0.5),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      AnimatedRotation(
                        turns: _isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.chevron_right, size: 14, color: NexusTheme.slate400),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.order.id,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: NexusTheme.slate900, height: 1.1),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 130,
                  child: Text(
                    widget.order.customerName,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: NexusTheme.slate700, height: 1.1),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: _buildStatusChip(widget.order.status),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    '₹${NumberFormat('#,##,###').format(widget.order.total)}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate900),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    DateFormat('dd/MM/yy').format(widget.order.createdAt),
                    style: const TextStyle(fontSize: 10, color: NexusTheme.slate500),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NexusTheme.slate50,
              border: Border(
                top: BorderSide(color: NexusTheme.slate200),
                bottom: BorderSide(color: NexusTheme.slate200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ORDER ITEMS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate500, letterSpacing: 1)),
                const SizedBox(height: 8),
                ...widget.order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.name} x ${item.quantity}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('₹${NumberFormat('#,##,###').format(item.price * item.quantity)}', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                )).toList(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    Text('₹${NumberFormat('#,##,###').format(widget.order.total)}', 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: NexusTheme.emerald600)),
                  ],
                ),
              ],
            ),
          ),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        break;
      case 'approved':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        break;
      case 'in transit':
        bgColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple.shade700;
        break;
      case 'delivered':
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        break;
      case 'cancelled':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = NexusTheme.slate100;
        textColor = NexusTheme.slate600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
