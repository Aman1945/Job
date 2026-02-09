import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class StockTransferScreen extends StatelessWidget {
  const StockTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final stnOrders = provider.orders.where((o) => o.isSTN == true).toList();

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('1.1 STOCK TRANSFER (STN)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
      ),
      body: Column(
        children: [
          _buildSTNHeader(stnOrders.length),
          Expanded(
            child: stnOrders.isEmpty
                ? _buildEmptySTN()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: stnOrders.length,
                    itemBuilder: (context, index) {
                      final order = stnOrders[index];
                      return _buildSTNCard(order);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: NexusTheme.slate900,
        icon: const Icon(Icons.add_road, color: NexusTheme.emerald400),
        label: const Text('INITIALIZE NEW STN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
      ),
    );
  }

  Widget _buildSTNHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: NexusTheme.slate200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_alt, color: NexusTheme.indigo600),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('INTER-DEPOT MOVEMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text('$count ACTIVE TRANSFERS IN PROGRESS', style: const TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySTN() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_outlined, size: 80, color: NexusTheme.slate300),
          SizedBox(height: 16),
          Text('Inventory Balanced', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
          Text('No inter-depot transfers active', style: TextStyle(color: NexusTheme.slate400)),
        ],
      ),
    );
  }

  Widget _buildSTNCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: NexusTheme.indigo50,
          child: const Icon(Icons.warehouse, color: NexusTheme.indigo600, size: 20),
        ),
        title: Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.indigo600)),
        subtitle: Text('To: ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: NexusTheme.emerald100, borderRadius: BorderRadius.circular(8)),
          child: const Text('IN TRANSIT', style: TextStyle(color: NexusTheme.emerald900, fontWeight: FontWeight.w900, fontSize: 9)),
        ),
      ),
    );
  }
}
