import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTerminal = 'ORDER FLOW';
  bool _isLoading = true;
  Map<String, dynamic> _categoryData = {};
  Map<String, dynamic> _fleetData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<NexusProvider>(context, listen: false);
    
    final results = await Future.wait([
      provider.fetchCategorySplitData(),
      provider.fetchFleetIntelligenceData(),
    ]);

    setState(() {
      _categoryData = results[0];
      _fleetData = results[1];
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: NexusTheme.indigo600)));

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('INTELLIGENCE TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTerminalToggle('ORDER FLOW'),
                _buildTerminalToggle('CATEGORY SPLIT'),
                _buildTerminalToggle('FLEET INTELLIGENCE'),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INTELLIGENCE TERMINAL',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: NexusTheme.slate900),
                ),
                const Text(
                  'HOLISTIC OPERATIONAL & CATEGORY PERFORMANCE ANALYTICS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: NexusTheme.slate400, letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSelectedTerminalView(),
            
            const SizedBox(height: 24),
            _buildIncentiveCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTerminalView() {
    switch (_selectedTerminal) {
      case 'CATEGORY SPLIT':
        return _buildCategorySplitView();
      case 'FLEET INTELLIGENCE':
        return _buildFleetIntelligenceView();
      case 'ORDER FLOW':
      default:
        return _buildOrderFlowView();
    }
  }

  Widget _buildOrderFlowView() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMetricCard('MTD QTY FULFILMENT', '0.0%', 'Ordered: 10 units', Colors.indigo, NexusTheme.blue900, icon: Icons.shopping_basket),
              _buildMetricCard('ORDER SUCCESS RATE', '0.0%', 'Total MTD: 1 orders', Colors.emerald, NexusTheme.emerald900, icon: Icons.check_circle),
              _buildMetricCard('STOCK SHORTAGE (LOSS)', '₹225', '5.2% leakage avg', Colors.orange, NexusTheme.amber900, icon: Icons.trending_down),
              _buildMetricCard('AVG LEAD TIME', '3.4 Days', '-0.8d vs Q1', Colors.slate, NexusTheme.slate900, icon: Icons.timer),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildChartContainer(
          'Supply Velocity % (MTD Trend)',
          LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 85),
                    const FlSpot(1, 88),
                    const FlSpot(2, 86),
                    const FlSpot(3, 89),
                    const FlSpot(4, 90),
                    const FlSpot(5, 50),
                    const FlSpot(6, 10),
                  ],
                  isCurved: true,
                  color: NexusTheme.indigo500,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: NexusTheme.indigo500.withOpacity(0.1)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySplitView() {
    final splitList = _categoryData['split'] as List? ?? [];
    final concentrationList = _categoryData['concentration'] as List? ?? [];

    return Row(
      children: [
        Expanded(
          child: _buildChartContainer(
            'Value by Category Split',
            Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: splitList.map((s) => PieChartSectionData(
                      color: Color(int.parse(s['color'].toString().replaceFirst('#', '0xFF'))), 
                      value: s['value'].toDouble(), 
                      radius: 40, 
                      showTitle: false
                    )).toList(),
                    centerSpaceRadius: 60,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, color: NexusTheme.indigo500),
                    const SizedBox(height: 4),
                    Text(splitList.isNotEmpty ? splitList[0]['category'] : 'N/A', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            icon: Icons.pie_chart_outline,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildChartContainer(
            'Qty Concentration',
            BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: concentrationList.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(toY: e.value['qty'].toDouble() / 50, color: NexusTheme.emerald500, width: 22, borderRadius: BorderRadius.circular(4))
                ])).toList(),
              ),
            ),
            icon: Icons.bar_chart,
            footerLabel: concentrationList.isNotEmpty ? concentrationList[0]['label'] : 'N/A',
          ),
        ),
      ],
    );
  }

  Widget _buildFleetIntelligenceView() {
    final metrics = _fleetData['metrics'] ?? {};
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMetricCard('FLEET COVERAGE', metrics['coverage'] ?? '0 KM', 'Trip distance MTD', Colors.indigo, NexusTheme.blue900, icon: Icons.route),
              _buildMetricCard('ACTIVE ASSETS', metrics['activeAssets'] ?? '0', 'Unique Reg Numbers', Colors.orange, NexusTheme.amber900, icon: Icons.local_shipping),
              _buildMetricCard('SUCCESSFUL DROPS', metrics['successfulDrops'] ?? '0', 'Confirmed PODs', Colors.emerald, NexusTheme.emerald900, icon: Icons.verified_user),
              _buildMetricCard('FLEET PERSONNEL', metrics['personnel'] ?? '0', 'On-field force', Colors.slate, NexusTheme.slate900, icon: Icons.person_pin_circle),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildChartContainer(
          'Fleet Assignment Velocity',
          const Center(child: Text('No Data Available', style: TextStyle(color: NexusTheme.slate400, fontSize: 12))),
        ),
      ],
    );
  }

  Widget _buildChartContainer(String title, Widget chart, {IconData? icon, String? footerLabel}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: NexusTheme.indigo500), const SizedBox(width: 8)],
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(height: 200, child: chart),
          if (footerLabel != null) ...[
            const SizedBox(height: 16),
            Center(child: Text(footerLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexusTheme.slate400))),
          ],
        ],
      ),
    );
  }

  Widget _buildTerminalToggle(String title) {
    bool isSelected = _selectedTerminal == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTerminal = title),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? NexusTheme.indigo500.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? NexusTheme.indigo500.withOpacity(0.2) : Colors.transparent),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected ? NexusTheme.indigo600 : NexusTheme.slate400,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color, Color accentColor, {IconData? icon}) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
              if (icon != null) Icon(icon, size: 14, color: NexusTheme.slate200),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
        ],
      ),
    );
  }

  Widget _buildIncentiveCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [NexusTheme.slate900, Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: NexusTheme.emerald500, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.calculate, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Animesh Jamuar', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    Text('FEB\'26 INCENTIVE TERMINAL', style: TextStyle(color: NexusTheme.emerald400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIncentiveMetric('GROSS MONTHLY SALARY', '₹131,089'),
              _buildIncentiveMetric('PAYABLE INCENTIVE', '₹32,772.25', isGreen: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncentiveMetric(String label, String value, {bool isGreen = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isGreen ? NexusTheme.emerald500.withOpacity(0.2) : Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isGreen ? NexusTheme.emerald500 : Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: isGreen ? NexusTheme.emerald400 : Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
