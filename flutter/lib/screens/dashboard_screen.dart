import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import 'live_missions_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final nexusProvider = Provider.of<NexusProvider>(context);
    final user = auth.currentUser;

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
              child: const Icon(Icons.grid_view_rounded, color: NexusTheme.blue600, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('System Hub', style: TextStyle(color: NexusTheme.slate900, fontSize: 18, fontWeight: FontWeight.w900)),
                Text('NEXUS OMS', style: TextStyle(color: NexusTheme.slate400, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: NexusTheme.slate700),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: NexusTheme.slate700),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: NexusTheme.blue600, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Global System Status
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
                    'GLOBAL SYSTEM STATUS',
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
                      Icon(Icons.insights_rounded, color: NexusTheme.slate700, size: 32),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusMetric('Uptime', '99.98%'),
                      _buildStatusMetric('Latency', '24ms'),
                      _buildStatusMetric('Active Nodes', '12'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            const Text(
              'EXECUTIVE UTILITIES',
              style: TextStyle(color: NexusTheme.slate900, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 20),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildUtilityCard(
                  Icons.insert_chart_outlined_rounded,
                  'Executive Pulse',
                  'Real-time KPI flow',
                  onTap: () {},
                ),
                _buildUtilityCard(
                  Icons.rocket_launch_rounded,
                  'Live Missions',
                  'Active deployments',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMissionsScreen())),
                ),
                _buildUtilityCard(
                  Icons.swap_horiz_rounded,
                  'Stock Transfer',
                  'Inter-node logistics',
                  onTap: () {},
                ),
                _buildUtilityCard(
                  Icons.inventory_2_rounded,
                  'Inventory',
                  'Stock optimization',
                  onTap: () => nexusProvider.setIndex(2),
                ),
                _buildUtilityCard(
                  Icons.article_outlined,
                  'Orders',
                  'Process automation',
                  onTap: () => nexusProvider.setIndex(1),
                ),
                _buildUtilityCard(
                  Icons.query_stats_rounded,
                  'Analytics',
                  'Deep-dive reporting',
                  onTap: () {},
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            const Text(
              'SECURITY & LOGS',
              style: TextStyle(color: NexusTheme.slate900, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: NexusTheme.slate50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: NexusTheme.slate100),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: NexusTheme.blue50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_outlined, color: NexusTheme.blue600, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Access Logs', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NexusTheme.slate900)),
                        Text('24 new entries today', style: TextStyle(fontSize: 12, color: NexusTheme.slate500, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: NexusTheme.slate300),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: NexusTheme.slate500, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildUtilityCard(IconData icon, String title, String subtitle, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: NexusTheme.slate900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: NexusTheme.slate500, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
