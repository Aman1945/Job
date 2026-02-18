import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../models/models.dart';
import '../widgets/nexus_components.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LogisticsOpsScreen extends StatefulWidget {
  const LogisticsOpsScreen({super.key});

  @override
  State<LogisticsOpsScreen> createState() => _LogisticsOpsScreenState();
}

class _LogisticsOpsScreenState extends State<LogisticsOpsScreen> {
  Order? _selectedOrder;
  final TextEditingController _thermacolQtyController = TextEditingController(text: '0');
  final TextEditingController _thermacolRateController = TextEditingController(text: '300');
  final TextEditingController _dryIceQtyController = TextEditingController(text: '0');
  final TextEditingController _dryIceRateController = TextEditingController(text: '18');
  final TextEditingController _remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final logisticsOrders = provider.orders.where((o) => o.status == 'Pending Logistics Cost').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('4. LOGISTICS COST TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return _selectedOrder == null 
            ? _buildOrderList(logisticsOrders, isMobile)
            : _buildCostMatrix(_selectedOrder!, isMobile);
        },
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, bool isMobile) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(100)),
              child: const Icon(LucideIcons.truck, size: 48, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            const Text('Logistics Queue Clear', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF64748B))),
            const Text('No pending cost definitions.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [BoxShadow(color: const Color(0xFF64748B).withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                    if (!isMobile) ...[
                      const SizedBox(height: 4),
                       Text('Values: ₹${order.total}', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ]
                  ],
                ),
              ),
              Expanded(flex: 3, child: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)))),
              if (!isMobile)
                Expanded(flex: 2, child: NexusComponents.statusBadge('PENDING COST')),
              
              ElevatedButton.icon(
                onPressed: () => setState(() => _selectedOrder = order),
                icon: const Icon(LucideIcons.calculator, size: 14),
                label: const Text('DEFINE COSTS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildCostMatrix(Order order, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: () => setState(() => _selectedOrder = null), icon: const Icon(Icons.arrow_back, color: Color(0xFF64748B))),
              const Text('Back to Queue', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF4338CA)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF4338CA).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
             child: Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                   child: const Icon(LucideIcons.truck, color: Colors.white),
                 ),
                 const SizedBox(width: 16),
                 const Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('Logistics Surcharge Matrix', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                     Text('Calculate ancillary freight costs', style: TextStyle(color: Colors.white70, fontSize: 12)),
                   ],
                 ),
               ],
             ),
          ),
          const SizedBox(height: 32),
          
          isMobile 
            ? Column(children: [
                _buildInputSection(),
                const SizedBox(height: 24),
                _buildSummarySection(order),
              ])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildInputSection()),
                  const SizedBox(width: 32),
                  Expanded(child: _buildSummarySection(order)),
                ],
              )
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!), 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF64748B).withValues(alpha: 0.05), blurRadius: 24)],
      ),
      child: Column(
        children: [
          _buildRowInput('THERMACOL BOXES (WH)', '0 Units', _thermacolQtyController, _thermacolRateController),
          const SizedBox(height: 24),
          _buildRowInput('DRY ICE KG (WH)', '0 KG', _dryIceQtyController, _dryIceRateController),
          const SizedBox(height: 24),
          // Additional mock inputs
          Row(
            children: [
              Expanded(child: _buildStaticInput('WH-STATION (₹)', '0')),
              const SizedBox(width: 16),
              Expanded(child: _buildStaticInput('STAT-HUB (₹)', '0')),
              const SizedBox(width: 16),
              Expanded(child: _buildStaticInput('HUB-DOOR (₹)', '0')),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRowInput(String label, String hint, TextEditingController qtyCtrl, TextEditingController rateCtrl) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextField(
                controller: qtyCtrl,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState((){}),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('RATE (₹)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
               const SizedBox(height: 8),
              TextField(
                controller: rateCtrl,
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                 decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                 keyboardType: TextInputType.number,
                 onChanged: (_) => setState((){}),
              ),
            ],
          ),
        ),
         const SizedBox(width: 16),
         Column(
           crossAxisAlignment: CrossAxisAlignment.end,
           children: [
             const Text('AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
              const SizedBox(height: 8),
             Text('₹${_calculateRow(qtyCtrl, rateCtrl)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF6366F1))),
           ],
         )
      ],
    );
  }

  Widget _buildStaticInput(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
          child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        )
      ],
    );
  }

  Widget _buildSummarySection(Order order) {
    double totalSurcharge = 
      double.parse(_calculateRow(_thermacolQtyController, _thermacolRateController)) + 
      double.parse(_calculateRow(_dryIceQtyController, _dryIceRateController));
      
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), 
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOTAL FREIGHT BURDEN', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text('₹${totalSurcharge.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('RATIO HEALTH', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(totalSurcharge > (order.total * 0.2) ? 'HIGH' : 'NOMINAL', 
                       style: TextStyle(color: totalSurcharge > (order.total * 0.2) ? const Color(0xFFF87171) : const Color(0xFF34D399), fontWeight: FontWeight.w900)),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _remarksController,
          maxLines: 2,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Add operational notes...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _pushToInvoicing(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
                ),
                child: const Text('PUSH TO INVOICING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
              ),
            ),
          ],
        )
      ],
    );
  }

  String _calculateRow(TextEditingController qty, TextEditingController rate) {
    double q = double.tryParse(qty.text) ?? 0;
    double r = double.tryParse(rate.text) ?? 0;
    return (q * r).toStringAsFixed(0);
  }

  void _pushToInvoicing(Order order) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    await provider.updateOrderStatus(order.id, 'Ready for Billing');
    if(mounted) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
         content: const Text('Costs Defined. Pushed to Invoicing (Stage 5).'),
         behavior: SnackBarBehavior.floating,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
         backgroundColor: const Color(0xFF10B981),
       ));
       setState(() => _selectedOrder = null);
    }
  }
}
