import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';

class PMSScreen extends StatefulWidget {
  const PMSScreen({super.key});

  @override
  State<PMSScreen> createState() => _PMSScreenState();
}

class _PMSScreenState extends State<PMSScreen> {
  String _selectedPeriod = 'This Month';
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final user = provider.currentUser;
    
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('PERFORMANCE MANAGEMENT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchOrders(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Performance Card
                _buildUserPerformanceCard(user?.name ?? 'User', isMobile),
                const SizedBox(height: 24),
                
                // Period Selector
                _buildPeriodSelector(isMobile),
                const SizedBox(height: 24),
                
                // KPI Dashboard
                _buildSectionHeader('KEY PERFORMANCE INDICATORS'),
                const SizedBox(height: 16),
                _buildKPIDashboard(provider, isMobile),
                const SizedBox(height: 24),
                
                // Sales Targets
                _buildSectionHeader('SALES TARGETS'),
                const SizedBox(height: 16),
                _buildSalesTargets(provider, isMobile),
                const SizedBox(height: 24),
                
                // Performance Metrics
                _buildSectionHeader('PERFORMANCE METRICS'),
                const SizedBox(height: 16),
                _buildPerformanceMetrics(provider, isMobile),
                const SizedBox(height: 24),
                
                // Team Leaderboard
                _buildSectionHeader('TEAM LEADERBOARD'),
                const SizedBox(height: 16),
                _buildTeamLeaderboard(isMobile),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildUserPerformanceCard(String userName, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [NexusTheme.emerald600, NexusTheme.emerald800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: NexusTheme.emerald500.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'TOP PERFORMER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceMetric('Score', '95/100', Icons.star, isMobile),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPerformanceMetric('Rank', '#2', Icons.emoji_events, isMobile),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPerformanceMetric('Growth', '+12%', Icons.trending_up, isMobile),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceMetric(String label, String value, IconData icon, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodSelector(bool isMobile) {
    final periods = ['Today', 'This Week', 'This Month', 'This Quarter', 'This Year'];
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: NexusTheme.emerald500, size: 20),
          const SizedBox(width: 12),
          const Text('Period:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              isExpanded: true,
              underline: const SizedBox(),
              items: periods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (value) => setState(() => _selectedPeriod = value!),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildKPIDashboard(NexusProvider provider, bool isMobile) {
    final orders = provider.orders;
    final completionRate = orders.isNotEmpty 
      ? (orders.where((o) => o.status == 'Delivered').length / orders.length * 100) 
      : 0;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: isMobile ? 12 : 16,
      crossAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: isMobile ? 1.3 : 1.5,
      children: [
        _buildKPICard('Orders Completed', '${orders.where((o) => o.status == 'Delivered').length}', completionRate, Colors.green, isMobile),
        _buildKPICard('Response Time', '2.5 hrs', 85, Colors.blue, isMobile),
        _buildKPICard('Customer Satisfaction', '4.8/5', 96, Colors.purple, isMobile),
        _buildKPICard('Target Achievement', '92%', 92, Colors.orange, isMobile),
      ],
    );
  }
  
  Widget _buildKPICard(String label, String value, double percentage, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: isMobile ? 10 : 11, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${percentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                  Icon(Icons.trending_up, size: 16, color: color),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 6,
                  backgroundColor: NexusTheme.slate100,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSalesTargets(NexusProvider provider, bool isMobile) {
    final orders = provider.orders;
    final totalSales = orders.fold(0.0, (sum, o) => sum + o.total);
    final target = 500000.0;
    final achievement = (totalSales / target * 100).clamp(0, 100);
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly Target', style: TextStyle(fontSize: 12, color: NexusTheme.slate500, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('₹${(target / 1000).toStringAsFixed(0)}K', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Achieved', style: TextStyle(fontSize: 12, color: NexusTheme.slate500, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('₹${(totalSales / 1000).toStringAsFixed(0)}K', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: NexusTheme.emerald600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: achievement / 100,
              minHeight: 12,
              backgroundColor: NexusTheme.slate100,
              valueColor: const AlwaysStoppedAnimation(NexusTheme.emerald500),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${achievement.toStringAsFixed(1)}% of target achieved',
            style: const TextStyle(fontSize: 12, color: NexusTheme.slate500, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceMetrics(NexusProvider provider, bool isMobile) {
    final metrics = [
      {'label': 'Average Deal Size', 'value': '₹45K', 'trend': '+8%', 'isPositive': true},
      {'label': 'Conversion Rate', 'value': '68%', 'trend': '+5%', 'isPositive': true},
      {'label': 'Response Time', 'value': '2.5 hrs', 'trend': '-15%', 'isPositive': true},
      {'label': 'Customer Retention', 'value': '94%', 'trend': '+3%', 'isPositive': true},
    ];
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        children: metrics.map((metric) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    metric['label'] as String,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      metric['value'] as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: NexusTheme.emerald600),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (metric['isPositive'] as bool) 
                          ? Colors.green.withValues(alpha: 0.1) 
                          : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (metric['isPositive'] as bool) ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 12,
                            color: (metric['isPositive'] as bool) ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            metric['trend'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: (metric['isPositive'] as bool) ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildTeamLeaderboard(bool isMobile) {
    final team = [
      {'name': 'Rajesh Kumar', 'score': 98, 'sales': '₹125K', 'rank': 1},
      {'name': 'Priya Sharma', 'score': 95, 'sales': '₹118K', 'rank': 2},
      {'name': 'Amit Patel', 'score': 92, 'sales': '₹110K', 'rank': 3},
      {'name': 'Sneha Reddy', 'score': 88, 'sales': '₹98K', 'rank': 4},
      {'name': 'Vikram Singh', 'score': 85, 'sales': '₹92K', 'rank': 5},
    ];
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        children: team.map((member) {
          final rank = member['rank'] as int;
          final medalColor = rank == 1 ? Colors.amber : rank == 2 ? Colors.grey : rank == 3 ? Colors.brown : null;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: medalColor != null ? medalColor.withValues(alpha: 0.1) : NexusTheme.slate100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: medalColor ?? NexusTheme.slate600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('Sales: ${member['sales']}', style: const TextStyle(fontSize: 11, color: NexusTheme.slate500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: NexusTheme.emerald100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${member['score']}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: NexusTheme.emerald700),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: NexusTheme.emerald500,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    );
  }
}
