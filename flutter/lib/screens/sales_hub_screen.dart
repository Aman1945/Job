import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class SalesHubScreen extends StatefulWidget {
  const SalesHubScreen({super.key});

  @override
  State<SalesHubScreen> createState() => _SalesHubScreenState();
}

class _SalesHubScreenState extends State<SalesHubScreen> {
  String _selectedPeriod = 'This Month';
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final orders = provider.orders;
    
    // Calculate metrics
    final totalSales = orders.fold(0.0, (sum, o) => sum + o.total);
    final completedOrders = orders.where((o) => o.status == 'Delivered').length;
    final pendingOrders = orders.where((o) => o.status.contains('Pending')).length;
    final avgOrderValue = orders.isNotEmpty ? (totalSales / orders.length).toDouble() : 0.0;
    
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('SALES HUB', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchOrders(),
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
                // Period Selector
                _buildPeriodSelector(isMobile),
                const SizedBox(height: 24),
                
                // Sales Metrics
                _buildSalesMetrics(totalSales, completedOrders, pendingOrders, avgOrderValue, isMobile),
                const SizedBox(height: 24),
                
                // Sales Pipeline
                _buildSectionHeader('SALES PIPELINE'),
                const SizedBox(height: 16),
                _buildSalesPipeline(orders, isMobile),
                const SizedBox(height: 24),
                
                // Top Customers
                _buildSectionHeader('TOP CUSTOMERS'),
                const SizedBox(height: 16),
                _buildTopCustomers(orders, isMobile),
                const SizedBox(height: 24),
                
                // Recent Activity
                _buildSectionHeader('RECENT ACTIVITY'),
                const SizedBox(height: 16),
                _buildRecentActivity(orders, isMobile),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPeriodSelector(bool isMobile) {
    final periods = ['This Month', 'Last 6 Months', 'This Quarter', 'This Year'];
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: NexusTheme.emerald500, size: 20),
          const SizedBox(width: 12),
          const Text('Period:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              isExpanded: true,
              underline: const SizedBox(),
              items: periods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPeriod = value);
                  String periodKey = value.toLowerCase().contains('6') ? 'six-months' : 
                                     value.toLowerCase().contains('quarter') ? 'quarter' :
                                     value.toLowerCase().contains('year') ? 'year' : 'month';
                  // provider.fetchSalesHubData(period: periodKey);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSalesMetrics(double totalSales, int completed, int pending, double avgValue, bool isMobile) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: isMobile ? 12 : 16,
      crossAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: isMobile ? 1.3 : 1.5,
      children: [
        _buildMetricCard('TOTAL SALES', '₹${(totalSales / 1000).toStringAsFixed(1)}K', Icons.trending_up, Colors.green, isMobile),
        _buildMetricCard('COMPLETED', '$completed', Icons.check_circle, Colors.blue, isMobile),
        _buildMetricCard('PENDING', '$pending', Icons.pending, Colors.orange, isMobile),
        _buildMetricCard('AVG ORDER', '₹${(avgValue / 1000).toStringAsFixed(1)}K', Icons.analytics, Colors.purple, isMobile),
      ],
    );
  }
  
  Widget _buildMetricCard(String label, String value, IconData icon, Color color, bool isMobile) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: isMobile ? 10 : 11, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
              Icon(icon, color: color, size: isMobile ? 20 : 24),
            ],
          ),
          Text(value, style: TextStyle(fontSize: isMobile ? 24 : 28, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
  
  Widget _buildSalesPipeline(List<Order> orders, bool isMobile) {
    final stages = {
      'New Leads': orders.where((o) => o.status == 'Pending').length,
      'In Progress': orders.where((o) => o.status.contains('Approved')).length,
      'Negotiation': orders.where((o) => o.status.contains('Credit')).length,
      'Closed Won': orders.where((o) => o.status == 'Delivered').length,
    };
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        children: stages.entries.map((entry) {
          final percentage = orders.isNotEmpty ? (entry.value / orders.length * 100).toDouble() : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${entry.value} (${percentage.toStringAsFixed(0)}%)', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: NexusTheme.slate500)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage / 100.0,
                    minHeight: 8,
                    backgroundColor: NexusTheme.slate100,
                    valueColor: const AlwaysStoppedAnimation<Color>(NexusTheme.emerald500),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildTopCustomers(List<Order> orders, bool isMobile) {
    final customerSales = <String, double>{};
    for (var order in orders) {
      customerSales[order.customerName] = (customerSales[order.customerName] ?? 0) + order.total;
    }
    
    final topCustomers = customerSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        children: topCustomers.take(5).map((entry) {
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
                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${customerSales[entry.key]!.toInt()} orders', 
                        style: const TextStyle(fontSize: 11, color: NexusTheme.slate500)),
                    ],
                  ),
                ),
                Text('₹${(entry.value / 1000).toStringAsFixed(1)}K', 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: NexusTheme.emerald600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildRecentActivity(List<Order> orders, bool isMobile) {
    final recentOrders = orders.take(5).toList();
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        children: recentOrders.map((order) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(order.customerName, style: const TextStyle(fontSize: 11, color: NexusTheme.slate500)),
                    ],
                  ),
                ),
                Text(_formatDate(order.createdAt), 
                  style: const TextStyle(fontSize: 10, color: NexusTheme.slate400)),
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
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      default: return Colors.blue;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
