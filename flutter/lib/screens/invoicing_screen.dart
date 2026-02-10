import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class InvoicingScreen extends StatelessWidget {
  const InvoicingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final pendingOrders = provider.orders.where((o) => o.status == 'Cost Added' || o.status == 'Pending Invoicing').toList();
    final invoicedOrders = provider.orders.where((o) => o.status == 'Invoiced' || o.status == 'Ready for Dispatch' || o.status == 'Picked Up' || o.status == 'Delivered').toList();

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('INVOICING TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20.0 : 40.0, 
              vertical: isMobile ? 24.0 : 32.0
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoicing Terminal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -1, height: 1)),
                      const SizedBox(height: 8),
                      const Text('POST-CREDIT REVENUE ACCOUNTING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: NexusTheme.slate400, letterSpacing: 1.5)),
                      const SizedBox(height: 16),
                      _buildDateBadge(),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Invoicing Terminal', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -1, height: 1)),
                          Text('POST-CREDIT REVENUE ACCOUNTING & BILLING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexusTheme.slate400, letterSpacing: 1.5)),
                        ],
                      ),
                      _buildDateBadge(),
                    ],
                  ),
                const SizedBox(height: 32),
                if (isMobile)
                  Column(
                    children: [
                      _buildPendingView(pendingOrders, provider, isMobile),
                      const SizedBox(height: 48),
                      _buildBilledView(invoicedOrders, isMobile),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildPendingView(pendingOrders, provider, isMobile)),
                      const SizedBox(width: 48),
                      Expanded(flex: 2, child: _buildBilledView(invoicedOrders, isMobile)),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: NexusTheme.slate200)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 12, color: NexusTheme.slate400),
          const SizedBox(width: 8),
          Text(DateTime.now().toString().split(' ')[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
        ],
      ),
    );
  }

  Widget _buildPendingView(List<Order> pendingOrders, NexusProvider provider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('AWAITING BILLING', pendingOrders.length, NexusTheme.indigo500),
        const SizedBox(height: 24),
        if (pendingOrders.isEmpty)
          _buildEmptyQueue()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              mainAxisExtent: isMobile ? 180 : 220,
            ),
            itemCount: pendingOrders.length,
            itemBuilder: (context, index) => _buildPendingOrderCard(context, pendingOrders[index], provider, isMobile),
          ),
      ],
    );
  }

  Widget _buildBilledView(List<Order> invoicedOrders, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('BILLED RECORDS', invoicedOrders.length, NexusTheme.slate900),
        const SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))],
          ),
          child: Column(
            children: [
              if (invoicedOrders.isEmpty)
                _buildNoHistory()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: invoicedOrders.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05), height: 32),
                  itemBuilder: (context, index) => _buildHistoryCard(invoicedOrders[index]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: 1.5)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('$count ITEMS', style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ),
      ],
    );
  }

  Widget _buildEmptyQueue() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40), border: Border.all(color: NexusTheme.slate100)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: NexusTheme.slate50, shape: BoxShape.circle), child: const Icon(Icons.receipt_long_outlined, color: NexusTheme.slate200, size: 48)),
            const SizedBox(height: 24),
            const Text('BILLING QUEUE CLEAR', style: TextStyle(color: NexusTheme.slate300, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoHistory() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Text('NO BILLED RECORDS FOUND', style: TextStyle(color: Colors.white12, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.5)),
      ),
    );
  }

  Widget _buildPendingOrderCard(BuildContext context, Order order, NexusProvider provider, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(32), 
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400, letterSpacing: 0.5)),
              const Icon(Icons.more_vert, color: NexusTheme.slate300, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.customerName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 16 : 18, color: NexusTheme.slate800, height: 1.2)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL AMT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: NexusTheme.slate400, letterSpacing: 0.5)),
              Text('₹${order.total.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 18 : 20, color: NexusTheme.slate900)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _generateInvoice(context, order, provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: NexusTheme.indigo600, 
                foregroundColor: Colors.white, 
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
                padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20)
              ),
              child: const Text('ISSUE INVOICE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Order order) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.description, color: NexusTheme.emerald400, size: 18),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INV-26-${order.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(order.customerName, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Text('₹${(order.total/1000).toStringAsFixed(1)}K', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }

  void _generateInvoice(BuildContext context, Order order, NexusProvider provider) async {
    final success = await provider.updateOrderStatus(order.id, 'Invoiced');
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 12),
            Text('Invoice issued for ${order.id} successfully'),
          ],
        ), 
        backgroundColor: NexusTheme.emerald500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ));
  }}
}
