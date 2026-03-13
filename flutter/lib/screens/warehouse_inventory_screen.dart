import 'package:flutter/material.dart';
import '../utils/theme.dart';

class WarehouseInventoryScreen extends StatefulWidget {
  const WarehouseInventoryScreen({super.key});

  @override
  State<WarehouseInventoryScreen> createState() => _WarehouseInventoryScreenState();
}

class _WarehouseInventoryScreenState extends State<WarehouseInventoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: NexusTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nexus OMS', style: TextStyle(color: NexusTheme.slate900, fontSize: 18, fontWeight: FontWeight.w900)),
                Text('INVENTORY CONTROL', style: TextStyle(color: NexusTheme.slate400, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: NexusTheme.slate600), onPressed: () {}),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_none_rounded, color: NexusTheme.slate600), onPressed: () {}),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFF43F5E), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=nexus_admin'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Metrics
            _buildMetricCard(
              'Total SKUs',
              '12,480',
              '+2.4%',
              NexusTheme.primaryBlue,
              Icons.inventory_2_outlined,
              isTrendPositive: true,
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              'Low Stock Alerts',
              '142',
              'Urgent',
              const Color(0xFFF59E0B),
              Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              'Pending Transfers',
              '28',
              'Real-time',
              const Color(0xFF8B5CF6),
              Icons.swap_horiz_rounded,
            ),
            
            const SizedBox(height: 40),
            
            // System Utilities Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.settings_suggest_outlined, color: NexusTheme.primaryBlue, size: 24),
                    const SizedBox(width: 12),
                    const Text('System Utilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.5)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All', style: TextStyle(color: NexusTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Utilities Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildUtilityCard('Stock Transfer', 'INTERNAL MOVEMENTS', Icons.compare_arrows_rounded),
                _buildUtilityCard('SKU Master', 'CATALOG MANAGEMENT', Icons.assignment_outlined),
                _buildUtilityCard('Inventory Audit', 'COMPLIANCE CHECK', Icons.verified_outlined),
                _buildUtilityCard('Zone Mapping', 'WAREHOUSE LAYOUT', Icons.location_on_outlined),
                _buildUtilityCard('Batch Tracking', 'LOT MANAGEMENT', Icons.qr_code_scanner_rounded),
                _buildUtilityCard('Supplier Sync', 'EXTERNAL APIS', Icons.sync_alt_rounded),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Storage Distribution
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 40, offset: const Offset(0, 20))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('STORAGE DISTRIBUTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1.5)),
                  const SizedBox(height: 32),
                  _buildStorageBar('Warehouse Alpha (NY)', 0.85, '85% Capacity'),
                  const SizedBox(height: 24),
                  _buildStorageBar('Warehouse Bravo (CA)', 0.42, '42% Capacity'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Recent System Logs
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 40, offset: const Offset(0, 20))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RECENT SYSTEM LOGS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1.5)),
                  const SizedBox(height: 32),
                  _buildSystemLog(
                    'SKU-402 Price Updated',
                    '2 minutes ago by Administrator',
                    'LOG-9921',
                    const Color(0xFFEFF6FF),
                    NexusTheme.primaryBlue,
                    Icons.edit_outlined,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  _buildSystemLog(
                    'Low Stock Trigger: Item #881',
                    '14 minutes ago via Automation',
                    'LOG-9918',
                    const Color(0xFFFFF7ED),
                    const Color(0xFFF59E0B),
                    Icons.bolt_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String tag, Color color, IconData icon, {bool isTrendPositive = false}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: NexusTheme.slate400, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(color: NexusTheme.slate900, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isTrendPositive ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isTrendPositive) const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isTrendPositive ? const Color(0xFF10B981) : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: NexusTheme.slate700, size: 28),
          ),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: NexusTheme.slate900, letterSpacing: -0.3)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: NexusTheme.slate400, letterSpacing: 0.8)),
        ],
      ),
    );
  }

  Widget _buildStorageBar(String label, double value, String percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: NexusTheme.slate700)),
            Text(percentage, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: NexusTheme.primaryBlue)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [NexusTheme.primaryBlue, Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemLog(String title, String meta, String id, Color bgColor, Color iconColor, IconData icon) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.2)),
              const SizedBox(height: 4),
              Text(meta, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: NexusTheme.slate400)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Text(id, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)),
        ),
      ],
    );
  }
}
