import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
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

    // Real-time calculations for Stats
    final liveMissionsCount = provider.orders.where((o) => o.status != 'Delivered' && o.status != 'Rejected').length;
    final pendingCount = provider.orders.where((o) => o.status == 'Pending Credit Approval' || o.status == 'Pending WH Selection').length;
    final deliveredCount = provider.orders.where((o) => o.status == 'Delivered').length;
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
          IconButton(
            onPressed: () => provider.logout(),
            icon: const Icon(Icons.logout, color: Colors.grey),
          ),
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
            _buildStatsGrid(liveMissionsCount.toString(), pendingCount.toString(), deliveredCount.toString(), "₹${(totalRevenue/1000).toStringAsFixed(1)}K"),
            const SizedBox(height: 32),
            const Text(
              'SUPPLY CHAIN LIFECYCLE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: NexusTheme.slate400,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionGrid(context),
            const SizedBox(height: 32),
            const Text(
              'ENTERPRISE TERMINALS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: NexusTheme.slate400,
                letterSpacing: 2,
              ),
            ),
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
        const Text(
          'Welcome back,',
          style: TextStyle(fontSize: 14, color: NexusTheme.slate400, fontWeight: FontWeight.w600),
        ),
        Text(
          name.toUpperCase(),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: NexusTheme.emerald500.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: NexusTheme.emerald500.withValues(alpha: 0.2)),
          ),
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

  Widget _buildStatsGrid(String live, String pending, String delivered, String revenue) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('LIVE MISSIONS', live, Icons.radar, NexusTheme.emerald500),
        _buildStatCard('PENDING OPS', pending, Icons.timer_outlined, Colors.orange),
        _buildStatCard('SCM SCORE', '110.0', Icons.analytics_outlined, Colors.blue),
        _buildStatCard('MTD REVENUE', revenue, Icons.payments_outlined, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              const Icon(Icons.arrow_outward, color: NexusTheme.slate300, size: 14),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -1)),
              Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        _buildActionCard(context, '0. NEW CUSTOMER', Icons.person_add_outlined, Colors.indigo, const NewCustomerScreen()),
        _buildActionCard(context, '1. BOOK ORDER', Icons.add_shopping_cart, NexusTheme.emerald700, const BookOrderScreen()),
        _buildActionCard(context, '1.1 STOCK TRANSFER', Icons.sync_alt, NexusTheme.slate600, const StockTransferScreen()),
        _buildActionCard(context, '2. CREDIT CONTROL', Icons.bolt, Colors.orange, const CreditControlScreen()),
        _buildActionCard(context, '2.5 WH ASSIGN', Icons.home_work_outlined, Colors.teal, const WarehouseSelectionScreen()),
        _buildActionCard(context, '3. WAREHOUSE', Icons.inventory_2_outlined, Colors.blueGrey, const WarehouseInventoryScreen()),
        _buildActionCard(context, '4. LOGISTICS COST', Icons.currency_rupee, Colors.deepPurple, const LogisticsCostScreen()),
        _buildActionCard(context, '5. INVOICING', Icons.receipt_long, Colors.blue, const InvoicingScreen()),
        _buildActionCard(context, '6. LOGISTICS HUB', Icons.explore_outlined, Colors.purple, const LogisticsHubScreen()),
        _buildActionCard(context, '7. EXECUTION', Icons.local_shipping_outlined, Colors.redAccent, const DeliveryExecutionScreen()),
      ],
    );
  }

  Widget _buildUtilityGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildUtilityCard(context, 'Procurement', Icons.shopping_bag_outlined, const ProcurementScreen()),
        _buildUtilityCard(context, 'Intelligence', Icons.insights, const AnalyticsScreen()),
        _buildUtilityCard(context, 'Order Archive', Icons.history, const OrderArchiveScreen()),
        _buildUtilityCard(context, 'Master Data', Icons.terminal, const MasterDataScreen()),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String label, IconData icon, Color color, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NexusTheme.slate200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate800, letterSpacing: -0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilityCard(BuildContext context, String label, IconData icon, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: NexusTheme.slate900,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: NexusTheme.slate900.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(icon, color: NexusTheme.emerald400, size: 18),
            const SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
