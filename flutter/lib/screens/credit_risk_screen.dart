import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import '../widgets/nexus_components.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';


class CreditRiskScreen extends StatefulWidget {
  const CreditRiskScreen({super.key});

  @override
  State<CreditRiskScreen> createState() => _CreditRiskScreenState();
}

class _CreditRiskScreenState extends State<CreditRiskScreen> {
  String _searchQuery = '';
  Customer? _selectedCustomer;

  @override
  Widget build(BuildContext context) {
    final nexus = Provider.of<NexusProvider>(context);
    final customers = nexus.customers;

    // Calculate Total Overdue across all customers (from imported OD master)
    final double totalOverdue =
        customers.fold(0, (sum, c) => sum + (c.odAmt)); // uses OD Amt

    // Apply search on name / id / city
    final filtered = customers.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.id.toLowerCase().contains(q) ||
          (c.location ?? '').toLowerCase().contains(q);
    }).toList();

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
                _buildCustomerList(filtered, isMobile),
                const SizedBox(height: 32),
                if (_selectedCustomer != null) _buildCfoMatrix(_selectedCustomer!, isMobile),
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
      onChanged: (val) {
        setState(() => _searchQuery = val.trim());
      },
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

  Widget _buildCustomerList(List<Customer> customers, bool isMobile) {
    if (customers.isEmpty) {
      return const Center(
        child: Text(
          'No customers with OD data found.\nImport Customer Master with aging to view risk.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
        ),
      );
    }

    return Column(
      children: customers.map((c) => _buildCustomerCard(c, isMobile)).toList(),
    );
  }

  Widget _buildCustomerCard(Customer customer, bool isMobile) {
    final bool hasOverdue = customer.odAmt > 0;

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
            Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(
              'ID: ${customer.id} • ${customer.customerClass ?? '-'}',
              style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: hasOverdue ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
               borderRadius: BorderRadius.circular(12),
             ),
             child: Text(
               hasOverdue ? 'OD ₹${customer.odAmt.toStringAsFixed(0)}' : 'CLEAN',
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
                  _buildStat('CREDIT TERMS', '${customer.exposureDays} days'),
                  const SizedBox(height: 8),
                  _buildStat('LIMIT', '₹${customer.limit.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _buildStat('OUTSTANDING', '₹${customer.osBalance.toStringAsFixed(0)}'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('CREDIT TERMS', '${customer.exposureDays} days'),
                  _buildStat('LIMIT', '₹${customer.limit.toStringAsFixed(0)}'),
                  _buildStat('OUTSTANDING', '₹${customer.osBalance.toStringAsFixed(0)}'),
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

  Widget _buildDetailPanel(Customer customer, bool isMobile) {
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
          // Use full OD / Aging table for this customer
          NexusComponents.creditMatrix(customer),
          const SizedBox(height: 24),
           
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

  Future<void> _sendWhatsAppAlert(Customer customer) async {
    final String message =
        "Hello ${customer.name}, this is an automated payment reminder from Nexus SCM regarding your outstanding balance of ₹${customer.osBalance.toStringAsFixed(0)}. Please clear the overdue amount immediately.";
    final Uri url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
    }
  }

  Future<void> _sendEmailAlert(Customer customer) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    await provider.sendEmailNotification(
      recipient: 'billing@${customer.name.toLowerCase().replaceAll(' ', '')}.com',
      subject: '⚠️ PAYMENT ALERT: Outstanding Balance ₹${customer.osBalance.toStringAsFixed(0)}',
      body:
          'Dear Customer,\n\nYour account shows an outstanding balance of ₹${customer.osBalance.toStringAsFixed(0)}.\nOverdue Amount: ₹${customer.odAmt.toStringAsFixed(0)}.\n\nPlease remit payment immediately to avoid service interruption.\n\nNexus Credit Control'
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email Alert Sent via SMTP Relay'), backgroundColor: Color(0xFF6366F1)));
    }
  }

  // CFO focus: pinned full OD matrix of selected customer (from tap)
  Widget _buildCfoMatrix(Customer customer, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics_outlined, color: Color(0xFF0F172A), size: 18),
            const SizedBox(width: 8),
            Text(
              'CFO VIEW • ${customer.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                color: Color(0xFF0F172A),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        NexusComponents.creditMatrix(customer),
      ],
    );
  }
}
