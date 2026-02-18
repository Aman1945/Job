import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LogisticsCostScreen extends StatefulWidget {
  const LogisticsCostScreen({super.key});

  @override
  State<LogisticsCostScreen> createState() => _LogisticsCostScreenState();
}

class _LogisticsCostScreenState extends State<LogisticsCostScreen> {
  Order? selectedOrder;
  final TextEditingController _freightController = TextEditingController();
  final TextEditingController _loadingController = TextEditingController();
  final TextEditingController _insuranceController = TextEditingController();
  bool isProcessing = false;

  @override
  void dispose() {
    _freightController.dispose();
    _loadingController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final pendingOrders = provider.orders.where((o) => o.status == 'Cost Added').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(selectedOrder == null ? '4. LOGISTICS AUDIT TERMINAL' : 'FREIGHT CALCULATION ENGINE', 
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
          : _buildFreightTerminal(selectedOrder!),
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
              child: const Icon(LucideIcons.truck, size: 80, color: Color(0xFF6366F1)),
            ),
            const SizedBox(height: 24),
            const Text('LOGISTICS QUEUE CLEAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const Text('No missions pending freight assignment.', style: TextStyle(color: Colors.grey)),
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
              onPressed: () {
                _freightController.text = '450';
                _loadingController.text = '50';
                _insuranceController.text = '25';
                setState(() => selectedOrder = order);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('CALCULATE COST', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFreightTerminal(Order order) {
    double f = double.tryParse(_freightController.text) ?? 0;
    double l = double.tryParse(_loadingController.text) ?? 0;
    double i = double.tryParse(_insuranceController.text) ?? 0;
    double totalFreight = f + l + i;
    double percentage = order.total > 0 ? (totalFreight / order.total) * 100 : 0;
    bool isHighCost = percentage > 15;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionHeader(order),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildCostInputCard(),
                    const SizedBox(height: 24),
                    _buildVehicleMasterCard(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildLogisticsVerdictCard(order, totalFreight, percentage, isHighCost),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionHeader(Order order) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('OPERATIONAL MISSION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
              Text(order.id, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              Text('Destination: ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('TOTAL ORDER VALUE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
              Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostInputCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GRANULAR FREIGHT BREAKDOWN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 24),
          _buildInputRow('Base Freight (Distance Based)', _freightController),
          _buildInputRow('Loading & Handling Charges', _loadingController),
          _buildInputRow('In-Transit Insurance (Premium)', _insuranceController),
        ],
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            onChanged: (v) => setState(() {}),
            decoration: InputDecoration(
              prefixText: '₹ ',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleMasterCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('APPROVED VEHICLE MASTER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 24),
          _buildVehicleChoice('TATA 407 (Reefer)', '2.5 Ton', active: true),
          const SizedBox(height: 12),
          _buildVehicleChoice('Mahindra Bolero', '1.2 Ton'),
          const SizedBox(height: 12),
          _buildVehicleChoice('Electric Cart', '500 KG'),
        ],
      ),
    );
  }

  Widget _buildVehicleChoice(String name, String cap, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.truck, size: 20, color: active ? const Color(0xFF6366F1) : Colors.grey),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: active ? const Color(0xFF6366F1) : Colors.black))),
          Text(cap, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLogisticsVerdictCard(Order order, double total, double percentage, bool high) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LOGISTICS VERDICT', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 24),
          const Text('TOTAL FREIGHT', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
          Text('₹${NumberFormat('#,##,###').format(total)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: high ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text('${percentage.toStringAsFixed(1)}% OF ORDER VALUE', style: TextStyle(color: high ? Colors.redAccent : Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 48),
          if (high)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.withOpacity(0.3))),
              child: const Row(
                children: [
                  Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 16),
                  SizedBox(width: 12),
                  Expanded(child: Text('HIGH COST ALERT: NOTIFYING ADMIN ANIMESH FOR OVERRIDE.', style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w900))),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: isProcessing ? null : () => _approveFreight(order, high),
              style: ElevatedButton.styleFrom(
                backgroundColor: high ? Colors.redAccent : const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(high ? 'OVERRIDE & APPROVE' : 'APPROVE & BILL', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  void _approveFreight(Order order, bool high) async {
    setState(() => isProcessing = true);
    final provider = Provider.of<NexusProvider>(context, listen: false);
    
    // TRIGGER: High-Cost Alert to Animesh
    if (high) {
      double f = double.tryParse(_freightController.text) ?? 0;
      double l = double.tryParse(_loadingController.text) ?? 0;
      double i = double.tryParse(_insuranceController.text) ?? 0;
      provider.sendEmailNotification(
        recipient: 'animesh@bigsams.in',
        subject: '🚨 LOGISTICS SENTINEL: HIGH-COST ALERT (${order.id})',
        body: 'Mission: ${order.id}\n'
              'Customer: ${order.customerName}\n'
              'Order Value: ₹${order.total}\n'
              'Total Freight: ₹${f+l+i}\n'
              'Alert: Logistics cost is ${( (f+l+i)/order.total * 100 ).toStringAsFixed(1)}% of value. Manual override performed.',
      );
    }

    final success = await provider.updateOrderStatus(order.id, 'Ready for Invoice');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(high ? 'High-cost override recorded. Order ${order.id} cleared!' : 'Freight approved for ${order.id}!'), backgroundColor: Colors.green));
      setState(() {
        selectedOrder = null;
        isProcessing = false;
      });
    } else {
       setState(() => isProcessing = false);
    }
  }
}
