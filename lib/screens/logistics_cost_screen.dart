import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class LogisticsCostScreen extends StatelessWidget {
  const LogisticsCostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final pendingOrders = provider.orders.where((o) => o.status == 'Cost Added').toList();

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('4. LOGISTICS COSTING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      ),
      body: Column(
        children: [
          _buildSummaryHeader(pendingOrders),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                const Text('PENDING FREIGHT ASSIGNMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400, letterSpacing: 1)),
                const Spacer(),
                Text('${pendingOrders.length} ORDERS', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.indigo600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: pendingOrders.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pendingOrders.length,
                  itemBuilder: (context, index) {
                    final order = pendingOrders[index];
                    return _buildCostCard(context, order, provider);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(List<Order> orders) {
    double totalFreight = orders.length * 250.0; // Mock calculation
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: NexusTheme.slate900,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: NexusTheme.slate900.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Text('ESTIMATED FREIGHT LIABILITIES', style: TextStyle(color: NexusTheme.emerald400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Text('₹${totalFreight.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('FOR ${orders.length} PENDING INBOUNDS', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payments_outlined, size: 80, color: NexusTheme.slate300),
          SizedBox(height: 16),
          Text('Liquidity Clear!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
          Text('No freight costs pending approval', style: TextStyle(color: NexusTheme.slate400)),
        ],
      ),
    );
  }

  Widget _buildCostCard(BuildContext context, Order order, NexusProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: NexusTheme.indigo50, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.local_shipping_outlined, color: NexusTheme.indigo600),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate400, fontSize: 11)),
                      Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
                const Text('₹250.00', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: NexusTheme.emerald900)),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRANSIT PARTNER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
                      Text('Blue Dart Logistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _approveCost(context, order, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusTheme.indigo600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('APPROVE & BILL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _approveCost(BuildContext context, Order order, NexusProvider provider) async {
    final success = await provider.updateOrderStatus(order.id, 'Ready for Invoice');
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Freight cost approved for ${order.id}'), backgroundColor: NexusTheme.indigo600),
      );
    }
  }
}
