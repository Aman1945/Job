import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart'; // NEW


class CreditRiskScreen extends StatefulWidget {
  const CreditRiskScreen({super.key});

  @override
  State<CreditRiskScreen> createState() => _CreditRiskScreenState();
}

class _CreditRiskScreenState extends State<CreditRiskScreen> {
  final List<Map<String, dynamic>> _riskProfiles = [
    {
      'name': 'VR Fine Foods',
      'id': '190187',
      'type': 'HORECA',
      'terms': '15 Days',
      'limit': 1000000.0,
      'outstanding': 650000.0,
      'overdue': 250000.0, // Part of outstanding that is overdue
      'buckets': {
        '0-7': 50000,
        '7-15': 50000,
        '15-30': 50000,
        '30-45': 50000,
        '45-90': 100000,
        '90-120': 100000,
        '120-150': 50000,
        '150-180': 100000,
        '>180': 100000,
      },
      'invoices': [
        {'id': 'EXT-9921', 'amount': 105000.0, 'date': '2024-01-15'}
      ]
    },
    {
      'name': 'Palkit Impex private limited',
      'id': '190094',
      'type': 'PRIVATE LTD',
      'terms': '45 Days',
      'limit': 500000.0,
      'outstanding': 385000.0,
      'overdue': 50000.0,
      'buckets': {
        '0-7': 335000, // Not overdue
        '45-90': 50000, // Overdue
      },
      'invoices': []
    },
     {
      'name': 'Harbour Exports',
      'id': '190068',
      'type': 'DISTRIBUTOR',
      'terms': '30 Days',
      'limit': 200000.0,
      'outstanding': 145000.0,
      'overdue': 0.0,
      'buckets': {
        '0-7': 145000,
      },
      'invoices': []
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate Total Overdue across all customers
    double totalOverdue = _riskProfiles.fold(0, (sum, profile) => sum + (profile['overdue'] as double));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('2.1 CREDIT RISK TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(totalOverdue, isMobile),
                const SizedBox(height: 32),
                _buildSearchFilter(),
                const SizedBox(height: 32),
                _buildCustomerList(isMobile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(double totalOverdue, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Slate 900
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.shieldAlert, color: Color(0xFFF43F5E), size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Credit Risk Terminal', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('Monitor overdue balances and dispatch payment missions', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                ),
              ),
              if (!isMobile)
                _buildOverdueBadge(totalOverdue),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 24),
            _buildOverdueBadge(totalOverdue),
          ]
        ],
      ),
    );
  }

  Widget _buildOverdueBadge(double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2), // Red 100
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.trendingDown, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 12),
          Text('TOTAL OVERDUE: ₹${amount.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSearchFilter() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Filter customer identity...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50], // Slate 50
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
    );
  }

  Widget _buildCustomerList(bool isMobile) {
    return Column(
      children: _riskProfiles.map((customer) => _buildCustomerCard(customer, isMobile)).toList(),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer, bool isMobile) {
    bool hasOverdue = (customer['overdue'] as double) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: hasOverdue ? [BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 20, spreadRadius: 5)] : [],
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        tilePadding: EdgeInsets.all(isMobile ? 16 : 24),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text('ID: ${customer['id']} • ${customer['type']}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: hasOverdue ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
               borderRadius: BorderRadius.circular(12),
             ),
             child: Text(
               hasOverdue ? '> ${(customer['overdue'] as double).toStringAsFixed(0)}' : 'CLEAN',
               style: TextStyle(
                 fontWeight: FontWeight.w900, 
                 fontSize: 12, 
                 color: hasOverdue ? const Color(0xFFEF4444) : const Color(0xFF22C55E)
               ),
             ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: isMobile 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStat('CREDIT TERMS', customer['terms']),
                  const SizedBox(height: 8),
                  _buildStat('LIMIT', '₹${customer['limit'].toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _buildStat('OUTSTANDING', '₹${customer['outstanding'].toStringAsFixed(0)}'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('CREDIT TERMS', customer['terms']),
                  _buildStat('LIMIT', '₹${customer['limit'].toStringAsFixed(0)}'),
                  _buildStat('OUTSTANDING', '₹${customer['outstanding'].toStringAsFixed(0)}'),
                ],
              ),
        ),
        children: [
           _buildDetailPanel(customer, isMobile),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
      ],
    );
  }

  Widget _buildDetailPanel(Map<String, dynamic> customer, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 16, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              const Text('AGING EXPOSURE PROFILE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (customer['buckets'] as Map<String, int>).entries.map((e) => _buildAgingBucket(e.key, e.value)).toList(),
          ),
          const SizedBox(height: 32),
           if ((customer['invoices'] as List).isNotEmpty) ...[
             const Text('LINKED INVOICE EVIDENCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 1)),
             const SizedBox(height: 16),
             ...((customer['invoices'] as List).map((inv) => _buildInvoiceRow(inv))),
             const SizedBox(height: 32),
           ],
           
           Row(
             children: [
               Expanded(
                 child: ElevatedButton.icon(
                   onPressed: () => _sendWhatsAppAlert(customer),
                   icon: const Icon(LucideIcons.messageSquare, size: 16),
                   label: const Text('WHATSAPP ALERT'),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF22C55E),
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                   ),
                 ),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: ElevatedButton.icon(
                   onPressed: () => _sendEmailAlert(customer),
                   icon: const Icon(LucideIcons.mail, size: 16),
                   label: const Text('EMAIL PROTOCOL'),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF6366F1),
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                   ),
                 ),
               ),
             ],
           ),
           const SizedBox(height: 16),
           Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFEF3C7))),
             child: Row(
               children: [
                 const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
                 const SizedBox(width: 12),
                 const Expanded(child: Text('Dispatching alerts will include an automated summary of overdue aging buckets and PDF copies of all open invoices.', style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.4))),
               ],
             ),
           )
        ],
      ),
    );
  }

  Widget _buildAgingBucket(String label, int value) {
    final isHighRisk = label == '90-120' || label == '120-150' || label == '150-180' || label == '>180' || label == '45-90';
    if (value == 0) return const SizedBox.shrink();

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isHighRisk ? const Color(0xFFFEF2F2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isHighRisk ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isHighRisk ? const Color(0xFFEF4444) : Colors.grey)),
          const SizedBox(height: 4),
          Text('₹${(value/1000).toStringAsFixed(0)}k', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isHighRisk ? const Color(0xFF991B1B) : const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(Map<String, dynamic> inv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(inv['id'], style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1))),
          Text('₹${inv['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Future<void> _sendWhatsAppAlert(Map<String, dynamic> customer) async {
    final String message = "Hello ${customer['name']}, this is an automated payment reminder from Nexus SCM regarding your outstanding balance of ₹${customer['outstanding']}. Please clear the overdue amount immediately.";
    final Uri url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
    }
  }

  Future<void> _sendEmailAlert(Map<String, dynamic> customer) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    await provider.sendEmailNotification(
      recipient: 'billing@${customer['name'].toString().toLowerCase().replaceAll(' ', '')}.com',
      subject: '⚠️ PAYMENT ALERT: Outstanding Balance ₹${customer['outstanding']}',
      body: 'Dear Customer,\n\nYour account shows an outstanding balance of ₹${customer['outstanding']}.\nOverdue Amount: ₹${customer['overdue']}.\n\nPlease remit payment immediately to avoid service interruption.\n\nNexus Credit Control'
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email Alert Sent via SMTP Relay'), backgroundColor: Color(0xFF6366F1)));
    }
  }
}
