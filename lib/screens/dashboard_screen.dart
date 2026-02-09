import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../widgets/nexus_components.dart';
import 'order_archive_screen.dart';
import 'book_order_screen.dart';
import 'procurement_screen.dart';
import 'master_data_screen.dart';
import 'warehouse_selection_screen.dart';
import 'credit_control_screen.dart';
import 'invoicing_screen.dart';
import 'logistics_hub_screen.dart';
import 'delivery_execution_screen.dart';
import 'new_customer_screen.dart';
import 'stock_transfer_screen.dart';
import 'logistics_cost_screen.dart';
import 'warehouse_inventory_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final user = provider.currentUser;

    final liveCount = provider.orders.where((o) => o.status != 'Delivered' && o.status != 'Rejected').length;
    final pendingCount = provider.orders.where((o) => o.status.contains('Pending')).length;
    final totalRevenue = provider.orders.fold(0.0, (sum, o) => sum + o.total);

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: NexusTheme.emerald500),
            SizedBox(width: 8),
            Text('NEXUS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            Text('OMS', style: TextStyle(color: NexusTheme.emerald500, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ],
        ),
        actions: [
          IconButton(onPressed: () => provider.logout(), icon: const Icon(Icons.logout, color: Colors.grey)),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(user?.name ?? 'User'),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                NexusComponents.statCard(label: 'LIVE MISSIONS', value: '$liveCount', icon: Icons.radar, color: NexusTheme.emerald500, trend: '+12%'),
                NexusComponents.statCard(label: 'PENDING OPS', value: '$pendingCount', icon: Icons.timer_outlined, color: Colors.orange),
                NexusComponents.statCard(label: 'SCM SCORE', value: '110.0', icon: Icons.analytics_outlined, color: Colors.blue),
                NexusComponents.statCard(label: 'MTD REVENUE', value: '₹${(totalRevenue/1000).toStringAsFixed(1)}K', icon: Icons.payments_outlined, color: Colors.purple),
              ],
            ),
            const SizedBox(height: 32),
            const _SectionTitle(title: 'SUPPLY CHAIN LIFECYCLE'),
            const SizedBox(height: 16),
            _buildActionGrid(context),
            const SizedBox(height: 32),
            const _SectionTitle(title: 'ENTERPRISE TERMINALS'),
            const SizedBox(height: 16),
            _buildUtilityGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Welcome back,', style: TextStyle(fontSize: 14, color: NexusTheme.slate400, fontWeight: FontWeight.w600)),
        Text(name.toUpperCase(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: NexusTheme.emerald500.withValues(alpha:0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: NexusTheme.emerald500.withValues(alpha: 0.2))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: NexusTheme.emerald500, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('ACTIVE CLOUD PROTOCOL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.emerald700, letterSpacing: 0.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      {'label': '0. NEW CUSTOMER', 'icon': Icons.person_add_outlined, 'color': Colors.indigo, 'screen': const NewCustomerScreen()},
      {'label': '1. BOOK ORDER', 'icon': Icons.add_shopping_cart, 'color': NexusTheme.emerald700, 'screen': const BookOrderScreen()},
      {'label': '1.1 STOCK TRANSFER', 'icon': Icons.sync_alt, 'color': NexusTheme.slate600, 'screen': const StockTransferScreen()},
      {'label': '2. CREDIT CONTROL', 'icon': Icons.bolt, 'color': Colors.orange, 'screen': const CreditControlScreen()},
      {'label': '2.5 WH ASSIGN', 'icon': Icons.home_work_outlined, 'color': Colors.teal, 'screen': const WarehouseSelectionScreen()},
      {'label': '3. WAREHOUSE', 'icon': Icons.inventory_2_outlined, 'color': Colors.blueGrey, 'screen': const WarehouseInventoryScreen()},
      {'label': '4. LOGISTICS COST', 'icon': Icons.currency_rupee, 'color': Colors.deepPurple, 'screen': const LogisticsCostScreen()},
      {'label': '5. INVOICING', 'icon': Icons.receipt_long, 'color': Colors.blue, 'screen': const InvoicingScreen()},
      {'label': '6. LOGISTICS HUB', 'icon': Icons.explore_outlined, 'color': Colors.purple, 'screen': const LogisticsHubScreen()},
      {'label': '7. EXECUTION', 'icon': Icons.local_shipping_outlined, 'color': Colors.redAccent, 'screen': const DeliveryExecutionScreen()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.25),
      itemCount: actions.length,
      itemBuilder: (context, i) => _ActionCard(
        label: actions[i]['label'] as String,
        icon: actions[i]['icon'] as IconData,
        color: actions[i]['color'] as Color,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => actions[i]['screen'] as Widget)),
      ),
    );
  }

  Widget _buildUtilityGrid(BuildContext context) {
    final utilities = [
      {'l': 'Procurement', 'i': Icons.shopping_bag_outlined, 's': const ProcurementScreen()},
      {'l': 'Intelligence', 'i': Icons.insights, 's': const AnalyticsScreen()},
      {'l': 'Order Archive', 'i': Icons.history, 's': const OrderArchiveScreen()},
      {'l': 'Master Data', 'i': Icons.terminal, 's': const MasterDataScreen()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.8),
      itemCount: utilities.length,
      itemBuilder: (context, i) => InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => utilities[i]['s'] as Widget)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: NexusTheme.slate900, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: NexusTheme.slate900.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Row(
            children: [
              Icon(utilities[i]['i'] as IconData, color: NexusTheme.emerald400, size: 18),
              const SizedBox(width: 10),
              Text((utilities[i]['l'] as String).toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 2));
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: NexusTheme.slate200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.05), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate800, letterSpacing: -0.2)),
          ],
        ),
      ),
    );
  }
}
