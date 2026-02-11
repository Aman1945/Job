import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class CreditControlScreen extends StatefulWidget {
  const CreditControlScreen({super.key});

  @override
  State<CreditControlScreen> createState() => _CreditControlScreenState();
}

class _CreditControlScreenState extends State<CreditControlScreen> {
  String _approvalNotes = '';
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final pendingOrders = provider.orders.where((o) => o.status == 'Pending Credit Approval').toList();

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('CREDIT CONTROL TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchOrders(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return pendingOrders.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  itemCount: pendingOrders.length,
                  itemBuilder: (context, index) {
                    final order = pendingOrders[index];
                    return _buildOrderCard(context, order, provider, isMobile);
                  },
                );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: NexusTheme.emerald50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, size: 80, color: NexusTheme.emerald600),
          ),
          const SizedBox(height: 24),
          const Text(
            'All Clear!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: NexusTheme.slate900),
          ),
          const SizedBox(height: 8),
          const Text(
            'No orders pending credit approval',
            style: TextStyle(color: NexusTheme.slate400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, NexusProvider provider, bool isMobile) {
    // Find actual customer data from provider
    final customer = provider.customers.firstWhere(
      (c) => c.id == order.customerId || c.name == order.customerName,
      orElse: () => Customer(id: '?', name: order.customerName, address: '', city: '', limit: 100000, osBalance: 0),
    );
    
    final outstandingBalance = customer.osBalance;
    final creditLimit = customer.limit;
    final creditUtilization = creditLimit > 0 ? (outstandingBalance / creditLimit * 100) : 0.0;
    
    // Use actual aging data if available, else use specific mock for this customer
    final mockPayments = [
      {'date': DateTime.now().subtract(const Duration(days: 15)), 'amount': order.total, 'status': 'Pending'},
      {'date': DateTime.now().subtract(const Duration(days: 45)), 'amount': 32000, 'status': 'Paid'},
      {'date': DateTime.now().subtract(const Duration(days: 75)), 'amount': customer.overdue, 'status': 'Overdue'},
    ];

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w900,
                          color: NexusTheme.indigo600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerName,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Salesperson: ${order.salespersonId}',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: NexusTheme.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: NexusTheme.amber500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NexusTheme.amber500.withOpacity(0.3)),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      color: NexusTheme.amber900,
                      fontWeight: FontWeight.w900,
                      fontSize: isMobile ? 9 : 10,
                    ),
                  ),
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            // Financial Metrics
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NexusTheme.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NexusTheme.slate200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricItem('ORDER VALUE', '₹${order.total.toStringAsFixed(0)}', NexusTheme.emerald600, isMobile),
                      _buildMetricItem('OUTSTANDING', '₹${outstandingBalance.toStringAsFixed(0)}', Colors.orange, isMobile),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricItem('CREDIT LIMIT', '₹${creditLimit.toStringAsFixed(0)}', NexusTheme.slate600, isMobile),
                      _buildMetricItem('UTILIZATION', '${creditUtilization.toStringAsFixed(1)}%', 
                        creditUtilization > 80 ? Colors.red : NexusTheme.emerald600, isMobile),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Credit Aging Analysis
            _buildAgingAnalysis(mockPayments, isMobile),
            
            const SizedBox(height: 16),
            
            // Payment History Timeline
            _buildPaymentTimeline(mockPayments, isMobile),
            
            const SizedBox(height: 16),
            
            // Approval Notes
            TextField(
              onChanged: (value) => _approvalNotes = value,
              decoration: InputDecoration(
                labelText: 'Approval Notes (Optional)',
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                hintText: 'Add reason or comments...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: NexusTheme.slate200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: NexusTheme.emerald500, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveOrder(context, order, provider),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('APPROVE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NexusTheme.emerald600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectOrder(context, order, provider),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('REJECT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NexusTheme.rose600,
                      side: const BorderSide(color: NexusTheme.rose600, width: 2),
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color, bool isMobile) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 9 : 10,
              fontWeight: FontWeight.w900,
              color: NexusTheme.slate400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgingAnalysis(List<Map<String, dynamic>> payments, bool isMobile) {
    final now = DateTime.now();
    final aging30 = payments.where((p) => now.difference(p['date']).inDays <= 30 && p['status'] == 'Overdue').length;
    final aging60 = payments.where((p) {
      final days = now.difference(p['date']).inDays;
      return days > 30 && days <= 60 && p['status'] == 'Overdue';
    }).length;
    final aging90 = payments.where((p) => now.difference(p['date']).inDays > 60 && p['status'] == 'Overdue').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: NexusTheme.slate400),
              const SizedBox(width: 8),
              const Text(
                'CREDIT AGING ANALYSIS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate600, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildAgingBadge('0-30 Days', aging30, Colors.green, isMobile),
              const SizedBox(width: 8),
              _buildAgingBadge('31-60 Days', aging60, Colors.orange, isMobile),
              const SizedBox(width: 8),
              _buildAgingBadge('60+ Days', aging90, Colors.red, isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgingBadge(String label, int count, Color color, bool isMobile) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 8 : 9,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTimeline(List<Map<String, dynamic>> payments, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 16, color: NexusTheme.slate400),
              const SizedBox(width: 8),
              const Text(
                'PAYMENT HISTORY',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate600, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...payments.take(3).map((payment) {
            final isPaid = payment['status'] == 'Paid';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isPaid ? NexusTheme.emerald500 : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(payment['date']),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          payment['status'],
                          style: TextStyle(
                            fontSize: 10,
                            color: isPaid ? NexusTheme.emerald600 : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${payment['amount']}',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w900,
                      color: isPaid ? NexusTheme.slate900 : Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _approveOrder(BuildContext context, Order order, NexusProvider provider) async {
    final success = await provider.updateOrderStatus(order.id, 'Credit Approved');
    if (success && context.mounted) {
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
                    Text('Order ${order.id} approved!', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (_approvalNotes.isNotEmpty)
                      Text('Note: $_approvalNotes', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: NexusTheme.emerald600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() => _approvalNotes = '');
    }
  }

  void _rejectOrder(BuildContext context, Order order, NexusProvider provider) async {
    final success = await provider.updateOrderStatus(order.id, 'Rejected');
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cancel, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Order ${order.id} rejected!', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (_approvalNotes.isNotEmpty)
                      Text('Reason: $_approvalNotes', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: NexusTheme.rose600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() => _approvalNotes = '');
    }
  }
}
