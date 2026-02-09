import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final totalValue = provider.orders.fold(0.0, (sum, order) => sum + order.total);
    final avgValue = provider.orders.isEmpty ? 0.0 : totalValue / provider.orders.length;

    return Scaffold(
      appBar: AppBar(title: const Text('SYSTEM ANALYTICS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Sales Revenue Intelligence'),
            const SizedBox(height: 12),
            _buildRevenueChart(provider),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Conversion Rate', '72%', Icons.trending_up, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Avg Order Value', '₹${(avgValue / 1000).toStringAsFixed(1)}k', Icons.bolt, Colors.blue)),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Supply Chain Efficiency'),
            const SizedBox(height: 12),
            _buildEfficiencySummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: NexusTheme.slate400),
    );
  }

  Widget _buildRevenueChart(NexusProvider provider) {
    // Get last 5 orders or fewer
    final lastOrders = provider.orders.take(5).toList().reversed.toList();
    
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: lastOrders.isEmpty 
        ? const Center(child: Text('No Data Available'))
        : BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: lastOrders.fold(0.0, (max, o) => o.total > max ? o.total : max) * 1.2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(show: false),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(lastOrders.length, (i) {
                return _makeGroupData(i, lastOrders[i].total, i % 2 == 0 ? NexusTheme.emerald500 : NexusTheme.emerald900);
              }),
            ),
          ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 20, color: color.withValues(alpha: 0.1)),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: NexusTheme.emerald950)),
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
        ],
      ),
    );
  }

  Widget _buildEfficiencySummary() {
    return Column(
      children: [
        _buildEfficiencyRow('Dispatch Latency', 0.85, Icons.timer),
        const SizedBox(height: 12),
        _buildEfficiencyRow('Logistics Accuracy', 0.94, Icons.gps_fixed),
        const SizedBox(height: 12),
        _buildEfficiencyRow('Procurement Cycle', 0.72, Icons.refresh),
      ],
    );
  }

  Widget _buildEfficiencyRow(String label, double value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Row(
        children: [
          Icon(icon, color: NexusTheme.emerald900, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const Spacer(),
          Text('${(value * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.emerald500)),
        ],
      ),
    );
  }
}
