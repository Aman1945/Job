import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus_oms_mobile/models/models.dart';
import 'package:nexus_oms_mobile/screens/live_missions_screen.dart';
import 'package:nexus_oms_mobile/screens/executive_pulse_screen.dart';
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
import 'live_orders_screen.dart';
import 'sales_hub_screen.dart';
import 'reporting_screen.dart';
import 'pms_screen.dart';
import 'add_product_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final user = provider.currentUser;

    final liveCount = provider.orders.where((o) => o.status != 'Delivered' && o.status != 'Rejected').length;
    final pendingCount = provider.orders.where((o) => o.status.contains('Pending')).length;
    final totalRevenue = provider.orders.fold(0.0, (sum, o) => sum + o.total);

    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context);
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
              onPressed: () => provider.logout(), 
              icon: const Icon(Icons.logout, color: Colors.grey),
              tooltip: 'Logout',
            ),
            IconButton(
              onPressed: () => _showExitDialog(context), 
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
                
                // Stats Cards - Always 2x2 Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: isMobile ? 12 : 16,
                  crossAxisSpacing: isMobile ? 12 : 16,
                  childAspectRatio: isMobile ? 1.3 : 1.4,
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
                
                // Action Cards - In Rows
                _buildActionList(context, isMobile),
                
                const SizedBox(height: 32),
                // Utility Cards - 2 Rows (2 cards per row)
                _buildUtilityGrid(context, isMobile, user?.role),
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
      {'label': '0. EXECUTIVE PULSE', 'icon': Icons.query_stats, 'color': NexusTheme.emerald600, 'screen': const ExecutivePulseScreen()},
      {'label': '1. LIVE MISSIONS', 'icon': Icons.radar, 'color': NexusTheme.indigo600, 'screen': const LiveMissionsScreen()},
      {'label': '1.1 ORDER ARCHIVE', 'icon': Icons.history, 'color': NexusTheme.blue600, 'screen': const OrderArchiveScreen()},
      {'label': '0. NEW CUSTOMER', 'icon': Icons.person_add_outlined, 'color': Colors.indigo, 'screen': const NewCustomerScreen()},
      {'label': '0.5 CREATE SKU MASTER', 'icon': Icons.post_add_rounded, 'color': NexusTheme.amber500, 'screen': const AddProductScreen()},
      {'label': '1. BOOK ORDER', 'icon': Icons.add_shopping_cart, 'color': NexusTheme.emerald700, 'screen': const BookOrderScreen()},
      {'label': '1.2 STOCK TRANSFER', 'icon': Icons.sync_alt, 'color': NexusTheme.slate600, 'screen': const StockTransferScreen()},
      {'label': '1.5 LIVE ORDERS', 'icon': Icons.pending_actions, 'color': Colors.cyan, 'screen': const LiveOrdersScreen()},
      {'label': '2. CREDIT CONTROL', 'icon': Icons.bolt, 'color': Colors.orange, 'screen': const CreditControlScreen()},
      {'label': '2.5 WH ASSIGN', 'icon': Icons.home_work_outlined, 'color': Colors.teal, 'screen': const WarehouseSelectionScreen()},
      {'label': '3. WAREHOUSE', 'icon': Icons.inventory_2_outlined, 'color': Colors.blueGrey, 'screen': const WarehouseInventoryScreen()},
      {'label': '4. LOGISTICS COST', 'icon': Icons.currency_rupee, 'color': Colors.deepPurple, 'screen': const LogisticsCostScreen()},
      {'label': '5. INVOICING', 'icon': Icons.receipt_long, 'color': Colors.blue, 'screen': const InvoicingScreen()},
      {'label': '6. LOGISTICS HUB', 'icon': Icons.explore_outlined, 'color': Colors.purple, 'screen': const LogisticsHubScreen()},
      {'label': '7. EXECUTION', 'icon': Icons.local_shipping_outlined, 'color': Colors.redAccent, 'screen': const DeliveryExecutionScreen()},
    ];

    return Column(
      children: actions.map((action) => Padding(
        padding: EdgeInsets.only(bottom: isMobile ? 10 : 12),
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

  Widget _buildUtilityGrid(BuildContext context, bool isMobile, UserRole? role) {
    final utilities = [
      {'l': 'Procurement', 'i': Icons.shopping_bag_outlined, 's': const ProcurementScreen()},
      {'l': 'Intelligence', 'i': Icons.insights, 's': const AnalyticsScreen()},
      {'l': 'Order Archive', 'i': Icons.history, 's': const OrderArchiveScreen()},
      {'l': 'Master Data', 'i': Icons.terminal, 's': const MasterDataScreen()},
      {'l': 'Sales Hub', 'i': Icons.storefront, 's': const SalesHubScreen()},
      {'l': 'Reporting', 'i': Icons.assessment, 's': const ReportingScreen()},
      {'l': 'PMS', 'i': Icons.emoji_events, 's': const PMSScreen()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isMobile ? 2.2 : 1.8,
      ),
      itemCount: utilities.length,
      itemBuilder: (context, i) => InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => utilities[i]['s'] as Widget)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
          decoration: BoxDecoration(color: NexusTheme.slate900, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: NexusTheme.slate900.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Row(
            children: [
              Icon(utilities[i]['i'] as IconData, color: NexusTheme.emerald400, size: isMobile ? 16 : 18),
              SizedBox(width: isMobile ? 8 : 10),
              Flexible(child: Text((utilities[i]['l'] as String).toUpperCase(), style: TextStyle(fontSize: isMobile ? 8 : 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5))),
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
  final bool isMobile;
  const _ActionCard({required this.label, required this.icon, required this.color, required this.onTap, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: isMobile ? 14 : 16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: NexusTheme.slate200), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10), 
              decoration: BoxDecoration(color: color.withOpacity(0.05), shape: BoxShape.circle), 
              child: Icon(icon, color: color, size: isMobile ? 20 : 24)
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Text(
                label, 
                style: TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w900, color: NexusTheme.slate800, letterSpacing: -0.2)
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: isMobile ? 14 : 16, color: NexusTheme.slate300),
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
      title: Row(
        children: [
          Icon(Icons.exit_to_app, color: Colors.redAccent, size: 28),
          SizedBox(width: 12),
          Text('Exit App', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
      content: Text(
        'Are you sure you want to exit NexusOMS?',
        style: TextStyle(fontSize: 14, color: NexusTheme.slate600),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('CANCEL', style: TextStyle(color: NexusTheme.slate500, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            // Exit the app
            SystemNavigator.pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('EXIT', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    ),
  ) ?? false;
}
