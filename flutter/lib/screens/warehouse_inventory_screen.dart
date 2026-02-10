import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class WarehouseInventoryScreen extends StatelessWidget {
  const WarehouseInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final pendingOrders = provider.orders.where((o) => o.status == 'Pending Packing').toList();

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('3. WAREHOUSE OPERATIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
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
                    return _buildPackingCard(context, order, provider, isMobile);
                  },
                );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: NexusTheme.slate300),
          SizedBox(height: 16),
          Text('All Orders Packed!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
          Text('No orders currently pending packing', style: TextStyle(color: NexusTheme.slate400)),
        ],
      ),
    );
  }

  Widget _buildPackingCard(BuildContext context, Order order, NexusProvider provider, bool isMobile) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(order.id, style: TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.indigo600, fontSize: isMobile ? 12 : 13))),
                Icon(Icons.qr_code_2, color: NexusTheme.slate300, size: isMobile ? 20 : 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.customerName, style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(width: isMobile ? 5 : 6, height: isMobile ? 5 : 6, decoration: const BoxDecoration(color: NexusTheme.emerald500, shape: BoxShape.circle)),
                  SizedBox(width: isMobile ? 10 : 12),
                  Expanded(child: Text(item.name, style: TextStyle(fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.w500))),
                  Text('x${item.quantity}', style: TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate900, fontSize: isMobile ? 13 : 14)),
                ],
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _markPacked(context, order, provider),
                icon: Icon(Icons.check_circle_outline, size: isMobile ? 18 : 20),
                label: Text('CONFIRM PACKING', style: TextStyle(fontSize: isMobile ? 12 : 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusTheme.emerald600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markPacked(BuildContext context, Order order, NexusProvider provider) async {
    final success = await provider.updateOrderStatus(order.id, 'Packed');
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order ${order.id} packed and ready for billing'), backgroundColor: NexusTheme.emerald600),
      );
    }
  }
}
