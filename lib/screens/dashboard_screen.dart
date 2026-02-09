import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'live_orders_screen.dart';
import 'analytics_screen.dart';
import 'book_order_screen.dart';
import 'order_archive_screen.dart';
import 'new_customer_screen.dart';
import 'credit_control_screen.dart';
import 'warehouse_selection_screen.dart';
import 'logistics_hub_screen.dart';
import 'delivery_execution_screen.dart';
import 'invoicing_screen.dart';
import 'procurement_screen.dart';
import 'master_data_screen.dart';
import '../providers/nexus_provider.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NexusProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);

    return Scaffold(
      drawer: _buildDrawer(context, provider),
      appBar: AppBar(
        title: const Text('NEXUS DASHBOARD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const CircleAvatar(
            backgroundColor: NexusTheme.emerald500,
            radius: 16,
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderStats(provider),
                  const SizedBox(height: 24),
                  _buildOrderChart(),
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Missions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildRecentOrders(provider),
                ],
              ),
            ),
    );
  }

  Widget _buildDrawer(BuildContext context, NexusProvider provider) {
    return Drawer(
      backgroundColor: NexusTheme.emerald950,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: NexusTheme.emerald900),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield, color: NexusTheme.emerald400, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    provider.currentUser?.name ?? 'User',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    provider.currentUser?.role.label ?? '',
                    style: const TextStyle(color: NexusTheme.emerald400, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          ..._buildRoleBasedItems(provider.currentUser?.role),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'LOGOUT',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => provider.logout(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildRoleBasedItems(UserRole? role) {
    if (role == null) return [];
    List<Widget> items = [];

    if (role == UserRole.admin) {
      return [
        _buildDrawerItem(Icons.dashboard, 'Executive Pulse', 0),
        _buildDrawerItem(Icons.rocket_launch, 'Live Missions', 1),
        _buildDrawerItem(Icons.archive, 'Order Archive', 2),
        const Divider(color: Colors.white12),
        _buildDrawerItem(Icons.person_add, 'New Customer', 3),
        _buildDrawerItem(Icons.add_shopping_cart, 'Book Order', 4),
        _buildDrawerItem(Icons.analytics, 'Analytics', 5),
        const Divider(color: Colors.white12),
        _buildDrawerItem(Icons.verified_user, 'Credit Control', 6),
        _buildDrawerItem(Icons.warehouse, 'WH Assignment', 7),
        _buildDrawerItem(Icons.local_shipping, 'Logistics Hub', 8),
        _buildDrawerItem(Icons.delivery_dining, 'Execution', 9),
        _buildDrawerItem(Icons.receipt_long, 'Invoicing', 10),
        const Divider(color: Colors.white12),
        _buildDrawerItem(Icons.inventory, 'Procurement', 11),
        _buildDrawerItem(Icons.database, 'Master Data', 12),
      ];
    }

    if (role == UserRole.sales) {
      items.add(_buildDrawerItem(Icons.add_shopping_cart, 'Book Order', 4));
      items.add(_buildDrawerItem(Icons.person_add, 'New Customer', 3));
      items.add(_buildDrawerItem(Icons.archive, 'Order Archive', 2));
      items.add(_buildDrawerItem(Icons.analytics, 'Analytics', 5));
    } else if (role == UserRole.finance || role == UserRole.approver) {
      items.add(_buildDrawerItem(Icons.verified_user, 'Credit Control', 6));
      items.add(_buildDrawerItem(Icons.dashboard, 'Executive Approval', 0));
      items.add(_buildDrawerItem(Icons.archive, 'Order Archive', 2));
    } else if (role == UserRole.logistics) {
      items.add(_buildDrawerItem(Icons.local_shipping, 'Logistics Hub', 8));
      items.add(_buildDrawerItem(Icons.rocket_launch, 'Fleet Tracking', 1));
      items.add(_buildDrawerItem(Icons.archive, 'Order Archive', 2));
    } else if (role == UserRole.delivery) {
      items.add(_buildDrawerItem(Icons.delivery_dining, 'My Deliveries', 9));
    } else if (role == UserRole.warehouse) {
      items.add(_buildDrawerItem(Icons.warehouse, 'WH Assignment', 7));
      items.add(_buildDrawerItem(Icons.rocket_launch, 'Packing Queue', 1));
      items.add(_buildDrawerItem(Icons.archive, 'Order Archive', 2));
    } else {
      items.add(_buildDrawerItem(Icons.dashboard, 'Overview', 0));
      items.add(_buildDrawerItem(Icons.archive, 'Order Archive', 2));
    }

    return items;
  }

  Widget _buildDrawerItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Colors.white
            : NexusTheme.emerald400.withValues(alpha: 0.6),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white60,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? NexusTheme.emerald500 : Colors.transparent,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context); // Close drawer
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LiveOrdersScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderArchiveScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewCustomerScreen()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookOrderScreen()),
          );
        } else if (index == 5) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
          );
        } else if (index == 6) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreditControlScreen()),
          );
        } else if (index == 7) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WarehouseSelectionScreen()),
          );
        } else if (index == 8) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LogisticsHubScreen()),
          );
        } else if (index == 9) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DeliveryExecutionScreen()),
          );
        } else if (index == 10) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InvoicingScreen()),
          );
        } else if (index == 11) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProcurementScreen()),
          );
        } else if (index == 12) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MasterDataScreen()),
          );
          );
        }
      },
    );
  }

  Widget _buildHeaderStats(NexusProvider provider) {
    final totalOrders = provider.orders.length;
    final totalValue = provider.orders.fold(0.0, (sum, order) => sum + order.total);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'TOTAL ORDERS',
            totalOrders.toString(),
            Icons.shopping_basket,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'VALUE',
            '₹${(totalValue / 1000).toStringAsFixed(1)}K',
            Icons.currency_rupee,
            NexusTheme.emerald500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 3),
                const FlSpot(1, 1),
                const FlSpot(2, 4),
                const FlSpot(3, 2),
                const FlSpot(4, 5),
              ],
              isCurved: true,
              color: NexusTheme.emerald500,
              barWidth: 4,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: NexusTheme.emerald500.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(NexusProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.orders.length,
      itemBuilder: (context, index) {
        final order = provider.orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NexusTheme.emerald500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                color: NexusTheme.emerald900,
              ),
            ),
            title: Text(
              order.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(order.id),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${order.total}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: NexusTheme.emerald900,
                  ),
                ),
                Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
