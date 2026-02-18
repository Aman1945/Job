import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DeliveryExecutionScreen extends StatefulWidget {
  const DeliveryExecutionScreen({super.key});

  @override
  State<DeliveryExecutionScreen> createState() => _DeliveryExecutionScreenState();
}

class _DeliveryExecutionScreenState extends State<DeliveryExecutionScreen> {
  Order? selectedOrder;
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  bool isClearing = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final deliveryQueue = provider.orders.where((o) => o.status == 'Out for Delivery' || o.status == 'In Transit').toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate for Field Terminal
      appBar: AppBar(
        title: Text(selectedOrder == null ? '7. FIELD EXECUTION TERMINAL' : 'MISSION HANDOVER', 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
          ? _buildDeliveryQueue(deliveryQueue)
          : _buildHandoverTerminal(selectedOrder!),
    );
  }

  Widget _buildDeliveryQueue(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
              child: const Icon(LucideIcons.home, size: 80, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 24),
            const Text('ALL MISSIONS DELIVERED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
            const Text('Field queue is currently clear.', style: TextStyle(color: Colors.grey)),
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
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            title: Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF38BDF8))),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(order.deliveryAddress ?? 'Location Pending', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => setState(() => selectedOrder = order),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('ARRIVED', style: TextStyle(color: Color(0xFF0F172A), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandoverTerminal(Order order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionBrief(order),
          const SizedBox(height: 32),
          _buildEPODCard(),
          const SizedBox(height: 24),
          _buildPaymentReconciliationCard(order),
          const SizedBox(height: 32),
          _buildHandoverAction(order),
        ],
      ),
    );
  }

  Widget _buildMissionBrief(Order order) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MISSION DEBRIEF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Text(order.customerName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: Color(0xFF38BDF8)),
              const SizedBox(width: 8),
              Expanded(child: Text(order.deliveryAddress ?? 'N/A', style: const TextStyle(color: Colors.grey, fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEPODCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('E-POD (PROOF OF DELIVERY)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildHandoverButton(LucideIcons.camera, 'PHOTO CAPTURE', true)),
              const SizedBox(width: 16),
              Expanded(child: _buildHandoverButton(LucideIcons.penTool, 'SIGNATURE', true)),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 8),
            decoration: InputDecoration(
              hintText: 'VERIFY OTP',
              hintStyle: const TextStyle(color: Colors.white12, letterSpacing: 1, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentReconciliationCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PAYMENT RECONCILIATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL CASH TO COLLECT', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _cashController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
              hintText: 'Enter Cash Collected',
              hintStyle: const TextStyle(color: Colors.white12, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandoverButton(IconData icon, String label, bool active) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active ? const Color(0xFF10B981) : Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: active ? const Color(0xFF10B981) : Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildHandoverAction(Order order) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        onPressed: isClearing ? null : () => _finalizeMission(order),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: isClearing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('DELIVER & CLOSE MISSION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  void _finalizeMission(Order order) async {
    if (_otpController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid 4-digit OTP'), backgroundColor: Colors.red));
      return;
    }
    
    setState(() => isClearing = true);
    final provider = Provider.of<NexusProvider>(context, listen: false);
    
    // TRIGGER: EPOD Statement to Hub
    provider.sendEmailNotification(
      recipient: 'logistics.hub@bigsams.in',
      subject: '🏁 MISSION COMPLETED: ${order.id}',
      body: 'Mission ${order.id} for ${order.customerName} has been successfully delivered.\n\n'
            'E-POD DETAILS:\n'
            '- Status: Delivered\n'
            '- Handover: OTP Verified\n'
            '- Proof: Signature & Photo Captured\n'
            '- Cash Collected: ₹${_cashController.text}\n\n'
            'Field Executive Terminal',
    );

    // Final status update
    final success = await provider.updateOrderStatus(order.id, 'Delivered');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission Accomplished! E-POD synced to Hub.'), backgroundColor: Color(0xFF10B981)));
      setState(() {
        selectedOrder = null;
        isClearing = false;
        _otpController.clear();
        _cashController.clear();
      });
    } else {
      setState(() => isClearing = false);
    }
  }
}
