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
        title: const Text('LOGISTICS HUB TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NexusTheme.slate900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPremiumSummary(pendingOrders, isMobile),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    const Text('PENDING FREIGHT ASSIGNMENT', 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400, letterSpacing: 1.5)
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: NexusTheme.indigo50, borderRadius: BorderRadius.circular(8)),
                      child: Text('${pendingOrders.length} ORDERS', 
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.indigo600)
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: pendingOrders.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: pendingOrders.length,
                      itemBuilder: (context, index) {
                        final order = pendingOrders[index];
                        return _buildHighFidelityCostCard(context, order, provider, isMobile);
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPremiumSummary(List<Order> orders, bool isMobile) {
    double totalFreight = orders.length * 250.0;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: NexusTheme.emerald400, size: 16),
              const SizedBox(width: 8),
              const Text('ESTIMATED FREIGHT LIABILITIES', 
                style: TextStyle(color: NexusTheme.emerald400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('₹${totalFreight.toStringAsFixed(2)}', 
            style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1.5)
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
            child: Text('LIABILITY FOR ${orders.length} PENDING INBOUNDS', 
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)
            ),
          ),
        ],
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
            decoration: BoxDecoration(color: NexusTheme.slate100, shape: BoxShape.circle),
            child: const Icon(Icons.payments_outlined, size: 48, color: NexusTheme.slate300),
          ),
          const SizedBox(height: 24),
          const Text('Terminal Clear!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
          const SizedBox(height: 8),
          const Text('All freight costs approved for this cycle', style: TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHighFidelityCostCard(BuildContext context, Order order, NexusProvider provider, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: NexusTheme.indigo50, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.local_shipping_rounded, color: NexusTheme.indigo600, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.indigo600, fontSize: 11, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: NexusTheme.slate900, height: 1.1)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('VALUED AT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
                    Text('₹250.00', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: NexusTheme.emerald900)),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(height: 1, color: NexusTheme.slate100),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TRANSIT PARTNER / AGENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.verified, color: NexusTheme.blue500, size: 14),
                          const SizedBox(width: 8),
                          Text('Blue Dart Logistics'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: NexusTheme.slate900)),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _approveCost(context, order, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusTheme.indigo600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    elevation: 0,
                  ),
                  child: const Text('APPROVE & BILL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
