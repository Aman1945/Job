import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTerminal = 'ORDER FLOW';

  @override
  Widget build(BuildContext context) {

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
             const Text(
              'HOLISTIC OPERATIONAL & CATEGORY PERFORMANCE ANALYTICS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: NexusTheme.slate400, letterSpacing: 0.5),
            ),
            const SizedBox(height: 16),
            
            // Intelligence Summary Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMetricCard('MTD QTY FULFILMENT', '0.0%', 'Ordered: 10 units', Colors.blue, NexusTheme.blue900),
                  _buildMetricCard('ORDER SUCCESS RATE', '0.0%', 'Total MTD: 1 orders', Colors.green, NexusTheme.emerald900),
                  _buildMetricCard('STOCK SHORTAGE (LOSS)', '₹225', '5.2% leakage avg', Colors.orange, NexusTheme.amber900),
                  _buildMetricCard('AVG LEAD TIME', '3.4 Days', '-0.8d vs Q1', Colors.grey, NexusTheme.slate900),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Supply Velocity Trend
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SUPPLY VELOCITY % (MTD TREND)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 200,
                    child: LineChart(
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
                              const FlSpot(4, 30),
                            ],
                            isCurved: true,
                            color: NexusTheme.indigo500,
                            barWidth: 4,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true, 
                              color: NexusTheme.indigo500.withValues(alpha: 0.1)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Incentive Card (Integrated)
            _buildIncentiveCard(),
          ],
        ),
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
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected ? NexusTheme.slate900 : NexusTheme.slate400,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color, Color accentColor) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: -1)),
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
        color: isGreen ? NexusTheme.emerald500.withValues(alpha: 0.2) : Colors.white10,
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
