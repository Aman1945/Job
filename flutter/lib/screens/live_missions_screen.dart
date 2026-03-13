import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'order_lifecycle_screen.dart';

class LiveMissionsScreen extends StatefulWidget {
  const LiveMissionsScreen({super.key});

  @override
  State<LiveMissionsScreen> createState() => _LiveMissionsScreenState();
}

class _LiveMissionsScreenState extends State<LiveMissionsScreen> {
  String _searchQuery = '';
  String _activeFilter = 'All Orders';
  Order? _selectedOrder;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final allOrders = provider.orders;
    
    // Filtering logic
    final filteredOrders = allOrders.where((o) {
      final matchesSearch = o.id.contains(_searchQuery) || o.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesFilter = true;
      if (_activeFilter == 'In Transit') matchesFilter = o.status == 'In Transit';
      if (_activeFilter == 'Pending') matchesFilter = o.status.contains('Pending');
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Nexus OMS', style: TextStyle(color: NexusTheme.slate900, fontWeight: FontWeight.w900, fontSize: 18)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: NexusTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'Premium Management',
                style: TextStyle(color: NexusTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Metrics Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildHeaderStats('Daily Volume', '1,284', '+12%', true),
                _buildDivider(),
                _buildHeaderStats('On-Time Rate', '98.2%', '+0.4%', true),
                _buildDivider(),
                _buildHeaderStats('Exceptions', '3 alerts', '-2', false, isNeutral: true),
              ],
            ),
          ),
          
          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NexusTheme.slate200),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search_rounded, color: NexusTheme.slate400),
                      hintText: 'Search Order ID, Client or SKU...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: NexusTheme.slate400, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Chips
                Row(
                  children: [
                    _buildFilterChip('All Orders'),
                    const SizedBox(width: 8),
                    _buildFilterChip('In Transit'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pending'),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => OrderLifecycleScreen(order: order))
                  ),
                  child: _buildOrderCard(order),
                );
              },
            ),
          ),

          // Pagination Info (Mock)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: NexusTheme.slate200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Showing 1 to 4 of 42 orders',
                  style: TextStyle(color: NexusTheme.slate500, fontSize: 12),
                ),
                Row(
                  children: [
                    _buildPageButton('1', isActive: true),
                    const SizedBox(width: 4),
                    _buildPageButton('2'),
                    const SizedBox(width: 4),
                    _buildPageButton('3'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats(String label, String value, String trend, bool isPositive, {bool isNeutral = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: NexusTheme.slate500, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(value, style: const TextStyle(color: NexusTheme.slate900, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(width: 4),
            Text(
              trend,
              style: TextStyle(
                color: isNeutral ? NexusTheme.slate400 : (isPositive ? NexusTheme.success : NexusTheme.error),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: NexusTheme.slate200);
  }

  Widget _buildFilterChip(String label) {
    final isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? NexusTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? NexusTheme.primaryBlue : NexusTheme.slate200),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : NexusTheme.slate600,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    // Generate initials for mock avatar
    final initials = order.customerName.isNotEmpty ? order.customerName.split(' ').map((e) => e[0]).take(2).join().toUpperCase() : '??';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexusTheme.slate200.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: NexusTheme.slate100,
            child: Text(initials, style: const TextStyle(color: NexusTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id.substring(order.id.length - 4)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate900, fontSize: 15),
                ),
                Text(
                  order.customerName,
                  style: const TextStyle(color: NexusTheme.slate500, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(order.status),
              const SizedBox(height: 4),
              const Text('2 hrs ago', style: TextStyle(color: NexusTheme.slate400, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = NexusTheme.success;
    if (status.contains('Pending')) color = NexusTheme.warning;
    if (status == 'Rejected') color = NexusTheme.error;
    if (status == 'In Transit') color = NexusTheme.primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildPageButton(String label, {bool isActive = false}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isActive ? NexusTheme.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? null : Border.all(color: NexusTheme.slate200),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : NexusTheme.slate600,
            fontWeight: FontWeight.bold,
            fontSize: 12,
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(order.customerName.toUpperCase(), 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))
              ),
              const SizedBox(height: 4),
              Text(order.partnerType ?? 'Distributor', 
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))
              ),
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
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final success = await provider.updateOrderStatus(order.id, 'Credit Approved', token: auth.token);
            if (success) setState(() => _selectedOrder = null);
          }),
          const SizedBox(height: 12),
          _buildDetailedButton('PLACE ON HOLD', const Color(0xFFF59E0B), Icons.pause_circle_outline, () async {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final success = await provider.updateOrderStatus(order.id, 'On Hold', token: auth.token);
            if (success) setState(() => _selectedOrder = null);
          }),
          const SizedBox(height: 12),
          _buildDetailedButton('REJECT ORDER', Colors.white, Icons.cancel_outlined, () async {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final success = await provider.updateOrderStatus(order.id, 'Rejected', token: auth.token);
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
  Widget _buildLiveSignal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseCircle(),
          const SizedBox(width: 8),
          const Text('LIVE SIGNAL ACQUIRED', 
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF065F46), letterSpacing: 1)
          ),
        ],
      ),
    );
  }
}

class _PulseCircle extends StatefulWidget {
  @override
  _PulseCircleState createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
      ),
    );
  }
}
