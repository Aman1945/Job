import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class WarehousePackingScreen extends StatefulWidget {
  const WarehousePackingScreen({super.key});

  @override
  State<WarehousePackingScreen> createState() => _WarehousePackingScreenState();
}

class _WarehousePackingScreenState extends State<WarehousePackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NexusProvider>(context, listen: false).fetchOrders();
    });
  }

  // Map to track checked items: { orderId: [checkedIndex1, checkedIndex2, ...] }
  final Map<String, Set<int>> _checkedItems = {};

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final orders = provider.orders.where((o) => o.status == 'Pending Packing').toList();

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('Packing & Fulfillment', 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: NexusTheme.slate900)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: NexusTheme.slate900),
        actions: [
          IconButton(icon: const Icon(LucideIcons.refreshCw), onPressed: () => provider.refreshData()),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: NexusTheme.emerald500, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                const Text('LIVE', style: TextStyle(color: NexusTheme.emerald600, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(width: 12),
                Text('${orders.length} orders ready for packing', 
                  style: const TextStyle(color: NexusTheme.slate500, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: orders.length,
              itemBuilder: (context, index) => _buildPackingCard(orders[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackingCard(Order order) {
    _checkedItems.putIfAbsent(order.id, () => {});
    final checkedSet = _checkedItems[order.id]!;
    final allChecked = checkedSet.length == order.items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [
          BoxShadow(color: NexusTheme.slate900.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start, // Align top
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: const TextStyle(color: NexusTheme.emerald600, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
                      const SizedBox(height: 8), // Increased space "niche lele thoda"
                      Text(
                        order.customerName, 
                        style: const TextStyle(color: NexusTheme.slate900, fontSize: 18, fontWeight: FontWeight.w900, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: NexusTheme.slate100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildSmallActionButton(LucideIcons.edit3, NexusTheme.blue600, () => _editAssignment(order)),
                      const SizedBox(width: 8),
                      _buildSmallActionButton(LucideIcons.trash2, NexusTheme.rose600, () => _cancelAssignment(order)),
                      const SizedBox(width: 12),
                      const Text('WH: WH001', style: TextStyle(color: NexusTheme.slate500, fontSize: 10, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: NexusTheme.slate100, height: 1),
          
          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => const Divider(color: NexusTheme.slate100, height: 1),
            itemBuilder: (context, idx) {
              final item = order.items[idx];
              final isChecked = checkedSet.contains(idx);
              
              // Mock batch info if missing
              final batch = item.allocatedBatches.isNotEmpty ? item.allocatedBatches.first.batchNumber : 'B240104';
              final expiry = item.allocatedBatches.isNotEmpty 
                  ? DateFormat('yyyy-MM-dd').format(item.allocatedBatches.first.expiry) 
                  : '2024-02-12';

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isChecked) checkedSet.remove(idx);
                    else checkedSet.add(idx);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: isChecked ? NexusTheme.emerald500 : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isChecked ? NexusTheme.emerald500 : NexusTheme.slate300, width: 1.5),
                        ),
                        child: isChecked ? const Icon(LucideIcons.check, size: 12, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: TextStyle(color: isChecked ? NexusTheme.slate400 : NexusTheme.slate900, fontSize: 14, fontWeight: FontWeight.bold, decoration: isChecked ? TextDecoration.lineThrough : null)),
                            const SizedBox(height: 4),
                            Text('${item.quantity} KG • Batch: $batch • Exp: $expiry', 
                              style: TextStyle(color: NexusTheme.slate500, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Footer Action
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: allChecked ? () => _pushToQC(order) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusTheme.emerald600,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: NexusTheme.slate100,
                  disabledForegroundColor: NexusTheme.slate300,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('PACKING COMPLETE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                    SizedBox(width: 8),
                    Icon(LucideIcons.arrowRight, size: 16),
                    SizedBox(width: 8),
                    Text('SEND TO QC', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pushToQC(Order order) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await provider.updateOrderStatus(order.id, 'Pending Quality Control', token: auth.token);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order ${order.id} sent to Quality Control'),
        backgroundColor: NexusTheme.emerald600,
        behavior: SnackBarBehavior.floating,
      ));
      setState(() {
        _checkedItems.remove(order.id);
      });
    }
  }

  Widget _buildSmallActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Future<void> _editAssignment(Order order) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Move back to Pending WH Selection
    final success = await provider.updateOrderStatus(order.id, 'Pending WH Selection', token: auth.token);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order ${order.id} moved back to Warehouse Selection')));
    }
  }

  Future<void> _cancelAssignment(Order order) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Cancel the order
    final success = await provider.updateOrderStatus(order.id, 'Cancelled', token: auth.token);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order ${order.id} cancelled')));
    }
  }
}
