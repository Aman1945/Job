import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
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
import 'live_orders_screen.dart';
import 'sales_hub_screen.dart';
import 'reporting_screen.dart';
import 'pms_screen.dart';
import 'add_product_screen.dart';
import 'live_missions_screen.dart';
import 'executive_pulse_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // USE AUTH PROVIDER FOR USER DATA
    final auth = Provider.of<AuthProvider>(context);
    final nexusProvider = Provider.of<NexusProvider>(context);
    
    final user = auth.currentUser;

    final liveCount = nexusProvider.orders.where((o) => o.status != 'Delivered' && o.status != 'Rejected').length;
    final pendingCount = nexusProvider.orders.where((o) => o.status.contains('Pending')).length;
    final totalRevenue = nexusProvider.orders.fold(0.0, (sum, o) => sum + o.total);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog(context);
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
            IconButton(
              onPressed: () => auth.logout(), 
              icon: const Icon(Icons.logout, color: Colors.grey),
              tooltip: 'Logout',
            ),
            IconButton(
              onPressed: () async {
                final result = await _showExitDialog(context);
                if (result) SystemNavigator.pop();
              }, 
              icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              tooltip: 'Exit App',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isMobile = width < 600;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(user?.name ?? 'User'),
                  const SizedBox(height: 32),
                  
                  // Stats Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMissionsScreen())),
                        child: NexusComponents.statCard(label: 'LIVE MISSIONS', value: '$liveCount', icon: Icons.radar, color: NexusTheme.emerald500, trend: '+12%'),
                      ),
                      NexusComponents.statCard(label: 'PENDING OPS', value: '$pendingCount', icon: Icons.timer_outlined, color: Colors.orange),
                      NexusComponents.statCard(label: 'SCM SCORE', value: '110.0', icon: Icons.analytics_outlined, color: Colors.blue),
                      NexusComponents.statCard(label: 'MTD REVENUE', value: '₹${(totalRevenue/1000).toStringAsFixed(1)}K', icon: Icons.payments_outlined, color: Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  const _SectionTitle(title: 'SUPPLY CHAIN LIFECYCLE'),
                  const SizedBox(height: 16),
                  
                  _buildActionList(context, isMobile),
                  
                  const SizedBox(height: 32),
                  _buildUtilityGrid(context, isMobile, user?.role.toString()),
                ],
              ),
            );
          },
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
          decoration: BoxDecoration(color: NexusTheme.emerald500.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: NexusTheme.emerald500.withOpacity(0.2))),
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

  Widget _buildActionList(BuildContext context, bool isMobile) {
    final actions = [
      {'label': '1. LIVE MISSIONS', 'icon': Icons.radar, 'color': NexusTheme.indigo600, 'screen': const LiveMissionsScreen()},
      {'label': '1. BOOK ORDER', 'icon': Icons.add_shopping_cart, 'color': NexusTheme.emerald700, 'screen': const BookOrderScreen()},
      {'label': '2. CREDIT CONTROL', 'icon': Icons.bolt, 'color': Colors.orange, 'screen': const CreditControlScreen()},
      {'label': '3. WAREHOUSE', 'icon': Icons.inventory_2_outlined, 'color': Colors.blueGrey, 'screen': const WarehouseInventoryScreen()},
      {'label': '5. INVOICING', 'icon': Icons.receipt_long, 'color': Colors.blue, 'screen': const InvoicingScreen()},
      {'label': '6. LOGISTICS HUB', 'icon': Icons.explore_outlined, 'color': Colors.purple, 'screen': const LogisticsHubScreen()},
    ];

    return Column(
      children: actions.map((action) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ActionCard(
          label: action['label'] as String,
          icon: action['icon'] as IconData,
          color: action['color'] as Color,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => action['screen'] as Widget)),
          isMobile: isMobile,
        ),
      )).toList(),
    );
  }

  Widget _buildUtilityGrid(BuildContext context, bool isMobile, String? role) {
    final utilities = [
      {'l': 'PMS Performance', 'i': Icons.emoji_events, 's': const PMSScreen()},
      {'l': 'Intelligence', 'i': Icons.insights, 's': const AnalyticsScreen()},
      {'l': 'Reporting', 'i': Icons.assessment, 's': const ReportingScreen()},
      {'l': 'Master Data', 'i': Icons.terminal, 's': const MasterDataScreen()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: utilities.length,
      itemBuilder: (context, i) => InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => utilities[i]['s'] as Widget)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: NexusTheme.slate900, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Icon(utilities[i]['i'] as IconData, color: NexusTheme.emerald400, size: 16),
              const SizedBox(width: 8),
              Flexible(child: Text((utilities[i]['l'] as String).toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white))),
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
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1.5));
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isMobile;
  const _ActionCard({required this.label, required this.icon, required this.color, required this.onTap, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16), 
          border: Border.all(color: NexusTheme.slate200), 
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate800))),
            const Icon(Icons.arrow_forward_ios, size: 12, color: NexusTheme.slate300),
          ],
        ),
      ),
    );
  }
}

Future<bool> _showExitDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Exit App', style: TextStyle(fontWeight: FontWeight.w900)),
      content: const Text('Are you sure you want to exit?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('EXIT', style: TextStyle(color: Colors.red))),
      ],
    ),
  ) ?? false;
}
