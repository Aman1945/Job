import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class WarehouseSelectionScreen extends StatelessWidget {
  const WarehouseSelectionScreen({super.key});

  static const warehouses = [
    'Mumbai Central',
    'Delhi NCR',
    'Bangalore Hub',
    'Chennai Depot',
    'Kolkata East',
    'Hyderabad Tech',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final pendingOrders = provider.orders
        .where((o) => o.status == 'Credit Approved' || o.status == 'Pending WH Selection')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WAREHOUSE ASSIGNMENT'),
        backgroundColor: NexusTheme.emerald900,
      ),
      body: pendingOrders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warehouse_outlined, size: 80, color: NexusTheme.slate300),
                  SizedBox(height: 16),
                  Text(
                    'All Assigned!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NexusTheme.slate400),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No orders pending warehouse assignment',
                    style: TextStyle(color: NexusTheme.slate400),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingOrders.length,
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                return _buildOrderCard(context, order, provider);
              },
            ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, NexusProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: NexusTheme.slate400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: NexusTheme.blue500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ASSIGN WH',
                    style: TextStyle(
                      color: NexusTheme.blue900,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'SELECT WAREHOUSE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: NexusTheme.slate400,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: warehouses.map((wh) {
                return ChoiceChip(
                  label: Text(wh),
                  selected: false,
                  onSelected: (selected) {
                    if (selected) {
                      _assignWarehouse(context, order, wh, provider);
                    }
                  },
                  selectedColor: NexusTheme.emerald500,
                  backgroundColor: NexusTheme.slate100,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _assignWarehouse(BuildContext context, Order order, String warehouse, NexusProvider provider) async {
    // Update order with warehouse and change status
    final success = await provider.updateOrderStatus(order.id, 'Pending Packing');
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.id} assigned to $warehouse'),
          backgroundColor: NexusTheme.emerald600,
        ),
      );
    }
  }
}
