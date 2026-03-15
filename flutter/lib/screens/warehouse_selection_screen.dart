import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class WarehouseSelectionScreen extends StatefulWidget {
  const WarehouseSelectionScreen({super.key});

  @override
  State<WarehouseSelectionScreen> createState() => _WarehouseSelectionScreenState();
}

class _WarehouseSelectionScreenState extends State<WarehouseSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NexusProvider>(context, listen: false);
      provider.fetchWarehouses();
      provider.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final orders = provider.orders.where((o) => o.status == 'Pending WH Selection').toList();
    final warehouses = provider.warehouses;

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('Warehouse Selection', 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: NexusTheme.slate900)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: NexusTheme.slate900),
        actions: [
          IconButton(icon: const Icon(LucideIcons.refreshCw), onPressed: () => provider.refreshData()),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('${orders.length} orders awaiting warehouse assignment', 
              style: const TextStyle(color: NexusTheme.slate500, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          
          // --- WAREHOUSE STATUS CARDS (HORIZONTAL) ---
          const SizedBox(height: 16),
          _buildWarehouseScroll(warehouses, orders),
          
          const SizedBox(height: 24),
          
          // --- ORDERS LIST ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: orders.length,
                  itemBuilder: (context, index) => _buildTerminalCard(orders[index], warehouses),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseScroll(List<Warehouse> warehouses, List<Order> orders) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: warehouses.isNotEmpty ? warehouses.length : 4, // Fallback for preview
        itemBuilder: (context, index) {
          if (warehouses.isEmpty) {
            // Mock data if empty
            final mockNames = ['Kurla Cold Storage', 'DP World Nhava Sheva', 'Arihant Delhi', 'Jolly BNG'];
            final mockLocs = ['Mumbai', 'Navi Mumbai', 'Delhi', 'Bangalore'];
            final mockTemps = ['-18°C to 4°C', '-22°C to -18°C', '-19°C to -5°C', '-18°C to -4°C'];
            
            return _buildWarehouseCard(
              Warehouse(
                id: 'W${index + 1}', 
                name: mockNames[index],
                location: mockLocs[index],
                tempRange: mockTemps[index],
                capacityUsed: index == 0 ? 38.0 : index == 1 ? 52.0 : index == 2 ? 15.0 : 22.0,
                capacityMax: index == 0 ? 50.0 : index == 1 ? 80.0 : index == 2 ? 60.0 : 45.0,
                manager: index == 0 ? 'Deepak More' : index == 1 ? 'Sanjay Bhat' : index == 2 ? 'Amit Kumar' : 'Rajesh Reddy'
              ),
              orders.isNotEmpty ? orders.first : null
            );
          }
          return _buildWarehouseCard(warehouses[index], orders.isNotEmpty ? orders.first : null);
        },
      ),
    );
  }

  Widget _buildWarehouseCard(Warehouse wh, Order? pendingOrder) {
    final progress = wh.capacityUsed / wh.capacityMax;
    final color = progress > 0.8 ? NexusTheme.rose600 : NexusTheme.emerald500;

    return InkWell(
      onTap: pendingOrder != null ? () {
        debugPrint('Tapped Warehouse: ${wh.name} for Order: ${pendingOrder.id}');
        _assignFacility(pendingOrder, wh);
      } : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: NexusTheme.slate200),
          boxShadow: [
            BoxShadow(color: NexusTheme.slate900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.factory, color: NexusTheme.emerald600, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(wh.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: NexusTheme.slate900))),
              ],
            ),
            const SizedBox(height: 4),
            Text('${wh.location} • ${wh.tempRange}', style: const TextStyle(color: NexusTheme.slate500, fontSize: 11, fontWeight: FontWeight.w600)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Capacity', style: TextStyle(color: NexusTheme.slate400, fontSize: 11, fontWeight: FontWeight.bold)),
                Text('${wh.capacityUsed.toInt()} Ton / ${wh.capacityMax.toInt()} Ton', 
                  style: TextStyle(color: NexusTheme.slate900, fontSize: 11, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: NexusTheme.slate100,
                color: color,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Text('Manager: ${wh.manager}', style: const TextStyle(color: NexusTheme.slate400, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalCard(Order order, List<Warehouse> warehouses) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [
          BoxShadow(color: NexusTheme.slate900.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.id, style: TextStyle(color: NexusTheme.emerald600, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(order.customerName, 
                      style: TextStyle(color: NexusTheme.slate900, fontSize: 18, fontWeight: FontWeight.w900, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('${order.items.length} items • ₹${NumberFormat('#,###').format(order.total)}', 
                      style: TextStyle(color: NexusTheme.slate500, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.clock, size: 12, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(order.status.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: Colors.blueAccent)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('SELECT WAREHOUSE', style: TextStyle(color: NexusTheme.slate400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: (warehouses.isNotEmpty ? warehouses : [
              Warehouse(id: 'W1', name: 'Kurla Cold Storage', location: 'Mumbai', tempRange: '-18°C', capacityUsed: 38, capacityMax: 50, manager: ''),
              Warehouse(id: 'W2', name: 'DP World Nhava Sheva', location: 'Navi Mumbai', tempRange: '-22°C', capacityUsed: 52, capacityMax: 80, manager: ''),
              Warehouse(id: 'W3', name: 'Arihant Delhi', location: 'Delhi', tempRange: '-19°C', capacityUsed: 15, capacityMax: 60, manager: ''),
              Warehouse(id: 'W4', name: 'Jolly BNG', location: 'Bangalore', tempRange: '-18°C', capacityUsed: 22, capacityMax: 45, manager: ''),
            ]).map((wh) => _buildSelectionButton(order, wh)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton(Order order, Warehouse wh) {
    return InkWell(
      onTap: () => _assignFacility(order, wh),
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: NexusTheme.emerald50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NexusTheme.emerald200),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.factory, color: Color(0xFF1ABFA1), size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wh.name, style: const TextStyle(color: NexusTheme.emerald700, fontSize: 11, fontWeight: FontWeight.w900)),
                  Text('${wh.capacityUsed.toInt()} Ton/${wh.capacityMax.toInt()} Ton', 
                    style: const TextStyle(color: NexusTheme.slate500, fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignFacility(Order order, Warehouse wh) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // Call the dedicated assignment API which handles FIFO batch allocation
    final success = await provider.assignWarehouseToOrder(order.id, wh.id, token: auth.token); 
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Order ${order.id} assigned to ${wh.name} via FIFO'),
          backgroundColor: NexusTheme.emerald600,
          behavior: SnackBarBehavior.floating,
        ));
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Assignment Failed: Check warehouse stock or connection.'),
          backgroundColor: NexusTheme.rose600,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}
