import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WarehouseInventoryScreen extends StatefulWidget {
  const WarehouseInventoryScreen({super.key});

  @override
  State<WarehouseInventoryScreen> createState() => _WarehouseInventoryScreenState();
}

class _WarehouseInventoryScreenState extends State<WarehouseInventoryScreen> {
  Order? selectedOrder;
  final Map<String, String> _itemBatches = {};
  final Map<String, int> _packaging = {
    'Small Carton': 0,
    'Large Carton': 0,
    'Ice Gel Packs': 0,
    'Dry Ice (KG)': 0,
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final pendingOrders = provider.orders.where((o) => o.status == 'Pending Packing').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      appBar: AppBar(
        title: Text(selectedOrder == null ? '3. WAREHOUSE OPERATIONS' : 'WMS PACKING TERMINAL', 
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
          : _buildPackingTerminal(selectedOrder!),
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
              child: const Icon(LucideIcons.packageCheck, size: 80, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 24),
            const Text('ALL ORDERS PACKED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const Text('Warehouse dispatch queue is clear.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            title: Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1))),
            subtitle: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            trailing: ElevatedButton(
              onPressed: () => setState(() => selectedOrder = order),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('START PACKING', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackingTerminal(Order order) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMissionHeader(order, isMobile),
              const SizedBox(height: 32),
              
              if (isMobile) ...[
                _buildItemVerificationCard(order),
                const SizedBox(height: 24),
                _buildPackagingConsumptionCard(),
                const SizedBox(height: 24),
                _buildOperationSummary(order),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildItemVerificationCard(order),
                          const SizedBox(height: 24),
                          _buildPackagingConsumptionCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildOperationSummary(order),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissionHeader(Order order, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MISSION REFERENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text(order.id, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              Text('Consignee: ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL LINE ITEMS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  Text('${order.items.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                ],
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MISSION REFERENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                  Text(order.id, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  Text('Consignee: ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    const Text('TOTAL LINE ITEMS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
                    Text('${order.items.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildItemVerificationCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LINE ITEM BATCH VERIFICATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 24),
          ...order.items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          const Icon(LucideIcons.box, size: 20, color: Color(0xFF94A3B8)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                Text('SKU: ${item.skuCode} | Qty: ${item.quantity}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          DropdownButton<String>(
            hint: const Text('Select Batch', style: TextStyle(fontSize: 10)),
            value: _itemBatches[item.skuCode],
            underline: const SizedBox(),
            items: ['B24-001 (Jan 26)', 'B24-005 (Feb 15)'].map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 11)))).toList(),
            onChanged: (val) => setState(() => _itemBatches[item.skuCode] = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagingConsumptionCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PACKAGING MATERIAL CONSUMPTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 24),
          Row(
            children: _packaging.entries.map((e) => Expanded(
              child: _buildPackagingCounter(e.key, e.value),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagingCounter(String label, int count) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => setState(() => _packaging[label] = (count > 0 ? count - 1 : 0)),
              child: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.red),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text('$count', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
            InkWell(
              onTap: () => setState(() => _packaging[label] = count + 1),
              child: const Icon(Icons.add_circle_outline, size: 20, color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationSummary(Order order) {
    final bool allBatched = order.items.every((i) => _itemBatches.containsKey(i.skuCode));
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.shieldCheck, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 12),
              Text('WMS SUMMARY', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 24),
          _buildSummaryRow('Line Items Cleared', '${_itemBatches.length}/${order.items.length}'),
          _buildSummaryRow('Bin Locations Sync', 'ACTIVE'),
          _buildSummaryRow('Temp Controlled', 'YES (-18°C)'),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFF334155)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: allBatched ? () => _finalizePacking(order) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('FINALIZE MISSION PACKING', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
          if (!allBatched)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text('Please select batches for ALL items to proceed.', style: TextStyle(color: Color(0xFFFDA4AF), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
        ],
      ),
    );
  }

  void _finalizePacking(Order order) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final success = await provider.updateOrderStatus(order.id, 'Packed');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission packed and batches committed to inventory!'), backgroundColor: Color(0xFF10B981)));
      setState(() => selectedOrder = null);
    }
  }
}
