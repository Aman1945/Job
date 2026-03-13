import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'order_archive_screen.dart';
import 'book_order_screen.dart';
import 'procurement_screen.dart';
import 'master_data_screen.dart';
import 'credit_control_screen.dart';
import 'invoicing_screen.dart';
import 'logistics_hub_screen.dart';
import 'delivery_execution_screen.dart';
import 'new_customer_screen.dart';
import 'credit_risk_screen.dart';
import 'warehouse_ops_screen.dart';
import 'quality_control_screen.dart';
import 'logistics_ops_screen.dart';
import 'stock_transfer_screen.dart';
import 'analytics_screen.dart';
import 'executive_pulse_screen.dart';
import 'live_missions_screen.dart';
import 'pms_screen.dart';
import 'add_product_screen.dart';
import 'step_assignment_screen.dart';
import 'team_hierarchy_screen.dart';
import 'sales_org_map_screen.dart';
import 'user_credentials_screen.dart';
import 'attendance_screen.dart';

// ─────────────────────── COLOUR PALETTE ───────────────────────
const _bgPage   = Color(0xFFEDF2F8);  // light blue-gray page bg
const _bgCard   = Colors.white;
const _bgDark   = Color(0xFF0D2137);  // dark utility cards
const _txtHead  = Color(0xFF0D2137);
const _txtSub   = Color(0xFF7A8EA5);
const _teal     = Color(0xFF1ABFA1);
const _indigo   = Color(0xFF5C6BE8);
const _orange   = Color(0xFFFF8C3A);
const _purple   = Color(0xFF9B6DE3);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth          = Provider.of<AuthProvider>(context);
    final nexusProvider = Provider.of<NexusProvider>(context);
    final user          = auth.currentUser;

    // ── Zone-based order filtering ──
    List<Order> visibleOrders;
    if (user == null) {
      visibleOrders = nexusProvider.orders;
    } else {
      final roleFiltered = nexusProvider.getVisibleOrdersFor(user);
      final zone = user.zone.toUpperCase();
      if (zone == 'PAN INDIA' || user.role.label == 'Admin') {
        visibleOrders = roleFiltered;
      } else {
        visibleOrders = roleFiltered.where((o) {
          final deliveryAddr = (o.deliveryAddress ?? '').toUpperCase();
          return deliveryAddr.contains(zone) || o.salespersonId == user.id;
        }).toList();
        if (visibleOrders.isEmpty) visibleOrders = roleFiltered;
      }
    }

    final liveCount    = visibleOrders.where((o) => o.status != 'Delivered' && o.status != 'Rejected').length;
    final pendingCount = visibleOrders.where((o) => o.status.contains('Pending')).length;
    final totalRevenue = visibleOrders.fold(0.0, (s, o) => s + o.total);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final ok = await _showExitDialog(context);
        if (ok && context.mounted) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: _bgPage,
        // ── AppBar ──────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 20,
          title: Row(
            children: [
              // Shield icon
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: _teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield_outlined, size: 18, color: _teal),
              ),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'NEXUS',
                      style: TextStyle(
                        color: _txtHead,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'OMS',
                      style: TextStyle(
                        color: _teal,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: _txtSub, size: 22),
              tooltip: 'Logout',
              onPressed: () async {
                final ok = await _showLogoutDialog(context);
                if (ok) auth.logout();
              },
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded, color: _txtSub, size: 22),
              tooltip: 'Search',
              onPressed: () {},
            ),
            const SizedBox(width: 6),
          ],
        ),

        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome banner ───────────────────────────────
              _WelcomeBanner(name: user?.name ?? 'User'),

              // ── Stat cards ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  children: [
                    _StatCard(
                      icon: Icons.radar_rounded,
                      iconColor: _teal,
                      value: '$liveCount',
                      label: 'LIVE MISSIONS',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMissionsScreen())),
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: Icons.timer_outlined,
                      iconColor: _orange,
                      value: '$pendingCount',
                      label: 'PENDING OPS',
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: Icons.bar_chart_rounded,
                      iconColor: _indigo,
                      value: '110.0',
                      label: 'SCM SCORE',
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: Icons.credit_card_rounded,
                      iconColor: _purple,
                      value: '₹${(totalRevenue / 1000).toStringAsFixed(1)}K',
                      label: 'MTD REVENUE',
                    ),
                  ],
                ),
              ),

              // ── Supply Chain Lifecycle ───────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 18, 16, 14),
                child: Text(
                  'SUPPLY CHAIN LIFECYCLE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _txtSub,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              _LifecycleGrid(user: user),

              // ── Utilities & System Hub ───────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 28, 16, 14),
                child: Text(
                  'UTILITIES & SYSTEM HUB',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _txtSub,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              _UtilityGrid(user: user),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── WELCOME BANNER ───────────────────────
class _WelcomeBanner extends StatelessWidget {
  final String name;
  const _WelcomeBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back,',
            style: TextStyle(fontSize: 13, color: _txtSub, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _txtHead,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8FBF7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _teal.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                const Text(
                  'ACTIVE CLOUD PROTOCOL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _teal,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── STAT CARD ────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: _txtHead,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                  color: _txtSub,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── LIFECYCLE GRID ──────────────────────
class _LifecycleGrid extends StatelessWidget {
  final User? user;
  const _LifecycleGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    final stages = <Map<String, dynamic>>[
      {
        'stage': 'STAGE 1',  'label': 'Creation',
        'icon': Icons.person_add_alt_1_rounded,
        'color': _teal,
        'screen': const NewCustomerScreen(),
        'roles': ['Admin', 'Sales', 'RSM', 'ASM', 'NSM', 'Logistics Lead', 'Hub Lead'],
      },
      {
        'stage': 'STAGE 2',  'label': 'Placed Order',
        'icon': Icons.shopping_cart_checkout_rounded,
        'color': _indigo,
        'screen': const BookOrderScreen(),
        'roles': ['Admin', 'Sales', 'RSM', 'ASM', 'NSM', 'Logistics Lead'],
      },
      {
        'stage': 'STAGE 3',  'label': 'Credit Approval',
        'icon': Icons.verified_rounded,
        'color': _orange,
        'screen': const CreditControlScreen(),
        'roles': ['Admin', 'Credit Control', 'RSM', 'ASM', 'NSM'],
      },
      {
        'stage': 'STAGE 4',  'label': 'Warehouse',
        'icon': Icons.inventory_2_rounded,
        'color': const Color(0xFF8B7355),
        'screen': const WarehouseOpsScreen(),
        'roles': ['Admin', 'Warehouse', 'WH Manager', 'RSM', 'ASM', 'NSM'],
      },
      {
        'stage': 'STAGE 5',  'label': 'Packing',
        'icon': Icons.inventory_rounded,
        'color': const Color(0xFFE8A020),
        'screen': const WarehouseOpsScreen(),
        'roles': ['Admin', 'Warehouse', 'RSM', 'ASM', 'NSM'],
      },
      {
        'stage': 'STAGE 6',  'label': 'QC',
        'icon': Icons.verified_user_rounded,
        'color': const Color(0xFF22C55E),
        'screen': const QualityControlScreen(),
        'roles': ['Admin', 'QC Head', 'RSM', 'ASM', 'NSM'],
      },
      {
        'stage': 'STAGE 7',  'label': 'Logistics Cost',
        'icon': Icons.currency_rupee_rounded,
        'color': _purple,
        'screen': const LogisticsOpsScreen(),
        'roles': ['Admin', 'Logistics Lead', 'RSM', 'ASM', 'NSM', 'Hub Lead'],
      },
      {
        'stage': 'STAGE 8',  'label': 'Invoice',
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFF3B82F6),
        'screen': const InvoicingScreen(),
        'roles': ['Admin', 'Billing', 'ATL Executive', 'RSM', 'ASM', 'NSM'],
      },
      {
        'stage': 'STAGE 9',  'label': 'Dispatch & Load',
        'icon': Icons.local_shipping_rounded,
        'color': const Color(0xFF0EA5E9),
        'screen': const LogisticsHubScreen(),
        'roles': ['Admin', 'Hub Lead', 'Logistics Lead', 'RSM', 'ASM', 'NSM'],
      },
      {
        'stage': 'STAGE 10', 'label': 'Delivery Ack',
        'icon': Icons.task_alt_rounded,
        'color': Colors.redAccent,
        'screen': const DeliveryExecutionScreen(),
        'roles': ['Admin', 'Delivery Team', 'RSM', 'ASM', 'NSM', 'Hub Lead', 'Logistics Lead'],
      },
    ];

    final role = user!.role.label;
    final filtered = stages.where((s) {
      if (role == 'Admin') return true;
      if (user!.stepAccess.containsKey(s['label'])) {
        return (user!.stepAccess[s['label']] ?? 'no') != 'no';
      }
      return (s['roles'] as List).contains(role);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.4,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final s = filtered[i];
          final color = s['color'] as Color;
          return _LifecycleCard(
            stage: s['stage'] as String,
            label: s['label'] as String,
            icon: s['icon'] as IconData,
            color: color,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => s['screen'] as Widget),
            ),
          );
        },
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

  const _LifecycleCard({
    required this.stage,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EEF5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stage,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _txtHead,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── UTILITY GRID ────────────────────────
class _UtilityGrid extends StatelessWidget {
  final User? user;
  const _UtilityGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    final role = user!.role.label;

    // Only completely hide utilities for very restricted roles
    if (role == 'Billing' || role == 'ATL Executive') return const SizedBox.shrink();

    final all = <Map<String, dynamic>>[
      {'l': 'EXECUTIVE PULSE', 'i': Icons.query_stats_rounded,      's': const ExecutivePulseScreen(),        'roles': ['Admin', 'Sales', 'RSM', 'ASM', 'NSM', 'Logistics Lead', 'Hub Lead']},
      {'l': 'LIVE MISSIONS',   'i': Icons.radar_rounded,             's': const LiveMissionsScreen(),          'roles': ['Admin', 'Sales', 'RSM', 'ASM', 'NSM', 'Logistics Lead', 'Hub Lead']},
      {'l': 'STOCK TRANSFER',  'i': Icons.swap_horiz_rounded,        's': const StockTransferScreen(),         'roles': ['Admin', 'Sales', 'RSM', 'ASM', 'NSM']},
      {'l': 'SKU MASTER',      'i': Icons.post_add_rounded,          's': const AddProductScreen(),            'roles': ['Admin', 'Sales', 'RSM', 'ASM', 'NSM']},
      {'l': 'ORDER ARCHIVE',   'i': Icons.history_rounded,           's': const OrderArchiveScreen(),          'roles': ['Admin', 'Sales', 'RSM', 'ASM', 'NSM', 'Logistics Lead', 'Hub Lead']},
      {'l': 'PMS PERFORMANCE', 'i': Icons.emoji_events_rounded,      's': const PMSScreen(),                  'roles': ['Admin', 'Sales', 'RSM', 'ASM', 'NSM']},
      {'l': 'INTELLIGENCE',    'i': Icons.insights_rounded,          's': const AnalyticsScreen(),            'roles': ['Admin', 'Sales', 'RSM', 'ASM', 'NSM', 'Credit Control', 'Logistics Lead']},
      {'l': 'CREDIT ALERTS',   'i': Icons.warning_amber_rounded,     's': const CreditRiskScreen(),           'roles': ['Credit Control', 'Admin', 'RSM', 'NSM']},
      {'l': 'PROCUREMENT',     'i': Icons.shopping_bag_outlined,     's': const ProcurementScreen(),          'roles': ['Admin', 'RSM', 'NSM']},
      {'l': 'USER CREDENTIALS',  'i': Icons.key_rounded,                  's': const UserCredentialsScreen(),      'roles': ['Admin']},
      {'l': 'STEP ASSIGNMENT',   'i': Icons.assignment_ind_rounded,       's': const StepAssignmentScreen(),       'roles': ['Admin']},
      {'l': 'ATTENDANCE',         'i': Icons.fingerprint_rounded,           's': const AttendanceScreen(),            'roles': ['Admin', 'Sales', 'RSM', 'ASM', 'NSM', 'Logistics Lead', 'Hub Lead', 'Delivery Team', 'Warehouse', 'QC Head', 'Credit Control', 'Billing', 'ATL Executive']},
      {'l': 'MASTER DATA',     'i': Icons.storage_rounded,           's': const MasterDataScreen(),           'roles': ['Admin']},
      {'l': 'TEAM HIERARCHY',  'i': Icons.account_tree_rounded,      's': const TeamHierarchyScreen(),        'roles': ['Admin', 'RSM', 'ASM', 'NSM', 'Logistics Lead', 'Hub Lead']},
      {'l': 'SALES ORG MAP',   'i': Icons.corporate_fare_rounded,   's': const SalesOrgMapScreen(),          'roles': ['Admin', 'NSM', 'RSM']},
    ];

    final filtered = all.where((u) => (u['roles'] as List).contains(role)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.8,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final item = filtered[i];
          return _UtilityCard(
            label: item['l'] as String,
            icon: item['i'] as IconData,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item['s'] as Widget),
            ),
          );
        },
      ),
    );
  }
}

class _UtilityCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _UtilityCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _bgDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: _teal, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── DIALOGS ─────────────────────────────
Future<bool> _showLogoutDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.w900)),
      content: const Text('Are you sure you want to log out of NexusOMS?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
        TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('LOGOUT', style: TextStyle(color: Colors.red))),
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
        TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('EXIT', style: TextStyle(color: Colors.red))),
      ],
    ),
  ) ?? false;
}
