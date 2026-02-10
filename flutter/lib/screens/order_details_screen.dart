import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final customer = provider.customers.firstWhere((c) => c.id == order.customerId, orElse: () => Customer(id: '', name: 'Unknown', address: '', city: 'NA', status: 'Inactive'));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('LIVE MISSION TRACKER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: NexusTheme.indigo600),
            onPressed: () {
              provider.downloadReport(type: 'Invoice ${order.id}', format: 'pdf');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading Invoice PDF...')),
              );
            },
            tooltip: 'Download Invoice PDF',
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildOrderHeader(order),
            const SizedBox(height: 24),

            // Credit Exposure Matrix Section
            _buildSectionTitle('⚡ 2. Credit Exposure Matrix', 'FINANCIAL HEALTH REVIEW FOR ${order.customerName}'),
            const SizedBox(height: 16),
            _buildCreditStatsGrid(customer),
            const SizedBox(height: 16),
            _buildAgingTable(customer),
            const SizedBox(height: 24),

            // Action Panel
            _buildActionPanel(context, order),
            const SizedBox(height: 24),

            // Intelligence Insight Section
            if (order.intelligenceInsight != null) ...[
              _buildIntelligenceInsight(order.intelligenceInsight!),
              const SizedBox(height: 24),
            ],

            // Workflow Trace Section
            _buildSectionTitle('MISSION WORKFLOW TRACE', ''),
            const SizedBox(height: 16),
            _buildWorkflowTrace(order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: NexusTheme.indigo50, borderRadius: BorderRadius.circular(8)),
                child: Text(order.status.toUpperCase(), style: const TextStyle(color: NexusTheme.indigo600, fontWeight: FontWeight.w900, fontSize: 9)),
              ),
              const SizedBox(height: 12),
              Text(order.id, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
              Text('${order.customerName} • ${order.partnerType ?? "Distributor"}', style: const TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('ORDER BOOKING VALUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: NexusTheme.slate400)),
              Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
        if (subtitle.isNotEmpty)
          Text(subtitle.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildCreditStatsGrid(Customer customer) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('CURRENT STANDING', 'CRITICAL EXPOSURE (15+ DAYS)', const Color(0xFFF43F5E)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('AVAILABLE CREDIT', '₹${NumberFormat('#,##,###').format(customer.limit - customer.osBalance)}', const Color(0xFF6366F1)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.priority_high, color: Colors.white, size: 8),
              ),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildAgingTable(Customer customer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: NexusTheme.slate200),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 40,
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
          columns: ['Days', 'Limit', 'O/s Bal', 'Overdue', '0 to 7', '7-15', '15-30', '30-45'].map((h) => DataColumn(label: Text(h.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)))).toList(),
          rows: [
            DataRow(cells: [
              const DataCell(Text('30 days', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
              DataCell(Text('₹${(customer.limit/1000).toStringAsFixed(0)}K', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
              DataCell(Text('₹${(customer.osBalance/1000).toStringAsFixed(0)}K', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
              const DataCell(Text('₹0', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red))),
              const DataCell(Text('₹2L', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
              const DataCell(Text('₹3L', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(4)),
                child: const Text('₹3.9L', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.pink)),
              )),
              const DataCell(Text('-')),
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildActionPanel(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('INTERNAL NOTE / REJECTION REASON', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: NexusTheme.slate400)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            height: 100,
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(20)),
            child: const Text('Add internal verification notes...', style: TextStyle(color: NexusTheme.slate400, fontSize: 12)),
          ),
          const SizedBox(height: 24),
          _buildActionButton(Icons.check_circle_outline, 'APPROVE ORDER', const Color(0xFF059669), () {
             Provider.of<NexusProvider>(context, listen: false).updateOrderStatus(order.id, 'Credit Approved');
             Navigator.pop(context);
          }),
          const SizedBox(height: 12),
          _buildActionButton(Icons.pause_circle_outline, 'PLACE ON HOLD', const Color(0xFFD97706), () {}),
          const SizedBox(height: 12),
          _buildActionButton(Icons.cancel_outlined, 'REJECT ORDER', const Color(0xFFE11D48), () {}, isOutline: true),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap, {bool isOutline = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isOutline ? Colors.white : color,
          borderRadius: BorderRadius.circular(24),
          border: isOutline ? Border.all(color: color.withOpacity(0.2)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isOutline ? color : Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isOutline ? color : Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildIntelligenceInsight(String insight) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF059669),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('INTELLIGENCE INSIGHT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9)),
                const SizedBox(height: 8),
                Text(insight, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWorkflowTrace(Order order) {
    final steps = [
      'PENDING CREDIT APPROVAL',
      'ON HOLD',
      'PENDING WH SELECTION',
      'PENDING PACKING',
      'PENDING LOGISTICS',
      'DELIVERED'
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          bool isActive = order.status.toUpperCase() == steps[index];
          return IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF059669).withOpacity(0.1) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: isActive ? Border.all(color: const Color(0xFF059669)) : null,
                      ),
                      child: isActive 
                        ? const Icon(Icons.check, size: 14, color: Color(0xFF059669))
                        : Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle))),
                    ),
                    if (index < steps.length - 1)
                      Expanded(child: Container(width: 1, color: const Color(0xFFF1F5F9))),
                  ],
                ),
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w900, 
                      fontSize: 10, 
                      color: isActive ? const Color(0xFF059669) : const Color(0xFFCBD5E1)
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
