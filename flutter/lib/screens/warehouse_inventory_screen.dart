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
      body: pendingOrders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingOrders.length,
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                return _buildPackingCard(context, order, provider);
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

  Widget _buildPackingCard(BuildContext context, Order order, NexusProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.indigo600)),
                const Icon(Icons.qr_code_2, color: NexusTheme.slate300),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: NexusTheme.emerald500, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                  Text('x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
                ],
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _markPacked(context, order, provider),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('CONFIRM PACKING'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusTheme.emerald600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
