import 'package:flutter/material.dart';
import 'package:nexus_oms_mobile/models/models.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';

class ExecutivePulseScreen extends StatelessWidget {
  const ExecutivePulseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('EXECUTIVE PULSE TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: NexusTheme.indigo50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.construction_rounded,
                size: 64,
                color: NexusTheme.indigo600,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'COMING SOON',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: NexusTheme.slate900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'The Executive Pulse terminal is currently being\nsynchronized with real-time field data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: NexusTheme.slate400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReliabilityCard() {
    return Container(
      height: 600,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      decoration: BoxDecoration(
        color: const Color(0xFF031A17),
        borderRadius: BorderRadius.circular(60),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  value: 0.942,
                  strokeWidth: 32,
                  color: const Color(0xFFF59E0B),
                  backgroundColor: Colors.white.withOpacity(0.05),
                  strokeCap: StrokeCap.round,
                ),
              ),
              const Icon(Icons.check, color: Colors.white, size: 64),
            ],
          ),
          const SizedBox(height: 80),
          const Text('94.2% Reliability', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF10B981), letterSpacing: -1)),
          const SizedBox(height: 16),
          const Text('Fleet performance index (Current Qtr)', 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF059669), letterSpacing: 0.5)
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyChart() {
    return Container(
      height: 600,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('THROUGHPUT EFFICIENCY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: NexusTheme.slate900)),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: NexusTheme.emerald500, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  const Text('DELIVERIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)),
                ],
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 380,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1, dashArray: [5, 5]),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold, fontSize: 12);
                        switch (value.toInt()) {
                          case 2: return const Padding(padding: EdgeInsets.only(top: 18), child: Text('Tue', style: style));
                          case 4: return const Padding(padding: EdgeInsets.only(top: 18), child: Text('Wed', style: style));
                          case 6: return const Padding(padding: EdgeInsets.only(top: 18), child: Text('Thu', style: style));
                          case 8: return const Padding(padding: EdgeInsets.only(top: 18), child: Text('Fri', style: style));
                          case 10: return const Padding(padding: EdgeInsets.only(top: 18), child: Text('Sat', style: style));
                          case 12: return const Padding(padding: EdgeInsets.only(top: 18), child: Text('Sun', style: style));
                        }
                        return const Text('');
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 15),
                      FlSpot(2, 35),
                      FlSpot(4, 25),
                      FlSpot(6, 48),
                      FlSpot(8, 38),
                      FlSpot(10, 18),
                      FlSpot(12, 14),
                    ],
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 8,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withOpacity(0.03),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.white,
                    tooltipRoundedRadius: 20,
                    tooltipPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
