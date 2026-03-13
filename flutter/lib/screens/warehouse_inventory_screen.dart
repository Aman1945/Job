import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';

class WarehouseInventoryScreen extends StatefulWidget {
  const WarehouseInventoryScreen({super.key});

  @override
  State<WarehouseInventoryScreen> createState() => _WarehouseInventoryScreenState();
}

class _WarehouseInventoryScreenState extends State<WarehouseInventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final nexusProvider = Provider.of<NexusProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NexusTheme.blue50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_rounded, color: NexusTheme.blue600, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inventory Hub', style: TextStyle(color: NexusTheme.slate900, fontSize: 18, fontWeight: FontWeight.w900)),
                Text('SUPPLY CHAIN MGMT', style: TextStyle(color: NexusTheme.slate400, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded, color: NexusTheme.slate700), onPressed: () {}),
          IconButton(icon: const Icon(Icons.tune_rounded, color: NexusTheme.slate700), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Global Supply Chain Status (System Hub same style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: NexusTheme.slate900,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: NexusTheme.slate900.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GLOBAL SUPPLY CHAIN STATUS',
                    style: TextStyle(color: NexusTheme.slate400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Operational',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                      const Icon(Icons.insights_rounded, color: NexusTheme.blue600, size: 32),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusMetric('SCM Uptime', '99.99%', Colors.white),
                      _buildStatusMetric('Node Latency', '18ms', Colors.white),
                      _buildStatusMetric('Active Hubs', '04', Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // SCM Technical Timeline (Full 1-10 Steps)
            const Text(
              'SUPPLY CHAIN TECHNICAL TIMELINE',
              style: TextStyle(color: NexusTheme.slate900, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: NexusTheme.slate100, width: 1.5),
              ),
              child: Column(
                children: [
                  _buildTimelineStep(1, 'Order Initialization', 'System handoff & ID generation', true),
                  _buildTimelineStep(2, 'Customer Compliance', 'Credit and validation check', true),
                  _buildTimelineStep(3, 'Logistics Planning', 'Route optimization & node selection', true),
                  _buildTimelineStep(4, 'Inventory Reservation', 'Stock allocation at JED-04', true),
                  _buildTimelineStep(5, 'Quality Engineering', 'Post-picking technical audit', true, isCurrent: true),
                  _buildTimelineStep(6, 'Smart Packaging', 'Dimensional weight optimization', false),
                  _buildTimelineStep(7, 'Manifest Generation', 'Digital invoicing & documentation', false),
                  _buildTimelineStep(8, 'Global Dispatch', 'Carrier handoff & tracking start', false),
                  _buildTimelineStep(9, 'Last-Mile Sync', 'Final delivery node activation', false),
                  _buildTimelineStep(10, 'Reverse Logistics', 'Return flow & circular SCM', false, isLast: true),
                ],
              ),
            ),
            
            const SizedBox(height: 48),

            // Executive Utilities Grid (Same as System Hub)
            const Text(
              'EXECUTIVE UTILITIES',
              style: TextStyle(color: NexusTheme.slate900, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.15,
              children: [
                _buildUtilityCard(Icons.insert_chart_outlined_rounded, 'Executive Pulse', 'Real-time KPI flow'),
                _buildUtilityCard(Icons.compare_arrows_rounded, 'Stock Transfer', 'Internal movements'),
                _buildUtilityCard(Icons.assignment_outlined, 'SKU Master', 'Catalog management'),
                _buildUtilityCard(Icons.verified_outlined, 'Safety Audit', 'Compliance checks'),
                _buildUtilityCard(Icons.location_on_outlined, 'Zone Mapping', 'Hub layout control'),
                _buildUtilityCard(Icons.sync_alt_rounded, 'Supplier Sync', 'External API bridge'),
              ],
            ),
            
            const SizedBox(height: 48),

            // Storage Distribution
            const Text(
              'STORAGE NODES DISTRIBUTION',
              style: TextStyle(color: NexusTheme.slate900, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: NexusTheme.slate50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: NexusTheme.slate100),
              ),
              child: Column(
                children: [
                  _buildStorageNode('Central Hub Alpha', 0.85, '85%'),
                  const SizedBox(height: 20),
                  _buildStorageNode('Regional Node Beta', 0.42, '42%'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: NexusTheme.slate500, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildTimelineStep(int step, String title, String subtitle, bool isDone, {bool isCurrent = false, bool isLast = false}) {
    Color pointColor = isDone ? NexusTheme.success : (isCurrent ? NexusTheme.blue600 : NexusTheme.slate200);
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: pointColor.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: pointColor, width: 1.5)),
          child: Center(child: isDone ? const Icon(Icons.check, size: 10, color: NexusTheme.success) : Text('$step', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: pointColor))),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isCurrent || isDone ? NexusTheme.slate900 : NexusTheme.slate400)),
        ]),
        const Spacer(),
        if (isCurrent) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: NexusTheme.blue50, borderRadius: BorderRadius.circular(4)), child: const Text('ACTIVE', style: TextStyle(color: NexusTheme.blue600, fontSize: 8, fontWeight: FontWeight.w900))),
      ],
    );
  }

  Widget _buildUtilityCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NexusTheme.slate100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NexusTheme.blue50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: NexusTheme.blue600, size: 20),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: NexusTheme.slate500, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStorageNode(String name, double percent, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: NexusTheme.slate800)),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: NexusTheme.blue600)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: NexusTheme.slate200,
            valueColor: const AlwaysStoppedAnimation<Color>(NexusTheme.blue600),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
