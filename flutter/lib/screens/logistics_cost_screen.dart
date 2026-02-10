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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Column(
            children: [
              _buildSummaryHeader(pendingOrders, isMobile),
              const SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
                child: Row(
                  children: [
                    Text('PENDING FREIGHT ASSIGNMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 9 : 10, color: NexusTheme.slate400, letterSpacing: 1)),
                    const Spacer(),
                    Text('${pendingOrders.length} ORDERS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 9 : 10, color: NexusTheme.indigo600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: pendingOrders.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                      itemCount: pendingOrders.length,
                      itemBuilder: (context, index) {
                        final order = pendingOrders[index];
                        return _buildCostCard(context, order, provider, isMobile);
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(List<Order> orders, bool isMobile) {
    double totalFreight = orders.length * 250.0; // Mock calculation
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: NexusTheme.slate900,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
        boxShadow: [BoxShadow(color: NexusTheme.slate900.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text('ESTIMATED FREIGHT LIABILITIES', style: TextStyle(color: NexusTheme.emerald400, fontSize: isMobile ? 9 : 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          SizedBox(height: isMobile ? 8 : 12),
          Text('₹${totalFreight.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: isMobile ? 28 : 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('FOR ${orders.length} PENDING INBOUNDS', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: isMobile ? 8 : 9, fontWeight: FontWeight.bold)),
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

  Widget _buildCostCard(BuildContext context, Order order, NexusProvider provider, bool isMobile) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  decoration: BoxDecoration(color: NexusTheme.indigo50, borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.local_shipping_outlined, color: NexusTheme.indigo600, size: isMobile ? 20 : 24),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate400, fontSize: isMobile ? 10 : 11)),
                      Text(order.customerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 15)),
                    ],
                  ),
                ),
                Text('₹250.00', style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 16 : 18, color: NexusTheme.emerald900)),
              ],
            ),
            const Divider(height: 32),
            isMobile
                ? Column(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TRANSIT PARTNER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
                          Text('Blue Dart Logistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _approveCost(context, order, provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NexusTheme.indigo600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('APPROVE & BILL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  )
                : Row(
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
