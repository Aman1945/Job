import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'live_missions_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final nexusProvider = Provider.of<NexusProvider>(context);
    final user = auth.currentUser;

    // Metric Calculations
    final visibleOrders = nexusProvider.getVisibleOrdersFor(user);
    final liveCount = visibleOrders.where((o) => o.status != 'Delivered' && o.status != 'Rejected').length;
    final totalRevenue = visibleOrders.fold(0.0, (s, o) => s + o.total);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final ok = await _showExitDialog(context);
        if (ok && context.mounted) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: NexusTheme.slate50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NexusTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hub_outlined, color: NexusTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nexus OMS',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: NexusTheme.slate600),
                  onPressed: () {},
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: NexusTheme.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded, color: NexusTheme.slate600),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: NexusTheme.slate200,
                          backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=nexus_user'), // Placeholder
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: NexusTheme.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, ${user?.name ?? "User"}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: NexusTheme.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Active Now',
                                  style: TextStyle(
                                    color: NexusTheme.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user?.role.label ?? 'Ops Manager',
                                style: TextStyle(color: NexusTheme.slate500, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Metric Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _MetricCard(
                      label: 'Live Missions',
                      value: '$liveCount',
                      trend: '+12%',
                      isPositive: true,
                      icon: Icons.rocket_launch_outlined,
                      color: Colors.blue,
                    ),
                    _MetricCard(
                      label: 'Pending Ops',
                      value: '45', // Mock as per Screenshot
                      trend: '-5%',
                      isPositive: false,
                      icon: Icons.assignment_outlined,
                      color: Colors.blueGrey,
                    ),
                    _MetricCard(
                      label: 'SCM Score',
                      value: '94.2%',
                      trend: '+0.8%',
                      isPositive: true,
                      icon: Icons.bar_chart_rounded,
                      color: Colors.indigo,
                    ),
                    _MetricCard(
                      label: 'MTD Revenue',
                      value: 'SR 2.4M',
                      trend: '+15%',
                      isPositive: true,
                      icon: Icons.payments_outlined,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Supply Chain Lifecycle
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: NexusTheme.slate200.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_tree_outlined, color: NexusTheme.primaryBlue),
                        const SizedBox(width: 12),
                        Text(
                          'Supply Chain Lifecycle',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _LifecycleStep(
                      title: 'Order Creation',
                      subtitle: 'Order #8821 confirmed and validated',
                      status: 'COMPLETED',
                      statusColor: NexusTheme.success,
                      icon: Icons.shopping_cart_outlined,
                      isFirst: true,
                    ),
                    _LifecycleStep(
                      title: 'Warehouse Processing',
                      subtitle: 'Picking and packing at JED-04 Hub',
                      status: 'IN PROGRESS',
                      statusColor: NexusTheme.success,
                      icon: Icons.inventory_2_outlined,
                    ),
                    _LifecycleStep(
                      title: 'Last-Mile Logistics',
                      subtitle: 'Awaiting carrier assignment',
                      status: 'PENDING',
                      statusColor: NexusTheme.slate400,
                      icon: Icons.local_shipping_outlined,
                    ),
                    _LifecycleStep(
                      title: 'Returns & Reverse SCM',
                      subtitle: 'Available post-delivery',
                      status: 'LOCKED',
                      statusColor: NexusTheme.slate400,
                      icon: Icons.assignment_return_outlined,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for FAB/BottomBar
            ],
          ),
        ),
      ),
    );
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
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('EXIT', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NexusTheme.slate200.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                trend,
                style: TextStyle(
                  color: isPositive ? NexusTheme.success : NexusTheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(color: NexusTheme.slate500, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: NexusTheme.slate900),
          ),
        ],
      ),
    );
  }
}

class _LifecycleStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final IconData icon;
  final bool isFirst;
  final bool isLast;

  const _LifecycleStep({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.icon,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: NexusTheme.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: NexusTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: NexusTheme.slate200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: NexusTheme.slate900),
                      ),
                      Text(
                        status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: NexusTheme.slate500, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
