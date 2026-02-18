import 'package:flutter/material.dart';
import 'package:nexus_oms_mobile/providers/nexus_provider.dart';
import 'package:nexus_oms_mobile/widgets/nexus_components.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreditControlScreen extends StatefulWidget {
  const CreditControlScreen({super.key});

  @override
  State<CreditControlScreen> createState() => _CreditControlScreenState();
}

class _CreditControlScreenState extends State<CreditControlScreen> {
  Order? selectedOrder;
  final TextEditingController _notesController = TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final pendingOrders = provider.orders.where((o) => o.status == 'Pending Credit Approval').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 for background
      appBar: AppBar(
        title: Text(selectedOrder == null ? 'CREDIT CONTROL QUEUE' : 'MISSION AUDIT TERMINAL',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () {
            if (selectedOrder != null) {
              setState(() => selectedOrder = null);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: selectedOrder == null
          ? _buildOrderQueue(pendingOrders, provider)
          : _buildDetailTerminal(selectedOrder!, provider, authProvider),
    );
  }

  Widget _buildOrderQueue(List<Order> orders, NexusProvider provider) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline, size: 80, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 24),
            const Text('ALL MISSIONS CLEARED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const Text('The credit control queue is currently empty', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Trace Reference ID or Client...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildQueueItem(order);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQueueItem(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        title: Row(
          children: [
            Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981), fontSize: 13)),
            const Spacer(),
            Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const Spacer(),
              _buildSmallBadge('PENDING CREDIT APPROVAL', const Color(0xFFF1F5F9), const Color(0xFF475569)),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => setState(() => selectedOrder = order),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('QUICK VIEW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: textCol, fontWeight: FontWeight.w900, fontSize: 8)),
    );
  }

  Widget _buildDetailTerminal(Order order, NexusProvider provider, AuthProvider authProvider) {
    bool isMobile = MediaQuery.of(context).size.width < 900;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionHeader(order),
          const SizedBox(height: 32),
          if (isMobile) ...[
            _buildCreditMatrixCard(isMobile, order, provider, authProvider),
            const SizedBox(height: 24),
            _buildNotesCard(isMobile),
            const SizedBox(height: 24),
            _buildInsightCard(isMobile),
            const SizedBox(height: 24),
            _buildActionButtons(isMobile),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildCreditMatrixCard(isMobile, order, provider, authProvider),
                      const SizedBox(height: 32),
                      _buildNotesCard(isMobile),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    children: [
                      _buildInsightCard(isMobile),
                      const SizedBox(height: 32),
                      _buildActionButtons(isMobile),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMissionHeader(Order order) {
    bool isMobile = MediaQuery.of(context).size.width < 900;
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSmallBadge('PENDING CREDIT APPROVAL', const Color(0xFFEEF2FF), const Color(0xFF4F46E5)),
                const SizedBox(height: 16),
                Text(order.id, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1, color: Color(0xFF1E293B))),
                Text('${order.customerName} • Distributor', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text('ORDER BOOKING VALUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSmallBadge('PENDING CREDIT APPROVAL', const Color(0xFFEEF2FF), const Color(0xFF4F46E5)),
                    const SizedBox(height: 12),
                    Text(order.id, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: Color(0xFF1E293B))),
                    Text('${order.customerName} • Distributor', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('ORDER BOOKING VALUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                    Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildCreditMatrixCard(bool isMobile, Order order, NexusProvider provider, AuthProvider authProvider) {
    final customer = provider.customers.firstWhere(
      (c) => c.id == order.customerId,
      orElse: () => Customer(id: order.customerId, name: order.customerName, address: '', status: 'Active'),
    );

    final String? role = authProvider.currentUser?.role.label;
    final bool hasAccess = role == 'Admin' || role == 'Credit Control';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CREDIT EXPOSURE MATRIX', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  Text('REAL-TIME FINANCIAL INTEGRITY CHECK', style: TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: Color(0xFF475569)),
                    SizedBox(width: 6),
                    Text('VERIFIED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF475569))),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          if (hasAccess)
            NexusComponents.creditMatrix(customer)
          else
            NexusComponents.restrictedView(),
        ],
      ),
    );
  }

  Widget _buildNotesCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('INTERNAL NOTE / REJECTION REASON', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w900, fontSize: 11)),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add internal verification notes...',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)]),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              const Text('INTELLIGENCE INSIGHT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('"Analyzing payments history... Verdict: POSITIVE. No overdue buckets above 30 days."', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Column(
      children: [
        _buildActionButton('APPROVE ORDER', const Color(0xFF059669), Icons.check_circle_outline, () => _handleAction('Credit Approved')),
        const SizedBox(height: 16),
        _buildActionButton('PLACE ON HOLD', const Color(0xFFF59E0B), Icons.pause_circle_outline, () => _handleAction('On Hold')),
        const SizedBox(height: 16),
        _buildOutlineButton('REJECT ORDER', const Color(0xFFE11D48), Icons.cancel_outlined, () => _handleAction('Rejected')),
      ],
    );
  }

  TableRow _buildMatrixHeaderRow() {
    const headers = [
      'Dist', 'Sales Mgr', 'Class', 'Emp Resp.', 'Credit Days', 
      'Limit', 'Sec Chq', 'O/s Amt', 'OD Amt', 'Diff Ydy',
      '0-7', '7-15', '15-30', '30-45', '45-90', '90-120', '120-150', '150-180', '>180'
    ];
    return TableRow(
      children: headers.map((h) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        alignment: Alignment.center,
        child: Text(h, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
      )).toList(),
    );
  }

  TableRow _buildMatrixDataRow(Customer? customer) {
    if (customer == null) {
      return TableRow(children: List.generate(19, (i) => const SizedBox()));
    }

    final buckets = customer.agingData;
    final data = [
      customer.location ?? '-',
      customer.salesManager ?? '-',
      customer.customerClass ?? '-',
      customer.employeeResponsible ?? '-',
      '30 days',
      '₹${NumberFormat('#,##,###').format(customer.limit)}',
      customer.securityChq,
      '₹${NumberFormat('#,##,###').format(customer.osBalance)}',
      '₹${NumberFormat('#,##,###').format(customer.odAmt)}',
      '₹${NumberFormat('#,##,###').format(customer.diffYesterdayToday)}',
      '₹${NumberFormat('#,##,###').format(buckets['0 to 7'] ?? 0)}',
      '₹${NumberFormat('#,##,###').format(buckets['7 to 15'] ?? 0)}',
      '₹${NumberFormat('#,##,###').format(buckets['15 to 30'] ?? 0)}',
      '₹${NumberFormat('#,##,###').format(buckets['30 to 45'] ?? 0)}',
      '₹${NumberFormat('#,##,###').format(buckets['45 to 90'] ?? 0)}',
      '₹${NumberFormat('#,##,###').format(buckets['90 to 120'] ?? 0)}',
      '₹${NumberFormat('#,##,###').format(buckets['120 to 150'] ?? 0)}',
      '₹${NumberFormat('#,##,###').format(buckets['150 to 180'] ?? 0)}',
      '₹${NumberFormat('#,##,###').format(buckets['>180'] ?? 0)}',
    ];

    return TableRow(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;
        
        // Coloring logic
        Color textCol = Colors.white;
        Color? bgCol;
        
        if (index == 18 && (buckets['>180'] ?? 0) > 0) {
           textCol = Colors.redAccent.shade100;
           bgCol = Colors.redAccent.withOpacity(0.1);
        } else if (index >= 15 && index <= 17 && (data[index] != '₹0')) {
           textCol = Colors.orangeAccent;
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bgCol),
          child: Text(value, textAlign: TextAlign.center, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 10)),
        );
      }).toList(),
    );
  }

  Widget _buildMatrixTable(Customer? customer) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF334155)), 
        borderRadius: BorderRadius.circular(16)
      ),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(), // Dist
          1: IntrinsicColumnWidth(), // Mgr
          2: IntrinsicColumnWidth(), // Class
          3: IntrinsicColumnWidth(), // Emp
          4: IntrinsicColumnWidth(), // Days
        },
        border: TableBorder.all(color: const Color(0xFF334155), width: 1),
        children: [
          _buildMatrixHeaderRow(),
          _buildMatrixDataRow(customer),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(String label, Color color, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: OutlinedButton.icon(
        onPressed: isSubmitting ? null : onPressed,
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  void _handleAction(String newStatus) async {
    if (selectedOrder == null) return;
    setState(() => isSubmitting = true);
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final success = await provider.updateOrderStatus(selectedOrder!.id, newStatus);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mission ${selectedOrder!.id} status updated to $newStatus')));
      setState(() {
        selectedOrder = null;
        isSubmitting = false;
        _notesController.clear();
      });
    } else {
      setState(() => isSubmitting = false);
    }
  }
}
