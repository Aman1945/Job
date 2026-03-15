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
        _buildOutlineButton('REJECT ORDER', const Color(0xFFE11D48), Icons.cancel_outlined, () => _handleAction('Rejected')),
        const SizedBox(height: 16),
        _buildActionButton('EDIT ORDER', NexusTheme.blue600, Icons.edit_outlined, () => _showEditDialog()),
        const SizedBox(height: 16),
        _buildOutlineButton('CANCEL ALL', Colors.red, Icons.delete_outline, () => _handleAction('Cancelled')),
      ],
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
          setState(() => selectedOrder = updatedOrder);
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
  late List<OrderItem> items;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    items = List.from(widget.order.items);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('EDIT ORDER ITEMS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return Row(
                    children: [
                      Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      IconButton(
                        onPressed: () => setState(() => items[i] = _updateQty(item, -1)),
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                      ),
                      Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => setState(() => items[i] = _updateQty(item, 1)),
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveChanges,
                    child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('SAVE'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  OrderItem _updateQty(OrderItem item, int delta) {
    int newQty = (item.quantity + delta).clamp(1, 999);
    return OrderItem(
      productId: item.productId,
      name: item.name,
      quantity: newQty,
      price: item.price,
      prevRate: item.prevRate,
      imageUrl: item.imageUrl,
      unit: item.unit,
    );
  }

  Future<void> _saveChanges() async {
    setState(() => isSaving = true);
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // Calculate new totals
    double subTotal = items.fold(0, (sum, item) => sum + (item.price * item.quantity));
    double gst = subTotal * 0.18;
    double total = subTotal + gst;

    final success = await provider.updateOrderItems(
      widget.order.id,
      items,
      total: total,
      subTotal: subTotal,
      gstAmount: gst,
      token: auth.token,
    );

    if (success && mounted) {
      final updatedOrder = await provider.fetchOrderById(widget.order.id, token: auth.token);
      if (updatedOrder != null) widget.onSaved(updatedOrder);
      Navigator.pop(context);
    } else {
      if (mounted) setState(() => isSaving = false);
    }
    }
  }
}
