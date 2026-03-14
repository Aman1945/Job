import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../widgets/nexus_components.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class WarehouseSelectionScreen extends StatefulWidget {
  const WarehouseSelectionScreen({super.key});

  @override
  State<WarehouseSelectionScreen> createState() => _WarehouseSelectionScreenState();
}

class _WarehouseSelectionScreenState extends State<WarehouseSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final orders = provider.orders.where((o) => o.status == 'Pending WH Selection').toList();
    final warehouses = provider.warehouses;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark background matching screenshots
      appBar: AppBar(
        title: const Text('Warehouse Selection', 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white, fontFamily: 'Montserrat')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          
          // --- WAREHOUSE STATUS CARDS (HORIZONTAL) ---
          const SizedBox(height: 16),
          _buildWarehouseScroll(warehouses),
          
          const SizedBox(height: 24),
          
          // --- ORDERS LIST ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
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

  Widget _buildWarehouseScroll(List<Warehouse> warehouses) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: warehouses.isNotEmpty ? warehouses.length : 2, // Fallback for preview
        itemBuilder: (context, index) {
          if (warehouses.isEmpty) {
            // Mock data if empty
            return _buildWarehouseCard(
              Warehouse(
                id: 'W1', name: index == 0 ? 'Kurla Cold Storage' : 'DP World Nhava Sheva',
                location: index == 0 ? 'Mumbai' : 'Navi Mumbai',
                tempRange: index == 0 ? '-18°C to 4°C' : '-22°C to -18°C',
                capacityUsed: index == 0 ? 38 : 52,
                capacityMax: index == 0 ? 50 : 80,
                manager: index == 0 ? 'Deepak More' : 'Sanjay Bhat'
              )
            );
          }
          return _buildWarehouseCard(warehouses[index]);
        },
      ),
    );
  }

  Widget _buildWarehouseCard(Warehouse wh) {
    final progress = wh.capacityUsed / wh.capacityMax;
    final color = progress > 0.8 ? Colors.orangeAccent : const Color(0xFF1ABFA1);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.factory, color: Colors.orangeAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(wh.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white))),
            ],
          ),
          const SizedBox(height: 4),
          Text('${wh.location} • ${wh.tempRange}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Capacity', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('${wh.capacityUsed.toInt()} Ton / ${wh.capacityMax.toInt()} Ton', 
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              color: color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Text('Manager: ${wh.manager}', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTerminalCard(Order order, List<Warehouse> warehouses) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.id, style: const TextStyle(color: Color(0xFF1ABFA1), fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(order.customerName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('${order.items.length} items • ₹${NumberFormat('#,###').format(order.total)}', 
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.clock, color: Colors.blueAccent, size: 14),
                    SizedBox(width: 8),
                    Text('Pending WH Selection', style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('SELECT WAREHOUSE', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: (warehouses.isNotEmpty ? warehouses : [
              Warehouse(id: 'WH001', name: 'Kurla Cold Storage', location: 'Mumbai', tempRange: '-18°C', capacityUsed: 38, capacityMax: 50, manager: ''),
              Warehouse(id: 'WH002', name: 'DP World Nhava Sheva', location: 'Navi Mumbai', tempRange: '-22°C', capacityUsed: 52, capacityMax: 80, manager: ''),
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
          color: const Color(0xFF1ABFA1).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1ABFA1).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.factory, color: Color(0xFF1ABFA1), size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wh.name, style: const TextStyle(color: Color(0xFF1ABFA1), fontSize: 11, fontWeight: FontWeight.w900)),
                  Text('${wh.capacityUsed.toInt()} Ton/${wh.capacityMax.toInt()} Ton', 
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w600)),
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
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order ${order.id} assigned to ${wh.name} via FIFO'),
        backgroundColor: const Color(0xFF1ABFA1),
        behavior: SnackBarBehavior.floating,
      ));
      setState(() {});
    }
  }
}
