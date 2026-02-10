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
    _loadData('month');
  }

  Future<void> _loadData([String period = 'month']) async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<NexusProvider>(context, listen: false);
      final data = await provider.fetchPMSData(
        userId: provider.currentUser?.id,
        period: period,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Connection Timeout'),
      );
      if (mounted) {
        setState(() {
          _pmsData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pmsData = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final user = provider.currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: NexusTheme.slate50,
        appBar: AppBar(
          title: const Text('INCENTIVE TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: NexusTheme.slate900),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: NexusTheme.indigo600)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: NexusTheme.slate50,
          appBar: AppBar(
            title: const Text('FEB\'26 INCENTIVE TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: NexusTheme.slate900),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: Column(
              children: [
                _buildIncentiveHeader(user?.name ?? 'Animesh Jamuar', isMobile),
                const SizedBox(height: 32),
                _buildKRAMatrix(isMobile),
                const SizedBox(height: 32),
                if (isMobile) ...[
                  _buildODBalanceMatrix(isMobile),
                  const SizedBox(height: 24),
                  _buildPayoutPolicy(isMobile),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildODBalanceMatrix(isMobile)),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildPayoutPolicy(isMobile)),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncentiveHeader(String name, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark Navy
        borderRadius: BorderRadius.circular(isMobile ? 32 : 50),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(color: NexusTheme.emerald500, borderRadius: BorderRadius.circular(isMobile ? 16 : 24)),
                child: Icon(Icons.calculate_rounded, color: Colors.white, size: isMobile ? 32 : 42),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.split('-')[0].trim().toUpperCase(), style: TextStyle(color: Colors.white, fontSize: isMobile ? 28 : 42, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1)),
                    Text('FEB\'26 INCENTIVE TERMINAL', style: TextStyle(color: NexusTheme.emerald500, fontSize: isMobile ? 10 : 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 32 : 0),
          if (isMobile)
            Column(
              children: [
                _buildHeaderAmountCard('GROSS MONTHLY SALARY', '₹131,089', Colors.white.withOpacity(0.05), Colors.white, isMobile),
                const SizedBox(height: 12),
                _buildHeaderAmountCard('PAYABLE INCENTIVE', '₹32,772.25', NexusTheme.emerald500, Colors.white, isMobile),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                _buildHeaderAmountCard('GROSS MONTHLY SALARY', '₹131,089', Colors.white.withOpacity(0.05), Colors.white, isMobile),
                const SizedBox(width: 16),
                _buildHeaderAmountCard('PAYABLE INCENTIVE', '₹32,772.25', NexusTheme.emerald500, Colors.white, isMobile),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderAmountCard(String label, String value, Color bgColor, Color textColor, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: bgColor == NexusTheme.emerald500 ? null : Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: bgColor == NexusTheme.emerald500 ? [BoxShadow(color: NexusTheme.emerald500.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))] : null,
      ),
      child: Column(
        crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(label, style: TextStyle(color: bgColor == NexusTheme.emerald500 ? Colors.white : Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: isMobile ? 20 : 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildKRAMatrix(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: isMobile 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.track_changes_rounded, color: NexusTheme.indigo600, size: 24),
                        SizedBox(width: 12),
                        Text('KRA ACHIEVEMENT MATRIX', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.2)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildWeightageSumBadge(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.track_changes_rounded, color: NexusTheme.indigo600, size: 28),
                        SizedBox(width: 12),
                        Text('KEY RESULT AREA ACHIEVEMENT MATRIX', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.2)),
                      ],
                    ),
                    _buildWeightageSumBadge(),
                  ],
                ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 60,
              dataRowMinHeight: 80,
              dataRowMaxHeight: 120,
              columnSpacing: isMobile ? 30 : 40,
              horizontalMargin: 24,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate300, letterSpacing: 1),
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('GOAL DESCRIPTION')),
                DataColumn(label: Text('CRITERIA')),
                DataColumn(label: Text('TARGET')),
                DataColumn(label: Text('ACHIEVED')),
                DataColumn(label: Text('WEIGHTAGE')),
                DataColumn(label: Text('FINAL SCORE')),
              ],
              rows: [
                _buildKRAMatrixRow('1', 'Weekly Fresh Salmon Sales (Quantity) including LULU', 'SM BUDGET', '1,232', '1232', '15', '110%', isMobile),
                _buildKRAMatrixRow('2', 'Hyderabad non Retail sales', 'SM BUDGET', '1,625,800', '1625800', '5', '100%', isMobile),
                _buildKRAMatrixRow('3', 'Chennai non Retail sales', 'SM BUDGET', '600,000', '600000', '5', '100%', isMobile),
                _buildKRAMatrixRow('4', 'Monthly visit to Cochin & Chennai, Hyderabad (2 out of 3 locations)', 'STANDARD', '3', '3', '5', '100%', isMobile),
                _buildKRAMatrixRow('5', 'Fresh Salmon Sales - Horeca', 'SM BUDGET', '498,800', '498800', '5', '100%', isMobile),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 40, vertical: isMobile ? 20 : 30),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Row(
              mainAxisAlignment: isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
              children: [
                const Text('TOTAL OPERATIONAL SCORE', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                if (!isMobile) const SizedBox(width: 32),
                Text('110', style: TextStyle(color: Colors.white, fontSize: isMobile ? 36 : 52, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightageSumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFEE2E2))),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 14),
          SizedBox(width: 8),
          Text('WEIGHTAGE SUM: 110 / 100', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  DataRow _buildKRAMatrixRow(String id, String desc, String criteria, String target, String achieved, String weight, String score, bool isMobile) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(color: NexusTheme.slate300, fontWeight: FontWeight.bold))),
      DataCell(Container(
        width: isMobile ? 250 : 350,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(desc, style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold, color: NexusTheme.slate900, height: 1.4)),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: NexusTheme.slate50, borderRadius: BorderRadius.circular(6), border: Border.all(color: NexusTheme.slate100)),
        child: Text(criteria, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
      )),
      DataCell(Text(target, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 13 : 15, color: NexusTheme.slate900))),
      DataCell(Text(achieved, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 13 : 15, color: NexusTheme.slate900))),
      DataCell(Text(weight, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 13 : 15, color: NexusTheme.slate400))),
      DataCell(Text(score, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 13 : 15, color: NexusTheme.emerald500))),
    ]);
  }

  Widget _buildODBalanceMatrix(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, color: NexusTheme.indigo600, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OD BALANCE SCORE MATRIX', style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.2)),
                    const Text('Calculation detail for KRA #9', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (isMobile)
            Column(
              children: [
                _buildLocationBalanceRow('CHENNAI OD', '₹49,562', NexusTheme.indigo500),
                const SizedBox(height: 12),
                _buildLocationBalanceRow('PERSONAL OD', '₹248,920', NexusTheme.emerald500),
                const SizedBox(height: 12),
                _buildLocationBalanceRow('HYD OD', '₹64,977', NexusTheme.amber500),
              ],
            )
          else
            Row(
              children: [
                _buildLocationBalance('CHENNAI OD', '₹49,562', NexusTheme.indigo500),
                const SizedBox(width: 16),
                _buildLocationBalance('PERSONAL OD', '₹248,920', NexusTheme.emerald500),
                const SizedBox(width: 16),
                _buildLocationBalance('HYD OD', '₹64,977', NexusTheme.amber500),
              ],
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL CLOSING BALANCE', style: TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text('₹363,459', style: TextStyle(color: Colors.white, fontSize: isMobile ? 18 : 24, fontWeight: FontWeight.w900)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('SCORE AWARDED', style: TextStyle(color: NexusTheme.emerald500, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text('30', style: TextStyle(color: NexusTheme.emerald500, fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('WEIGHTAGE SLAB PROTOCOL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProtocolItem('UP TO 363...', '30', true),
                const SizedBox(width: 12),
                _buildProtocolItem('UP TO 1.3M', '24', false),
                const SizedBox(width: 12),
                _buildProtocolItem('UP TO 1.9M', '18', false),
                const SizedBox(width: 12),
                _buildProtocolItem('UP TO 2.5M', '12', false),
                const SizedBox(width: 12),
                _buildProtocolItem('UP TO 3.2M', '6', false),
                const SizedBox(width: 12),
                _buildProtocolItem('UP TO 4.0M', '0', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBalanceRow(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildLocationBalance(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolItem(String label, String score, bool isActive) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(color: isActive ? NexusTheme.emerald500.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: isActive ? NexusTheme.emerald500 : NexusTheme.slate100)),
          child: Center(child: Text(score, style: TextStyle(color: isActive ? NexusTheme.emerald500 : NexusTheme.slate300, fontSize: 16, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
      ],
    );
  }

  Widget _buildPayoutPolicy(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.monetization_on_rounded, color: NexusTheme.emerald500, size: 28),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('INCENTIVE PAYOUT POLICY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.2)),
                  Text('Achievement score to currency conversion', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildPolicyRow('1', 'SCORE RANGE', '90% — 95%', 'PAYOUT FACTOR', '10%', false, isMobile),
          const SizedBox(height: 12),
          _buildPolicyRow('2', 'SCORE RANGE', '96% — 100%', 'PAYOUT FACTOR', '15%', false, isMobile),
          const SizedBox(height: 12),
          _buildPolicyRow('3', 'SCORE RANGE', '101% — 105%', 'PAYOUT FACTOR', '20%', false, isMobile),
          const SizedBox(height: 12),
          _buildPolicyRow('4', 'SCORE RANGE', '106% — 110%', 'PAYOUT FACTOR', '25%', true, isMobile),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: NexusTheme.slate900, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL SCORE', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    SizedBox(height: 4),
                    Text('110.0%', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward, color: Colors.white24, size: 16),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('INCENTIVE AMT', style: TextStyle(color: NexusTheme.emerald500, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text('₹32,772.25', style: TextStyle(color: NexusTheme.emerald500.withOpacity(0.9), fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(String id, String label1, String value1, String label2, String value2, bool isActive, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: isActive ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]) : null,
        color: !isActive ? NexusTheme.slate50 : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.indigoAccent : NexusTheme.slate100),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: isActive ? Colors.white.withOpacity(0.2) : Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(id, style: TextStyle(color: isActive ? Colors.white : NexusTheme.slate300, fontWeight: FontWeight.w900, fontSize: 12))),
          ),
          SizedBox(width: isMobile ? 16 : 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: TextStyle(color: isActive ? Colors.white70 : NexusTheme.slate300, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value1, style: TextStyle(color: isActive ? Colors.white : NexusTheme.slate600, fontSize: isMobile ? 13 : 15, fontWeight: FontWeight.w900)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(label2, style: TextStyle(color: isActive ? Colors.white70 : NexusTheme.slate300, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value2, style: TextStyle(color: isActive ? Colors.white : NexusTheme.slate600, fontSize: isMobile ? 15 : 18, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}
