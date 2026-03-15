import 'package:flutter/material.dart';
import 'package:nexus_oms_mobile/providers/nexus_provider.dart';
import 'package:nexus_oms_mobile/widgets/nexus_components.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'mission_audit_detail_screen.dart';

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981), fontSize: 13)),
                const Spacer(),
                Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildSmallBadge('PENDING CREDIT APPROVAL', const Color(0xFFF1F5F9), const Color(0xFF475569)),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => setState(() => selectedOrder = order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('QUICK VIEW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MissionAuditDetailScreen(order: order)),
                  ).then((_) => Provider.of<NexusProvider>(context, listen: false).fetchOrders(token: Provider.of<AuthProvider>(context, listen: false).token));
                },
                icon: const Icon(LucideIcons.arrowRight, size: 14, color: Colors.white),
                label: const Text('FULL AUDIT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
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
        Row(
          children: [
            Expanded(
              child: _buildSmallActionButton(
                'APPROVE MISSION',
                NexusTheme.emerald500,
                LucideIcons.checkCircle,
                () => _handleAction('Credit Approved'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallActionButton(
                'HOLD MISSION',
                NexusTheme.amber500,
                LucideIcons.pauseCircle,
                () => _handleAction('Hold'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          'EDIT SUPPLY MISSION',
          NexusTheme.indigo600,
          LucideIcons.edit3,
          () => _showEditDialog(),
        ),
        const SizedBox(height: 16),
        _buildOutlineButton(
          'REJECT / CANCEL MISSION',
          NexusTheme.rose600,
          LucideIcons.xCircle,
          () => _handleAction('Cancelled'),
        ),
      ],
    );
  }

  Widget _buildSmallActionButton(String label, Color color, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.updateOrderStatus(selectedOrder!.id, newStatus, token: auth.token);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mission ${selectedOrder!.id} status updated to $newStatus')));
      setState(() {
        selectedOrder = null;
        isSubmitting = false;
        _notesController.clear();
      });
    } else {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _showEditDialog() {
    if (selectedOrder == null) return;
    showDialog(
      context: context,
      builder: (context) => _EditOrderDialog(
        order: selectedOrder!,
        onSaved: (updatedOrder) {
          setState(() {
            selectedOrder = updatedOrder; // Update with fresh data instead of nulling
            isSubmitting = false;
          });
        },
      ),
    );
  }
}

class _EditOrderDialog extends StatefulWidget {
  final Order order;
  final Function(Order) onSaved;
  const _EditOrderDialog({required this.order, required this.onSaved});

  @override
  State<_EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<_EditOrderDialog> {
  late List<Map<String, dynamic>> items;
  late List<TextEditingController> qtyControllers;
  late List<TextEditingController> rateControllers;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    items = widget.order.items.map((i) => {
      'productId': i.productId,
      'skuCode': i.skuCode,
      'name': i.productName,
      'quantity': i.quantity,
      'boxCount': (i.boxCount == null || i.boxCount == 0) ? 1 : i.boxCount,
      'price': i.price,
      'prevRate': i.prevRate, // Added prevRate from existing order item
      'unit': i.unit ?? 'KG',
    }).toList();

    qtyControllers = items.map((i) => TextEditingController(text: i['quantity'].toString())).toList();
    rateControllers = items.map((i) => TextEditingController(text: i['price'].toString())).toList();
  }

  @override
  void dispose() {
    for (var c in qtyControllers) {
      c.dispose();
    }
    for (var c in rateControllers) {
      c.dispose();
    }
    super.dispose();
  }

  double get _revisedTotal {
    double total = 0;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final qty = int.tryParse(qtyControllers[i].text) ?? (item['quantity'] as num);
      final rate = double.tryParse(rateControllers[i].text) ?? (item['price'] as num).toDouble();
      final box = (item['boxCount'] as num? ?? 1);
      final boxMultiplier = box == 0 ? 1 : box;
      total += rate * qty * boxMultiplier * 1.18;
    }
    return total;
  }

  void _addNewLine() {
    setState(() {
      items.add({
        'skuCode': '',
        'name': 'Select SKU...',
        'quantity': 1,
        'price': 0.0,
        'unit': 'KG',
      });
      qtyControllers.add(TextEditingController(text: '1'));
      rateControllers.add(TextEditingController(text: '0.0'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final products = provider.products;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: 1000,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(32),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top app-bar style row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: NexusTheme.slate900),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'EDIT SUPPLY MISSION',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.5,
                            color: NexusTheme.slate900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 28,
                        decoration: BoxDecoration(
                          color: NexusTheme.amber500,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 0.6, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 20),
                  // Header (Only show if not cramped)
                  if (constraints.maxWidth > 600)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(flex: 4, child: Text('PRODUCT / SKU', style: _headerStyle)),
                          Expanded(flex: 1, child: Text('QTY', style: _headerStyle, textAlign: TextAlign.center)),
                          Expanded(flex: 1, child: Text('UNIT', style: _headerStyle, textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text('RATE', style: _headerStyle, textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text('TOTAL', style: _headerStyle, textAlign: TextAlign.right)),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Item List - Use Column since parent is scrollable
                  Column(
                    children: items.asMap().entries.map((entry) => _buildItemRow(entry.key, entry.value, products, constraints.maxWidth)).toList(),
                  ),
                  const SizedBox(height: 18),
                  // Add New Item Button — soft dashed-style block
                  GestureDetector(
                    onTap: _addNewLine,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 16, color: NexusTheme.slate400),
                          SizedBox(width: 8),
                          Text(
                            'ADD NEW ITEM LINE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color: NexusTheme.slate400,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Reject / Cancel inline action
                  Center(
                    child: TextButton(
                      onPressed: isSaving ? null : () => Navigator.pop(context),
                      child: const Text(
                        'REJECT / CANCEL MISSION',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                          color: NexusTheme.rose600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 0.6, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 20),
                  // Footer
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'REVISED VALUATION',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                color: NexusTheme.slate400,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${NumberFormat('#,##,###').format(_revisedTotal)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: NexusTheme.slate900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF635BFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            ),
                            child: Text(
                              isSaving ? '...' : 'COMMIT CHANGES',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  TextStyle get _headerStyle => const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5);

  Widget _buildItemRow(int index, Map<String, dynamic> item, List<Product> products, double maxWidth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PRODUCT / SKU', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Product>(
                            isExpanded: true,
                            hint: Text(item['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: NexusTheme.slate800)),
                            items: products.map((p) => DropdownMenuItem(
                              value: p,
                              child: Text('${p.skuCode} - ${p.name}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            )).toList(),
                            onChanged: (p) {
                              if (p != null) {
                                setState(() {
                                  item['skuCode'] = p.skuCode;
                                  item['name'] = p.name;
                                  item['price'] = p.price > 0 ? p.price : (p.mrp ?? 0.0);
                                  rateControllers[index].text = item['price'].toString();
                                  
                                  // Fetch last rate for new selection
                                  final provider = Provider.of<NexusProvider>(context, listen: false);
                                  final auth = Provider.of<AuthProvider>(context, listen: false);
                                  provider.fetchLastRate(widget.order.customerId, p.skuCode, token: auth.token).then((rate) {
                                    if (mounted) setState(() => item['prevRate'] = rate);
                                  });
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Read-only chip showing package quantity (boxes) selected by sales
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'PKG QTY: ${ (item['boxCount'] == null || item['boxCount'] == 0) ? 1 : item['boxCount'] }',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => setState(() {
                    if (index < items.length) {
                      items.removeAt(index);
                      qtyControllers[index].dispose();
                      rateControllers[index].dispose();
                      qtyControllers.removeAt(index);
                      rateControllers.removeAt(index);
                    }
                  }),
                  icon: const Icon(LucideIcons.minusCircle, color: NexusTheme.rose600, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildEditableField('QTY', qtyControllers[index], (val) {
                  setState(() {
                    item['quantity'] = int.tryParse(val) ?? item['quantity'];
                  });
                }),
                const SizedBox(width: 12),
                _buildEditableField('RATE', rateControllers[index], (val) {
                  setState(() {
                    item['price'] = double.tryParse(val) ?? item['price'];
                  });
                }),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PREV. RATE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.indigo600)),
                      const SizedBox(height: 6),
                      Text('₹${(item['prevRate'] ?? 0.0).toStringAsFixed(2)}', 
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: NexusTheme.indigo600)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('LINE TOTAL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
                      Builder(
                        builder: (_) {
                          final qty = int.tryParse(qtyControllers[index].text) ?? (item['quantity'] as num);
                          final rate = double.tryParse(rateControllers[index].text) ?? (item['price'] as num).toDouble();
                          final box = (item['boxCount'] as num? ?? 1);
                          final boxMultiplier = box == 0 ? 1 : box;
                          final lineTotal = rate * qty * boxMultiplier;
                          return Text(
                            '₹${lineTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: NexusTheme.indigo600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, Function(String) onChanged) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
          const SizedBox(height: 4),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            controller: controller,
            onChanged: (val) {
              // Update backing map then force UI to refresh totals
              onChanged(val);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => isSaving = true);
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // Map back to OrderItem
    final List<OrderItem> orderItems = items.map((i) => OrderItem(
      productId: i['productId'],
      skuCode: i['skuCode'],
      productName: i['name'],
      quantity: i['quantity'],
      boxCount: (i['boxCount'] == null || i['boxCount'] == 0) ? 1 : i['boxCount'],
      price: i['price'].toDouble(),
      prevRate: (i['prevRate'] ?? 0.0).toDouble(),
      unit: i['unit'],
    )).toList();

    double subTotal = orderItems.fold(0, (sum, item) => sum + (item.price * item.quantity * (item.boxCount ?? 1)));
    double gst = subTotal * 0.18;
    double total = subTotal + gst;

    try {
      final success = await provider.updateOrderItems(
        widget.order.id,
        orderItems,
        total: total,
        subTotal: subTotal,
        gstAmount: gst,
        token: auth.token,
      );

      if (success && mounted) {
        // Fetch fresh order data to update the details terminal
        await provider.fetchOrders(token: auth.token);
        final freshOrder = provider.orders.firstWhere((o) => o.id == widget.order.id, orElse: () => widget.order);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Mission ${widget.order.id} updated successfully'),
            backgroundColor: NexusTheme.emerald500,
          ));
          widget.onSaved(freshOrder);
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to update items. Check your connection.'),
            backgroundColor: NexusTheme.rose600,
          ));
          setState(() => isSaving = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: NexusTheme.rose600,
        ));
        setState(() => isSaving = false);
      }
    }
  }
}

