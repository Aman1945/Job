import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class LiveMissionsScreen extends StatefulWidget {
  const LiveMissionsScreen({super.key});

  @override
  State<LiveMissionsScreen> createState() => _LiveMissionsScreenState();
}

class _LiveMissionsScreenState extends State<LiveMissionsScreen> {
  Order? _selectedOrder;
  final TextEditingController _noteController = TextEditingController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Set up auto-sync every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _selectedOrder == null) {
        Provider.of<NexusProvider>(context, listen: false).fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final orders = provider.orders.where((o) => o.status != 'Delivered' && o.status != 'Rejected').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('LIVE MISSIONS TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1000;
          
          if (_selectedOrder == null) {
            return _buildMissionList(orders);
          }

          return isDesktop 
            ? _buildDesktopDetailView(_selectedOrder!, provider) 
            : _buildMobileDetailView(_selectedOrder!, provider);
        },
      ),
    );
  }

  Widget _buildMissionList(List<Order> orders) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Pulse Command Center Hero
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -50,
                  bottom: -50,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(Icons.waves, size: 200, color: Colors.indigo[400]),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 8, 
                          height: 8, 
                          decoration: const BoxDecoration(color: Color(0xFFE11D48), shape: BoxShape.circle)
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Live Pulse Command\nCenter', 
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -1)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('MONITORING ${orders.length} ACTIVE SUPPLY MISSIONS\n(INCLUDING PARTIALS)', 
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.5), letterSpacing: 0.5, height: 1.4)
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${orders.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                              const Text('IN FLIGHT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1)),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.indigo[500]!.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.bolt, color: Color(0xFF818CF8), size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text('ACTIVE MISSIONS DASHBOARD', 
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.5)
                  ),
                ),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('AUTO-SYNC: 5S', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildMissionRow(order);
            },
          ),
          
          // GLOBAL STATUS FEED Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Row(
              children: [
                const Icon(Icons.show_chart_rounded, color: Color(0xFFF43F5E), size: 20),
                const SizedBox(width: 12),
                const Text('GLOBAL STATUS FEED', 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)
                ),
              ],
            ),
          ),

          // Activity Feed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: orders.take(2).map((order) => _buildFeedItem(order)).toList(),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildFeedItem(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
              ),
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFFF1F5F9), const Color(0xFFF8FAFC).withOpacity(0)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.customerName.toUpperCase(), 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.2)
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(order.id, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6366F1))),
                    const SizedBox(width: 10),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    const Text('09:33', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                    children: [
                      const TextSpan(text: 'Status moved to '),
                      TextSpan(
                        text: order.status, 
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionRow(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedOrder = order),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.access_time_rounded, color: Color(0xFF94A3B8), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(order.id, 
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF6366F1))
                            ),
                            const SizedBox(width: 8),
                            if (order.isSTN == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(6)),
                                child: const Text('STN', 
                                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.white)
                                ),
                              ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                              child: Text(order.status.toUpperCase(), 
                                style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Color(0xFF64748B))
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(order.customerName.toUpperCase(), 
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A), letterSpacing: -0.5)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('₹${order.total.toStringAsFixed(0)}', 
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1)
              ),
              const Text('CONSOLIDATED VALUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('JOURNEY PROGRESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                  Text('${(_calculateProgress(order.status) * 100).toInt()}% - ${order.status == 'On Hold' ? 'PAUSED' : 'ON TRACK'}', 
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: order.status == 'On Hold' ? Colors.orange : const Color(0xFF6366F1))
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _calculateProgress(order.status),
                  child: Container(
                    decoration: BoxDecoration(
                      color: order.status == 'On Hold' ? Colors.orange : const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CREDIT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1))),
                  Text('PACKING', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1))),
                  Text('LOGISTICS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1))),
                  Text('BILLING', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1))),
                  Text('FINAL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyProgressBar(double progress) {
    return Container(
      width: double.infinity,
      height: 12,
      decoration: BoxDecoration(
        color: NexusTheme.slate100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: NexusTheme.indigo500,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [BoxShadow(color: NexusTheme.indigo500.withOpacity(0.3), blurRadius: 10)],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: NexusTheme.indigo50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.indigo600, letterSpacing: 0.5)),
    );
  }

  Widget _buildDesktopDetailView(Order order, NexusProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Content Area
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _selectedOrder = null),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('RETURN TO MISSION QUEUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
                  style: TextButton.styleFrom(foregroundColor: NexusTheme.slate400),
                ),
                const SizedBox(height: 48),
                _buildOrderHeroSection(order),
                const SizedBox(height: 40),
                _buildCriticalExposureCard(),
                const SizedBox(height: 40),
                _buildCreditExposureMatrix(order),
                const SizedBox(height: 40),
                _buildIntelligenceInsight(order),
                const SizedBox(height: 40),
                _buildActionPanel(order, provider),
              ],
            ),
          ),
        ),

        // Side Workflow Trace
        Container(
          width: 400,
          color: Colors.white,
          padding: const EdgeInsets.all(60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MISSION WORKFLOW TRACE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 2)),
              const SizedBox(height: 60),
              _buildWorkflowStep('PENDING CREDIT APPROVAL', order.status != 'Pending Credit Approval', order.status == 'Pending Credit Approval'),
              _buildWorkflowStep('ON HOLD', order.status == 'On Hold', order.status == 'On Hold'),
              _buildWorkflowStep('PENDING WH SELECTION', order.status.contains('WH'), order.status == 'Pending WH Selection'),
              _buildWorkflowStep('PENDING PACKING', order.status.contains('Packing'), order.status == 'Pending Packing'),
              _buildWorkflowStep('PENDING LOGISTICS', order.status.contains('Cost') || order.status.contains('Invoicing'), order.status.contains('Cost')),
              _buildWorkflowStep('DELIVERED', order.status == 'Delivered', order.status == 'Delivered'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDetailView(Order order, NexusProvider provider) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeroSection(order),
            const SizedBox(height: 24),
            _buildCreditExposureMatrix(order),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildCriticalExposureCard()),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AVAILABLE\nCREDIT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF6366F1), letterSpacing: 1)),
                        SizedBox(height: 12),
                        Text('₹610,000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF6366F1))),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildActionPanel(order, provider),
            const SizedBox(height: 24),
            _buildIntelligenceInsight(order),
            const SizedBox(height: 24),
            // Workflow Trace
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MISSION WORKFLOW TRACE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                  const SizedBox(height: 48),
                  _buildWorkflowStep('PENDING CREDIT APPROVAL', order.status != 'Pending Credit Approval', order.status == 'Pending Credit Approval'),
                  _buildWorkflowStep('ON HOLD', order.status == 'On Hold', order.status == 'On Hold'),
                  _buildWorkflowStep('PENDING WH SELECTION', order.status.contains('WH'), order.status == 'Pending WH Selection'),
                  _buildWorkflowStep('PENDING PACKING', order.status.contains('Packing'), order.status == 'Pending Packing'),
                  _buildWorkflowStep('PENDING LOGISTICS', order.status.contains('Cost') || order.status.contains('Invoicing'), order.status.contains('Cost')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeroSection(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Column(
        children: [
          _buildStatusBadge(order.status),
          const SizedBox(height: 24),
          Text(order.id, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(order.customerName.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
              ),
              Text(order.partnerType ?? 'Distributor', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 40),
          const Text('ORDER BOOKING VALUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
          const SizedBox(height: 8),
          Text('₹${order.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -2.5)),
        ],
      ),
    );
  }

  Widget _buildCriticalExposureCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF191A0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURRENT\nSTANDING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 14),
              SizedBox(width: 8),
              Expanded(child: Text('CRITICAL\nEXPOSURE\n(15+ DAYS)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditExposureMatrix(Order order) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.amber, size: 24),
                  SizedBox(width: 12),
                  Text('Credit Exposure\nMatrix', 
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.1)
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('FINANCIAL HEALTH REVIEW FOR\n${order.customerName.toUpperCase()}', 
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          clipBehavior: Clip.antiAlias,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFF0F172A)),
            headingRowHeight: 56,
            dataRowHeight: 64,
            horizontalMargin: 20,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Days', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11))),
              DataColumn(label: Text('Limit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11))),
              DataColumn(label: Text('Sec\nChq', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10))),
              DataColumn(label: Text('O/s Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10))),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('30 days', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
                DataCell(Text('₹1,500,000', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
                DataCell(Text('N/A', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF94A3B8)))),
                DataCell(Text('₹890,000', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntelligenceInsight(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.7), size: 18),
              const SizedBox(width: 12),
              const Text('INTELLIGENCE INSIGHT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            order.intelligenceInsight ?? '"**Risk Factor:** The customer maintains a clean payment record with zero overdue amounts, and the small order value poses negligible financial risk relative to their existing balance. **Recommendation:** Approve"',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel(Order order, NexusProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('INTERNAL NOTE / REJECTION REASON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Add internal verification notes...',
                hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                border: InputBorder.none,
              ),
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 32),
          _buildDetailedButton('APPROVE ORDER', const Color(0xFF10B981), Icons.check_circle_outline, () async {
            final success = await provider.updateOrderStatus(order.id, 'Credit Approved');
            if (success) setState(() => _selectedOrder = null);
          }),
          const SizedBox(height: 12),
          _buildDetailedButton('PLACE ON HOLD', const Color(0xFFF59E0B), Icons.pause_circle_outline, () {}),
          const SizedBox(height: 12),
          _buildDetailedButton('REJECT ORDER', Colors.white, Icons.cancel_outlined, () async {
            final success = await provider.updateOrderStatus(order.id, 'Rejected');
            if (success) setState(() => _selectedOrder = null);
          }, isOutlined: true),
        ],
      ),
    );
  }

  Widget _buildDetailedButton(String label, Color color, IconData icon, VoidCallback onTap, {bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: isOutlined ? const Color(0xFFF43F5E) : Colors.white),
        label: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isOutlined ? const Color(0xFFF43F5E) : Colors.white, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: isOutlined ? const BorderSide(color: Color(0xFFFEE2E2), width: 1) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkflowStep(String label, bool isDone, bool isCurrent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFECFDF5) : (isCurrent ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check_circle_outline : (isCurrent ? Icons.bolt_rounded : Icons.circle),
              color: isDone ? const Color(0xFF10B981) : (isCurrent ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
              size: 24,
            ),
          ),
          const SizedBox(width: 24),
          Text(label, 
            style: TextStyle(
              fontSize: 11, 
              fontWeight: FontWeight.w900, 
              color: isDone ? const Color(0xFF10B981) : (isCurrent ? const Color(0xFF0F172A) : const Color(0xFF94A3B8)),
              letterSpacing: 1
            )
          ),
        ],
      ),
    );
  }

  double _calculateProgress(String status) {
    switch (status) {
      case 'Pending Credit Approval': return 0.1;
      case 'On Hold': return 0.1;
      case 'Pending WH Selection': return 0.25;
      case 'Pending Packing': return 0.4;
      case 'Cost Added': return 0.55;
      case 'Pending Invoicing': return 0.7;
      case 'Ready for Dispatch': return 0.85;
      case 'Out for Delivery': return 0.95;
      case 'Delivered': return 1.0;
      case 'In Transit': return 0.5; // For STNs
      default: return 0.1;
    }
  }
}
