import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class LogisticsHubScreen extends StatelessWidget {
  const LogisticsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final readyOrders = provider.orders
        .where((o) => o.status == 'Invoiced' || o.status == 'Ready for Dispatch')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGISTICS HUB'),
        backgroundColor: NexusTheme.emerald900,
      ),
      body: readyOrders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_outlined, size: 80, color: NexusTheme.slate300),
                  SizedBox(height: 16),
                  Text(
                    'Fleet Ready!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NexusTheme.slate400),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No orders pending driver assignment',
                    style: TextStyle(color: NexusTheme.slate400),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: readyOrders.length,
              itemBuilder: (context, index) {
                final order = readyOrders[index];
                return _buildOrderCard(context, order, provider);
              },
            ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, NexusProvider provider) {
    final drivers = provider.users.where((u) => u.role == UserRole.delivery).toList();

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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: NexusTheme.slate400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              order.deliveryAddress,
                              style: const TextStyle(
                                fontSize: 12,
                                color: NexusTheme.slate500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: NexusTheme.purple500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ASSIGN',
                    style: TextStyle(
                      color: NexusTheme.purple900,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'ASSIGN DRIVER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: NexusTheme.slate400,
              ),
            ),
            const SizedBox(height: 12),
            ...drivers.map((driver) => _buildDriverTile(context, order, driver, provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverTile(BuildContext context, Order order, User driver, NexusProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: NexusTheme.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: NexusTheme.emerald500,
          child: Text(
            driver.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          driver.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          driver.id,
          style: const TextStyle(fontSize: 12, color: NexusTheme.slate500),
        ),
        trailing: ElevatedButton(
          onPressed: () => _assignDriver(context, order, driver, provider),
          style: ElevatedButton.styleFrom(
            backgroundColor: NexusTheme.emerald600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('ASSIGN', style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  void _assignDriver(BuildContext context, Order order, User driver, NexusProvider provider) async {
    final success = await provider.updateOrderStatus(order.id, 'Picked Up');
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.id} assigned to ${driver.name}'),
          backgroundColor: NexusTheme.emerald600,
        ),
      );
    }
  }
}
