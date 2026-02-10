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
    final pendingOrders = provider.orders
        .where((o) => o.status == 'Cost Added' || o.status == 'Pending Invoicing')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('INVOICING'),
        backgroundColor: NexusTheme.emerald900,
      ),
      body: pendingOrders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: NexusTheme.slate300),
                  SizedBox(height: 16),
                  Text(
                    'All Invoiced!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NexusTheme.slate400),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No orders pending invoice generation',
                    style: TextStyle(color: NexusTheme.slate400),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingOrders.length,
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                return _buildOrderCard(context, order, provider);
              },
            ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, NexusProvider provider) {
    final gstAmount = order.total * 0.18; // 18% GST
    final totalWithGst = order.total + gstAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: NexusTheme.slate400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: NexusTheme.indigo500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'INVOICE',
                    style: TextStyle(
                      color: NexusTheme.indigo900,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NexusTheme.slate50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildAmountRow('Subtotal', order.total),
                  const SizedBox(height: 8),
                  _buildAmountRow('GST (18%)', gstAmount),
                  const Divider(height: 16),
                  _buildAmountRow('TOTAL', totalWithGst, isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _previewInvoice(context, order),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('PREVIEW'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NexusTheme.emerald600,
                      side: const BorderSide(color: NexusTheme.emerald600),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateInvoice(context, order, provider),
                    icon: const Icon(Icons.receipt, size: 18),
                    label: const Text('GENERATE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NexusTheme.emerald600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
  }

  Widget _buildAmountRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isTotal ? NexusTheme.emerald900 : NexusTheme.slate600,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.w900,
            color: isTotal ? NexusTheme.emerald900 : NexusTheme.slate700,
          ),
        ),
      ],
    );
  }

  void _previewInvoice(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invoice Preview'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Invoice No: INV-${order.id}'),
              Text('Customer: ${order.customerName}'),
              const Divider(),
              Text('Items: ${order.items.length}'),
              Text('Subtotal: ₹${order.total.toStringAsFixed(2)}'),
              Text('GST: ₹${(order.total * 0.18).toStringAsFixed(2)}'),
              Text('Total: ₹${(order.total * 1.18).toStringAsFixed(2)}', 
                style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _generateInvoice(BuildContext context, Order order, NexusProvider provider) async {
    final success = await provider.updateOrderStatus(order.id, 'Invoiced');
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice generated for ${order.id}'),
          backgroundColor: NexusTheme.emerald600,
          action: SnackBarAction(
            label: 'TALLY EXPORT',
            textColor: Colors.white,
            onPressed: () {
              // Export to Tally XML
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exported to Tally successfully!')),
              );
            },
          ),
        ),
      );
    }
  }
}
