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
  Map<String, dynamic>? _pmsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final data = await provider.fetchPMSData(
      userId: provider.currentUser?.id,
      period: _selectedPeriod.toLowerCase().replaceAll(' ', '-'),
    );
    if (mounted) {
      setState(() {
        _pmsData = data;
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final user = provider.currentUser;
    final isAdmin = user?.id == 'admin@nexus.com';
    
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final performance = _pmsData?['userPerformance'] ?? {};
    final kpis = _pmsData?['kpis'] ?? {};
    final leaderboard = (_pmsData?['leaderboard'] as List? ?? []);

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('PERFORMANCE MANAGEMENT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                _buildUserPerformanceCard(user?.name ?? 'User', performance, isMobile),
                const SizedBox(height: 24),
                
                // Period Selector
                _buildPeriodSelector(isMobile),
                const SizedBox(height: 24),
                
                // KPI Dashboard
                _buildSectionHeader('KEY PERFORMANCE INDICATORS'),
                const SizedBox(height: 16),
                _buildKPIDashboard(kpis, isMobile),
                const SizedBox(height: 24),
                
                // Sales Targets
                _buildSectionHeader('SALES TARGETS'),
                const SizedBox(height: 16),
                _buildSalesTargets(performance, isMobile),
                const SizedBox(height: 24),
                
                // Team Leaderboard (Admin Only)
                if (isAdmin) ...[
                  _buildSectionHeader('TEAM LEADERBOARD'),
                  const SizedBox(height: 16),
                  _buildTeamLeaderboard(leaderboard, isMobile),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildUserPerformanceCard(String userName, Map<String, dynamic> performance, bool isMobile) {
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
            color: NexusTheme.emerald500.withOpacity(0.3),
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
                  color: Colors.white.withOpacity(0.2),
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ACTIVE PERFORMER',
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
                child: _buildPerformanceMetric('Score', '${performance['score'] ?? 0}/100', Icons.star, isMobile),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPerformanceMetric('Rank', '#${performance['rank'] ?? 'N/A'}', Icons.emoji_events, isMobile),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPerformanceMetric('Sales', '₹${((performance['sales'] ?? 0)/1000).toStringAsFixed(1)}K', Icons.trending_up, isMobile),
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
        color: Colors.white.withOpacity(0.15),
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
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodSelector(bool isMobile) {
    final periods = ['This Month', 'Last 6 Months', 'This Quarter', 'This Year'];
    
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
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPeriod = value);
                  _loadData();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildKPIDashboard(Map<String, dynamic> kpis, bool isMobile) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: isMobile ? 12 : 16,
      crossAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: isMobile ? 1.3 : 1.5,
      children: [
        _buildKPICard('Orders Completed', '${kpis['ordersCompleted'] ?? 0}', 100, Colors.green, isMobile),
        _buildKPICard('Response Time', '${kpis['responseTime'] ?? 0} hrs', 85.0, Colors.blue, isMobile),
        _buildKPICard('Customer Sat.', '${kpis['customerSatisfaction'] ?? 0}/5', 96.0, Colors.purple, isMobile),
        _buildKPICard('Target Achievement', '${kpis['targetAchievement'] ?? 0}%', (double.tryParse(kpis['targetAchievement']?.toString() ?? '0') ?? 0), Colors.orange, isMobile),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
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
                  value: percentage / 100.0,
                  minHeight: 6,
                  backgroundColor: NexusTheme.slate100,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSalesTargets(Map<String, dynamic> performance, bool isMobile) {
    final totalSales = (performance['sales'] ?? 0).toDouble();
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
              value: achievement / 100.0,
              minHeight: 12,
              backgroundColor: NexusTheme.slate100,
              valueColor: const AlwaysStoppedAnimation<Color>(NexusTheme.emerald500),
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
  
  Widget _buildTeamLeaderboard(List<dynamic> leaderboard, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        children: leaderboard.map((member) {
          final index = leaderboard.indexOf(member) + 1;
          final medalColor = index == 1 ? Colors.amber : index == 2 ? Colors.grey : index == 3 ? Colors.brown : null;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: medalColor != null ? medalColor.withOpacity(0.1) : NexusTheme.slate100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '#$index',
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
                      Text(member['name']?.toString() ?? 'User', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('Sales: ₹${((member['sales'] ?? 0)/1000).toStringAsFixed(1)}K', style: const TextStyle(fontSize: 11, color: NexusTheme.slate500)),
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
                    '${member['score'] ?? 0}',
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
