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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FA), // Light greyish-blue background from SS
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SUPPLY CHAIN LIFECYCLE',
              style: TextStyle(color: NexusTheme.slate400, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            const SizedBox(height: 20),
            
            // 2-Column Lifecycle Grid (Stages 1-10)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.1,
              children: [
                _buildLifecycleCard('STAGE 1', 'Creation', Icons.person_add_alt_1_rounded, const Color(0xFFE0F2F1), const Color(0xFF00897B)),
                _buildLifecycleCard('STAGE 2', 'Placed Or...', Icons.shopping_cart_rounded, const Color(0xFFF3E5F5), const Color(0xFF8E24AA)),
                _buildLifecycleCard('STAGE 3', 'Credit Ap...', Icons.check_circle_rounded, const Color(0xFFFFF3E0), const Color(0xFFFB8C00)),
                _buildLifecycleCard('STAGE 4', 'Warehouse', Icons.inventory_2_rounded, const Color(0xFFEFEBE9), const Color(0xFF6D4C41)),
                _buildLifecycleCard('STAGE 5', 'Packing', Icons.assignment_rounded, const Color(0xFFFFF9C4), const Color(0xFFFBC02D)),
                _buildLifecycleCard('STAGE 6', 'QC', Icons.verified_user_rounded, const Color(0xFFE8F5E9), const Color(0xFF43A047)),
                _buildLifecycleCard('STAGE 7', 'Logistics ...', Icons.currency_rupee_rounded, const Color(0xFFF3E5F5), const Color(0xFF7E57C2)),
                _buildLifecycleCard('STAGE 8', 'Invoice', Icons.document_scanner_rounded, const Color(0xFFE3F2FD), const Color(0xFF1E88E5)),
                _buildLifecycleCard('STAGE 9', 'Dispatch ...', Icons.local_shipping_rounded, const Color(0xFFE1F5FE), const Color(0xFF0288D1)),
                _buildLifecycleCard('STAGE 10', 'Delivery A...', Icons.check_circle_outline_rounded, const Color(0xFFFFEBEE), const Color(0xFFE53935)),
              ],
            ),
            
            const SizedBox(height: 40),

            const Text(
              'UTILITIES & SYSTEM HUB',
              style: TextStyle(color: NexusTheme.slate400, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            const SizedBox(height: 20),

            // 2-Column Dark Utilities Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.3,
              children: [
                _buildDarkUtilityCard('EXECUTIVE PULSE', Icons.insights_rounded),
                _buildDarkUtilityCard('LIVE MISSIONS', Icons.webhook_rounded),
                _buildDarkUtilityCard('STOCK TRANSFER', Icons.swap_horiz_rounded),
                _buildDarkUtilityCard('SKU MASTER', Icons.grid_view_rounded),
                _buildDarkUtilityCard('ORDER ARCHIVE', Icons.history_rounded),
                _buildDarkUtilityCard('P&S PERFORMANCE', Icons.donut_large_rounded),
                _buildDarkUtilityCard('INTELLIGENCE', Icons.auto_graph_rounded),
                _buildDarkUtilityCard('CREDIT ALERTS', Icons.warning_amber_rounded),
                _buildDarkUtilityCard('PROCUREMENT', Icons.shopping_bag_outlined),
                _buildDarkUtilityCard('USER CREDENTIALS', Icons.vpn_key_outlined),
                _buildDarkUtilityCard('STEP ASSIGNMENT', Icons.person_search_outlined),
                _buildDarkUtilityCard('ATTENDANCE', Icons.fingerprint_rounded),
                _buildDarkUtilityCard('MASTER DATA', Icons.list_alt_rounded),
                _buildDarkUtilityCard('TEAM HIERARCHY', Icons.account_tree_outlined),
                _buildDarkUtilityCard('SALES ORG MAP', Icons.home_work_outlined),
              ],
            ),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildLifecycleCard(String stage, String title, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stage,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: iconColor.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: NexusTheme.slate900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: NexusTheme.slate200, size: 16),
        ],
      ),
    );
  }

  Widget _buildDarkUtilityCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Slate-900 like deep dark
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2DD4BF), size: 16), // Teal accent
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
