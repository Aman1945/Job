import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
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
import 'credit_risk_screen.dart';
import 'warehouse_ops_screen.dart';
import 'quality_control_screen.dart';
import 'logistics_ops_screen.dart'; // NEW
import 'stock_transfer_screen.dart';
import 'logistics_cost_screen.dart';
import 'warehouse_inventory_screen.dart';
import 'analytics_screen.dart';
import 'live_orders_screen.dart';
import 'sales_hub_screen.dart';
import 'reporting_screen.dart';
import 'executive_pulse_screen.dart';
import 'live_missions_screen.dart';
import 'pms_screen.dart';
import 'add_product_screen.dart';
import 'admin_user_management_screen.dart';
import 'step_assignment_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () async {
                final result = await _showLogoutDialog(context);
                if (result) auth.logout();
              }, 
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
                  
                  _buildActionList(context, isMobile, user),
                  
                  const SizedBox(height: 32),
                  const _SectionTitle(title: 'UTILITIES & SYSTEM HUB'),
                  const SizedBox(height: 16),
                  _buildUtilityGrid(context, isMobile, user),
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

  Widget _buildActionList(BuildContext context, bool isMobile, User? user) {
    if (user == null) return const SizedBox.shrink();

    final List<Map<String, dynamic>> lifecycleStages = [
      {
        'stage': 'STAGE 0',
        'label': 'New Customer',
        'icon': Icons.person_add_rounded,
        'color': Colors.indigo,
        'screen': const NewCustomerScreen(),
        'roles': ['Admin', 'Sales']
      },
      {
        'stage': 'STAGE 1',
        'label': 'Book Order',
        'icon': Icons.add_shopping_cart_rounded,
        'color': Colors.lightBlue,
        'screen': const BookOrderScreen(),
        'roles': ['Admin', 'Sales']
      },
      {
        'stage': 'STAGE 1.1',
        'label': 'Stock Transfer',
        'icon': Icons.sync_alt_rounded,
        'color': Colors.amber.shade800,
        'screen': const StockTransferScreen(),
        'roles': ['Admin', 'Sales']
      },
      {
        'stage': 'STAGE 1.5',
        'label': 'Clearance',
        'icon': Icons.cleaning_services_rounded,
        'color': Colors.blueGrey,
        'screen': const LiveOrdersScreen(),
        'roles': ['Admin', 'Sales']
      },
      {
        'stage': 'STAGE 2',
        'label': 'Credit Control',
        'icon': Icons.bolt_rounded,
        'color': Colors.orange.shade700,
        'screen': const CreditControlScreen(),
        'roles': ['Admin', 'Credit Control']
      },
      {
        'stage': 'STAGE 2.1',
        'label': 'Credit Alerts',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.red.shade700,
        'screen': const CreditRiskScreen(),
        'roles': ['Admin', 'Credit Control']
      },
      {
        'stage': 'STAGE 3',
        'label': 'Warehouse Operations', // Unified
        'icon': Icons.inventory_2_rounded,
        'color': Colors.brown.shade700,
        'screen': const WarehouseOpsScreen(),
        'roles': ['Admin', 'Warehouse', 'WH House', 'WH Manager', 'Operations']
      },
      {
        'stage': 'STAGE 3.5',
        'label': 'Quality Control (QC)',
        'icon': Icons.verified_user_rounded,
        'color': Colors.green.shade700,
        'screen': const QualityControlScreen(),
        'roles': ['Admin', 'QC Head']
      },
      {
        'stage': 'STAGE 4',
        'label': 'Logistics Costing',
        'icon': Icons.currency_rupee_rounded,
        'color': Colors.deepPurple,
        'screen': const LogisticsOpsScreen(), // Changed from LogisticsCostScreen to LogisticsOpsScreen
        'roles': ['Admin', 'Logistics Lead', 'Logistics Team']
      },
      {
        'stage': 'STAGE 5',
        'label': 'Invoicing',
        'icon': Icons.receipt_long_rounded,
        'color': Colors.blue.shade700,
        'screen': const InvoicingScreen(),
        'roles': ['Admin', 'ATL Executive', 'Billing']
      },
      {
        'stage': 'STAGE 6',
        'label': 'Fleet Loading (Hub)',
        'icon': Icons.local_shipping_rounded,
        'color': Colors.purple.shade700,
        'screen': const LogisticsHubScreen(),
        'roles': ['Admin', 'Hub Lead']
      },
      {
        'stage': 'STAGE 7',
        'label': 'Delivery Execution',
        'icon': Icons.task_alt_rounded,
        'color': Colors.redAccent.shade700,
        'screen': const DeliveryExecutionScreen(),
        'roles': ['Admin', 'Delivery Team']
      },
    ];

    // Filter stages based on role AND specifically requested persons/emails
    final filteredStages = lifecycleStages.where((s) {
      final email = user.id.toLowerCase();
      final role = user.role.label;

      // ★ ADMIN ALWAYS SEES EVERYTHING
      if (role == 'Admin') return true;

      // ★ PRIORITY 1: If Admin has configured stepAccess, use it (3-level: full/view/no)
      if (user.stepAccess.isNotEmpty) {
        final access = user.stepAccess[s['label']] ?? 'no';
        return access == 'full' || access == 'view'; // Show for both full & view, hide for 'no'
      }

      // 1. Invoicing row only for ATL Executives
      const atlExecutivesEmails = [
        'sandesh.gonbare@bigsams.in',
        'rajesh.suryavanshi@bigsams.in',
        'nitin.kadam@bigsams.in',
        'dipashree.gawde@bigsams.in'
      ];
      if (atlExecutivesEmails.contains(email)) {
        return s['label'] == 'Invoicing';
      }

      // 2. Pranav Override -> ONLY WH Assignment
      if (email == 'pranav.manger@bigsams.in') {
        return s['label'] == 'WH Assignment & Packing';
      }

      // 3. Dheeraj / QC Head Override -> ONLY QC
      if (email == 'dhiraj.kumar@bigsams.in' || email == 'quality@bigsams.in') {
        return s['label'] == 'Quality Control (QC)';
      }

      // 4. Pratish Dalvi -> Logistics Costing & Hub
      if (email == 'pratish.dalvi@bigsams.in') {
        return s['label'] == 'Logistics Costing' || s['label'] == 'Fleet Loading (Hub)';
      }

      // 5. Sagar -> ONLY Fleet Loading (Hub)
      if (email == 'sagar.delivery@bigsams.in') {
        return s['label'] == 'Fleet Loading (Hub)';
      }

      // 6. Lawin -> ONLY Logistics Managed (Renamed for him)
      if (email == 'lavin.samtani@bigsams.in') {
        if (s['label'] == 'Logistics Costing') {
          s['label'] = 'Logistics Managed';
          return true;
        }
        return false;
      }

      // 7. Operations Manager (operations@bigsams.in) - Warehouse Focus
      if (email == 'operations@bigsams.in') {
        // STRICTLY SHOW: Warehouse Operations, Logistics Costing, Fleet Loading (Hub)
        // EXPLICITLY HIDE: Quality Control (QC) and all others
        const allowedStages = [
          'Warehouse Operations', 
          'Logistics Costing', 
          'Fleet Loading (Hub)'
        ];
        return allowedStages.contains(s['label']);
      }

      // 8. Credit Control specialists (Already done)
      if (email == 'pawan.kumar@bigsams.in' || email == 'kshama.jaiswal@bigsams.in' || role == 'Credit Control' || email == 'credit.control@bigsams.in') {
        return s['label'] == 'Credit Control' || s['label'] == 'Credit Alerts';
      }

      // 9. Creation stages (restricted to Sales/Admin)
      const creationStages = ['New Customer', 'Book Order', 'Stock Transfer', 'Clearance'];
      if (creationStages.contains(s['label'])) {
        // STRICT: "New Customer" only for Sales team (and Admin)
        if (s['label'] == 'New Customer') {
           if (role == 'Admin') return true;
           if (role == 'Sales') return true;
           // Explicitly block for everyone else
           return false;
        }
        return (role == 'Sales' || role == 'Admin');
      }

      // Standard Role Match for Admin/Others
      final roleMatch = (s['roles'] as List).contains(role);
      return roleMatch;
    }).toList();

    return Column(
      children: filteredStages.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _LifecycleCard(
          stage: s['stage'] as String,
          label: s['label'] as String,
          icon: s['icon'] as IconData,
          color: s['color'] as Color,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => s['screen'] as Widget)),
          isMobile: isMobile,
          isActive: filteredStages.indexOf(s) == 0, // Highlight the first visible stage
        ),
      )).toList(),
    );
  }

  Widget _buildUtilityGrid(BuildContext context, bool isMobile, User? user) {
    if (user == null) return const SizedBox.shrink();

    final allUtilities = [
      {'l': 'Executive Pulse', 'i': Icons.query_stats, 's': const ExecutivePulseScreen(), 'roles': ['Admin', 'Sales']},
      {'l': 'Live Missions', 'i': Icons.radar, 's': const LiveMissionsScreen(), 'roles': ['Admin', 'Sales']},
      {'l': 'Stock Transfer', 'i': Icons.sync_alt, 's': const StockTransferScreen(), 'roles': ['Admin', 'Sales']},
      {'l': 'SKU Master', 'i': Icons.post_add_rounded, 's': const AddProductScreen(), 'roles': ['Admin', 'Sales']},
      {'l': 'Order Archive', 'i': Icons.history, 's': const OrderArchiveScreen(), 'roles': ['Admin', 'Sales']},
      {'l': 'PMS Performance', 'i': Icons.emoji_events, 's': const PMSScreen(), 'roles': ['Admin', 'Sales']},
      {'l': 'Intelligence', 'i': Icons.insights, 's': const AnalyticsScreen(), 'roles': ['Admin', 'Sales', 'Credit Control']},
    {'l': 'Credit Alerts', 'i': Icons.warning_amber_rounded, 's': const CreditRiskScreen(), 'roles': ['Credit Control', 'Admin']}, // NEW
      {'l': 'Procurement', 'i': Icons.shopping_bag_outlined, 's': const ProcurementScreen(), 'roles': ['Admin']},
      {'l': 'User Management', 'i': Icons.manage_accounts_rounded, 's': const AdminUserManagementScreen(), 'roles': ['Admin']},
      {'l': 'Step Assignment', 'i': Icons.assignment_ind_rounded, 's': const StepAssignmentScreen(), 'roles': ['Admin']},
      {'l': 'Master Data', 'i': Icons.terminal, 's': const MasterDataScreen(), 'roles': ['Admin']},
    ];

    final email = user.id.toLowerCase();
    final role = user.role.label;

    // Strict filter for dedicated terminal users - No utilities
    if (email == 'pawan.kumar@bigsams.in' || email == 'kshama.jaiswal@bigsams.in' || role == 'Credit Control' || email == 'credit.control@bigsams.in') {
      return const SizedBox.shrink();
    }

    final filteredUtils = allUtilities.where((u) => (u['roles'] as List).contains(role)).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: filteredUtils.length,
      itemBuilder: (context, i) => InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => filteredUtils[i]['s'] as Widget)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: NexusTheme.slate900, 
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Icon(filteredUtils[i]['i'] as IconData, color: NexusTheme.emerald400, size: 18),
              const SizedBox(width: 10),
              Flexible(child: Text((filteredUtils[i]['l'] as String).toUpperCase(), 
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5))),
            ],
          ),
        ),
      ),
    );
  }
}

class _LifecycleCard extends StatelessWidget {
  final String stage;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isMobile;
  final bool isActive;

  const _LifecycleCard({
    required this.stage,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isMobile,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isActive ? LinearGradient(colors: [color.withOpacity(0.5), color]) : null,
          boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : null,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? Colors.transparent : NexusTheme.slate200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stage, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.2)),
                    const SizedBox(height: 2),
                    Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isActive ? color : NexusTheme.slate300),
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


Future<bool> _showLogoutDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.w900)),
      content: const Text('Are you sure you want to log out of NexusOMS?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('LOGOUT', style: TextStyle(color: Colors.red))),
      ],
    ),
  ) ?? false;
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
