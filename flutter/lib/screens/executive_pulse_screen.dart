import 'package:flutter/material.dart';
import 'package:nexus_oms_mobile/models/models.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';

class ExecutivePulseScreen extends StatelessWidget {
  const ExecutivePulseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final allOrders = provider.orders;
    
    // Flatten all status histories into a single list of activities
    List<Map<String, dynamic>> activities = [];
    for (var order in allOrders) {
      if (order.statusHistory != null) {
        for (var history in order.statusHistory!) {
          activities.add({
            'orderId': order.id,
            'customer': order.customerName,
            'status': history['status'],
            'timestamp': DateTime.parse(history['timestamp'] ?? DateTime.now().toIso8601String()),
            'isSTN': order.isSTN ?? false,
          });
        }
      } else {
        // Fallback to order creation date if no history
        activities.add({
          'orderId': order.id,
          'customer': order.customerName,
          'status': order.status,
          'timestamp': order.createdAt,
          'isSTN': order.isSTN ?? false,
        });
      }
    }
    
    // Sort by most recent
    activities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('EXECUTIVE PULSE COMMAND', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsHeader(allOrders),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Text('REAL-TIME FIELD ACTIVITY', style: TextStyle(color: Color(0xFF6366F1), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
          Expanded(
            child: activities.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: activities.length,
                  itemBuilder: (context, index) => _buildActivityCard(activities[index]),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(List<Order> orders) {
    final liveMissions = orders.where((o) => o.status != 'Delivered' && o.status != 'Rejected').length;
    final stns = orders.where((o) => o.isSTN == true).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          _buildStatItem('LIVE MISSIONS', liveMissions.toString(), const Color(0xFF10B981)),
          Container(width: 1, height: 40, color: Colors.white12),
          _buildStatItem('STOCK TRANSFERS', stns.toString(), const Color(0xFF6366F1)),
          Container(width: 1, height: 40, color: Colors.white12),
          _buildStatItem('SYSTEM UPTIME', '99.9%', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final DateTime ts = activity['timestamp'];
    final String timeStr = DateFormat('HH:mm').format(ts);
    final bool isSTN = activity['isSTN'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSTN ? const Color(0xFF6366F1).withOpacity(0.1) : const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSTN ? Icons.sync_alt_rounded : Icons.shopping_cart_outlined,
              color: isSTN ? const Color(0xFF818CF8) : const Color(0xFF34D399),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(activity['orderId'], style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    Text(timeStr, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(activity['customer'].toString().toUpperCase(), 
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(activity['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activity['status'].toString().toUpperCase(),
                        style: TextStyle(color: _getStatusColor(activity['status']), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('Pending')) return Colors.orange;
    if (status.contains('Delivered')) return const Color(0xFF10B981);
    if (status.contains('Rejected')) return Colors.redAccent;
    return const Color(0xFF6366F1);
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, color: Colors.white10, size: 64),
          SizedBox(height: 16),
          Text('NO FIELD ACTIVITY DETECTED', style: TextStyle(color: Colors.white10, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
        ],
      ),
    );
  }
}
