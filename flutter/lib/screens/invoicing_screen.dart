import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nexus_provider.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InvoicingScreen extends StatefulWidget {
  const InvoicingScreen({super.key});

  @override
  State<InvoicingScreen> createState() => _InvoicingScreenState();
}

class _InvoicingScreenState extends State<InvoicingScreen> {
  Order? selectedOrder;
  bool isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final pendingOrders = provider.orders.where((o) => o.status == 'Pending Invoicing' || o.status == 'Ready for Billing').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(selectedOrder == null ? '5. REVENUE & BILLING TERMINAL' : 'INVOICE AUDIT TERMINAL', 
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
          ? _buildOrderQueue(pendingOrders)
          : _buildInvoiceTerminal(selectedOrder!),
    );
  }

  Widget _buildOrderQueue(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(LucideIcons.receipt, size: 80, color: Color(0xFF6366F1)),
            ),
            const SizedBox(height: 24),
            const Text('BILLING QUEUE CLEAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const Text('All missions have been accounted.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                title: Row(
                  children: [
                    Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1))),
                    const Spacer(),
                    Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
                subtitle: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                trailing: ElevatedButton(
                  onPressed: () => setState(() => selectedOrder = order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('GENERATE INV', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildInvoiceTerminal(Order order) {
    final double netValue = order.total / 1.18;
    final double gstValue = order.total - netValue;
    final double cgst = gstValue / 2;
    final double sgst = gstValue / 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 1000;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvoiceHeader(order, isMobile),
              const SizedBox(height: 32),
              
              if (isMobile)
                Column(
                  children: [
                    _buildTaxReconciliationCard(netValue, cgst, sgst, order.total),
                    const SizedBox(height: 24),
                    _buildItemizedBillingCard(order),
                    const SizedBox(height: 24),
                    _buildFinalCommitCard(order),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildTaxReconciliationCard(netValue, cgst, sgst, order.total),
                          const SizedBox(height: 24),
                          _buildItemizedBillingCard(order),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildFinalCommitCard(order),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvoiceHeader(Order order, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: isMobile 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PROFORMA INVOICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text('INV-${DateFormat('yyMM').format(DateTime.now())}-${order.id.split('-').last}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
              const Divider(height: 32),
              Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const Text('REVENUE TO BE RECOGNIZED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PROFORMA INVOICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                  Text('INV-${DateFormat('yyMM').format(DateTime.now())}-${order.id.split('-').last}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  Text('Customer: ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('REVENUE TO BE RECOGNIZED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
                  Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildTaxReconciliationCard(double net, double cgst, double sgst, double total) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.fileDigit, color: Color(0xFFFBBF24), size: 20),
              SizedBox(width: 12),
              Text('TAX RECONCILIATION', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 24),
          _buildSummaryRow('Taxable Value (Net)', '₹${NumberFormat('#,##,###.##').format(net)}'),
          _buildSummaryRow('CGST (9%)', '₹${NumberFormat('#,##,###.##').format(cgst)}'),
          _buildSummaryRow('SGST (9%)', '₹${NumberFormat('#,##,###.##').format(sgst)}'),
          const Divider(color: Color(0xFF334155), height: 32),
          _buildSummaryRow('GRAND TOTAL (ROUNDED)', '₹${NumberFormat('#,##,###').format(total)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildItemizedBillingCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ITEMIZED BILLING DETAILS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 24),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Text('${item.quantity} x ₹${item.price}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 24),
                Text('₹${NumberFormat('#,##,###').format(item.quantity * item.price)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFinalCommitCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ERP COMMIT PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 24),
          _buildStatusBit('TALLY COMPLIANCE', true),
          _buildStatusBit('GST PORTAL SYNC', true),
          _buildStatusBit('E-WAY BILL GENERATION', true),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: isSyncing ? null : () => _finalizeInvoice(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: isSyncing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('COMMIT TO ERP & BILL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBit(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(active ? Icons.check_circle : Icons.circle_outlined, size: 16, color: active ? Colors.green : Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? Colors.white : const Color(0xFF94A3B8), fontSize: isBold ? 13 : 11)),
          Text(val, style: TextStyle(color: Colors.white, fontWeight: isBold ? FontWeight.w900 : FontWeight.w900, fontSize: isBold ? 18 : 11)),
        ],
      ),
    );
  }

  void _finalizeInvoice(Order order) async {
    setState(() => isSyncing = true);
    final provider = Provider.of<NexusProvider>(context, listen: false);
    
    // TRIGGER: Digital Invoice Email to Client
    provider.sendEmailNotification(
      recipient: 'billing@${order.customerName.toLowerCase().replaceAll(' ', '')}.com',
      subject: '📄 DIGITAL INVOICE: ${order.id}',
      body: 'Dear Customer,\n\n'
            'Your tax invoice for Mission ${order.id} has been generated and synced to ERP.\n'
            'Total Value: ₹${order.total}\n'
            'Tax Breakdown (GST 18%): ₹${(order.total - (order.total / 1.18)).toStringAsFixed(2)}\n\n'
            'NexusOMS Enterprise',
    );
    
    // Simulate API Delay for ERP Sync
    await Future.delayed(const Duration(seconds: 2));
    
    final success = await provider.updateOrderStatus(order.id, 'Invoiced');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tax Invoice generated and synced to Tally ERP!'), backgroundColor: Color(0xFF10B981)));
      setState(() {
        selectedOrder = null;
        isSyncing = false;
      });
    } else {
       setState(() => isSyncing = false);
    }
  }
}
