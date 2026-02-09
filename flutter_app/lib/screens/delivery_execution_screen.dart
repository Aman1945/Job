import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class DeliveryExecutionScreen extends StatelessWidget {
  const DeliveryExecutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final myOrders = provider.orders
        .where((o) => 
            o.status == 'Picked Up' || 
            o.status == 'Out for Delivery' || 
            o.status == 'In Transit')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DELIVERY EXECUTION'),
        backgroundColor: NexusTheme.emerald900,
      ),
      body: myOrders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: NexusTheme.slate300),
                  SizedBox(height: 16),
                  Text(
                    'All Delivered!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NexusTheme.slate400),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No active deliveries',
                    style: TextStyle(color: NexusTheme.slate400),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myOrders.length,
              itemBuilder: (context, index) {
                final order = myOrders[index];
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
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NexusTheme.slate50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: NexusTheme.emerald600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.deliveryAddress ?? 'Address not provided',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ORDER VALUE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: NexusTheme.slate400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: NexusTheme.emerald900,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'ITEMS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: NexusTheme.slate400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.items.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: NexusTheme.slate700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context, order, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Picked Up':
        bgColor = NexusTheme.blue500.withValues(alpha: 0.1);
        textColor = NexusTheme.blue900;
        break;
      case 'Out for Delivery':
      case 'In Transit':
        bgColor = NexusTheme.purple500.withValues(alpha: 0.1);
        textColor = NexusTheme.purple900;
        break;
      default:
        bgColor = NexusTheme.slate200;
        textColor = NexusTheme.slate700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order, NexusProvider provider) {
    if (order.status == 'Picked Up') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _startDelivery(context, order, provider),
          icon: const Icon(Icons.navigation, size: 18),
          label: const Text('START DELIVERY'),
          style: ElevatedButton.styleFrom(
            backgroundColor: NexusTheme.emerald600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _markDelivered(context, order, provider),
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('DELIVERED'),
            style: ElevatedButton.styleFrom(
              backgroundColor: NexusTheme.emerald600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showIssueDialog(context, order, provider),
            icon: const Icon(Icons.report_problem, size: 18),
            label: const Text('ISSUE'),
            style: OutlinedButton.styleFrom(
              foregroundColor: NexusTheme.rose600,
              side: const BorderSide(color: NexusTheme.rose600),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _startDelivery(BuildContext context, Order order, NexusProvider provider) async {
    final success = await provider.updateOrderStatus(order.id, 'Out for Delivery');
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery started! Navigate to customer location.'),
          backgroundColor: NexusTheme.emerald600,
        ),
      );
    }
  }

  void _markDelivered(BuildContext context, Order order, NexusProvider provider) async {
    final success = await provider.updateOrderStatus(order.id, 'Delivered');
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.id} marked as delivered!'),
          backgroundColor: NexusTheme.emerald600,
        ),
      );
    }
  }

  void _showIssueDialog(BuildContext context, Order order, NexusProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cancel, color: NexusTheme.rose600),
              title: const Text('Customer Rejected'),
              onTap: () {
                Navigator.pop(context);
                provider.updateOrderStatus(order.id, 'Rejected');
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: NexusTheme.amber600),
              title: const Text('Partial Delivery'),
              onTap: () {
                Navigator.pop(context);
                provider.updateOrderStatus(order.id, 'Partially Delivered');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}
