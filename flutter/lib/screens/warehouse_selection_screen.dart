import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import '../widgets/nexus_components.dart';

class WarehouseSelectionScreen extends StatelessWidget {
  const WarehouseSelectionScreen({super.key});

  static const warehouses = [
    'IOPL Kurla',
    'IOPL DP WORLD',
    'IOPL Arihant Delhi',
    'IOPL Jolly Bng',
    'IOPL Hyderabad',
    'IOPL Chennai'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final pendingOrders = provider.orders.where((o) => o.status == 'Pending WH Selection').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('2.5 WAREHOUSE ASSIGNMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return pendingOrders.isEmpty
              ? NexusComponents.emptyState(icon: Icons.warehouse_outlined, title: 'All Assigned!', subtitle: 'No orders pending warehouse assignment')
              : ListView.builder(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  itemCount: pendingOrders.length,
                  itemBuilder: (context, index) => _OrderCard(order: pendingOrders[index], provider: provider, isMobile: isMobile),
                );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final NexusProvider provider;
  final bool isMobile;
  const _OrderCard({required this.order, required this.provider, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
                      const SizedBox(height: 4),
                      Text(order.customerName, style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                NexusComponents.statusBadge('ASSIGN WH'),
              ],
            ),
            const Divider(height: 24),
            Text('SELECT WAREHOUSE', style: TextStyle(fontSize: isMobile ? 9 : 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
            const SizedBox(height: 12),
            Wrap(
              spacing: isMobile ? 6 : 8,
              runSpacing: isMobile ? 6 : 8,
              children: WarehouseSelectionScreen.warehouses.map((wh) {
                return ChoiceChip(
                  label: Text(wh),
                  selected: false,
                  onSelected: (selected) async {
                    if (selected) {
                      final success = await provider.updateOrderStatus(order.id, 'Warehouse Assigned');
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order ${order.id} assigned to $wh'), backgroundColor: NexusTheme.emerald600));
                      }
                    }
                  },
                  selectedColor: NexusTheme.emerald500,
                  backgroundColor: NexusTheme.slate100,
                  labelStyle: TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.bold),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
