import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../widgets/nexus_components.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String? _aiInsight;
  bool _isInsightLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAiInsight();
  }

  Future<void> _fetchAiInsight() async {
    setState(() => _isInsightLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ai/credit-insight'),
        headers: authProvider.authHeaders,
        body: jsonEncode({
          'customerId': widget.order.customerId,
          'customerName': widget.order.customerName,
          'orderValue': widget.order.total,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiInsight = data['insight'];
          _isInsightLoading = false;
        });
      } else {
        setState(() {
          _aiInsight = "No AI insight available at this moment.";
          _isInsightLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiInsight = "Failed to load AI Credit Insight.";
        _isInsightLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final customer = provider.customers.firstWhere(
      (c) => c.id == widget.order.customerId, 
      orElse: () => Customer(id: '', name: 'Unknown', address: '', city: 'NA', status: 'Inactive')
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('LIVE MISSION TRACKER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: NexusTheme.indigo600),
            onPressed: () {
              provider.downloadReport(type: 'Invoice ${widget.order.id}', format: 'pdf');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading Invoice PDF...')),
              );
            },
            tooltip: 'Download Invoice PDF',
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(widget.order),
            const SizedBox(height: 24),

            _buildSectionTitle('⚡ 2. Credit Exposure Matrix', 'FINANCIAL HEALTH REVIEW FOR ${widget.order.customerName}'),
            const SizedBox(height: 16),
            if (authProvider.currentUser?.role.label == 'Admin' || authProvider.currentUser?.role.label == 'Credit Control')
              NexusComponents.creditMatrix(customer)
            else
              NexusComponents.restrictedView(),
            const SizedBox(height: 24),

            // AI CREDIT INSIGHT CARD
            _buildSectionTitle('🤖 AI CREDIT INTELLIGENCE', 'GEMINI POWERED RISK ASSESSMENT'),
            const SizedBox(height: 16),
            _buildAiInsightCard(),
            const SizedBox(height: 24),

            _buildActionPanel(context, widget.order),
            if (authProvider.currentUser?.role.label == 'Admin') ...[
              const SizedBox(height: 24),
              _buildAdminBypassPanel(context, widget.order),
            ],
            const SizedBox(height: 24),

            _buildSectionTitle('MISSION WORKFLOW TRACE', ''),
            const SizedBox(height: 16),
            _buildWorkflowTrace(widget.order),
          ],
        ),
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'AI RISK ASSESSMENT',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isInsightLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            Text(
              _aiInsight ?? "Analyzing credit risk...",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: NexusTheme.indigo50, borderRadius: BorderRadius.circular(8)),
                child: Text(order.status.toUpperCase(), style: const TextStyle(color: NexusTheme.indigo600, fontWeight: FontWeight.w900, fontSize: 9)),
              ),
              const SizedBox(height: 12),
              Text(order.id, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
              Text('${order.customerName} • Distributor', style: const TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('ORDER BOOKING VALUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: NexusTheme.slate400)),
              Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
        if (subtitle.isNotEmpty)
          Text(subtitle.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildActionPanel(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: NexusTheme.slate200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('INTERNAL NOTE / REJECTION REASON', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: NexusTheme.slate400)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(20)),
            child: const Text('Add internal verification notes...', style: TextStyle(color: NexusTheme.slate400, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          _buildActionButton(Icons.check_circle_outline, 'APPROVE ORDER', const Color(0xFF059669), () {
             Provider.of<NexusProvider>(context, listen: false).updateOrderStatus(order.id, 'Credit Approved');
             Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildAdminBypassPanel(BuildContext context, Order order) {
    final List<String> statuses = [
      'Pending', 'Credit Approved', 'Pending WH Selection', 
      'WH Assigned', 'Packed', 'Quality Checked', 
      'Logistics Costed', 'Invoiced', 'Loaded', 'Delivered', 
      'Rejected', 'Pending Admin Review'
    ];

    String selectedStatus = statuses.contains(order.status) ? order.status : statuses[0];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NexusTheme.slate900, 
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text('ADMIN CONTROL PANEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Bypass current step and force status to:', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 12),
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedStatus,
                      dropdownColor: NexusTheme.slate900,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      underline: const SizedBox(),
                      items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                      onChanged: (val) => setState(() => selectedStatus = val!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(Icons.bolt, 'BYPASS & MOVE TO STEP', Colors.orange.shade700, () async {
                    try {
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final response = await http.patch(
                        Uri.parse('${ApiConfig.baseUrl}/orders/${order.id}'),
                        headers: auth.authHeaders,
                        body: json.encode({
                          'status': selectedStatus,
                          'isAdminBypass': true
                        }),
                      );
                      
                      if (response.statusCode == 200 && context.mounted) {
                        Provider.of<NexusProvider>(context, listen: false).fetchOrders();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bypassed to $selectedStatus')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowTrace(Order order) {
    final steps = ['PENDING CREDIT APPROVAL', 'CREDIT APPROVED', 'PENDING WH SELECTION', 'DELIVERED'];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          bool isActive = order.status.toUpperCase() == steps[index];
          return Row(
            children: [
              Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, color: isActive ? Colors.green : Colors.grey, size: 20),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(steps[index], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isActive ? Colors.green : Colors.grey)),
              ),
            ],
          );
        },
      ),
    );
  }
}
