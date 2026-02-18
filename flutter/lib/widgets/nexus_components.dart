import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class NexusComponents {
  // ... (previous components)

  // 5. Detailed Credit Matrix (2-Part Table from Excel)
  static Widget creditMatrix(Customer? customer) {
    if (customer == null) return const SizedBox();

    final buckets = customer.agingData;
    final currencyFormat = NumberFormat('#,##,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PART 1: Identity & Financials
        _buildSectionHeader('CREDIT IDENTITY & FINANCIALS'),
        _buildTableContainer([
          _buildHeaderRow(['Customer ID', 'Dist', 'Sales Manager', 'Class', 'Employee respons.', 'Customer Names', 'Credit Days', 'Credit Limit', 'Security Chq', 'Dist Channel', 'O/s Amt', 'OD Amt']),
          _buildDataRow([
            customer.id,
            customer.location ?? '-',
            customer.salesManager ?? '-',
            customer.customerClass ?? '-',
            customer.employeeResponsible ?? '-',
            customer.name,
            '${customer.exposureDays} days',
            '₹${currencyFormat.format(customer.limit)}',
            customer.securityChq,
            customer.distributionChannel ?? '-',
            '₹${currencyFormat.format(customer.osBalance)}',
            '₹${currencyFormat.format(customer.odAmt)}',
          ]),
        ]),
        
        const SizedBox(height: 24),

        // PART 2: Aging & Differences
        _buildSectionHeader('AGING BUCKETS & VARIANCE'),
        _buildTableContainer([
          _buildHeaderRow(['Diffn btw ydy & tday', '0 to 7', '7 to 15', '15 to 30', '30 to 45', '45 to 90', '90 to 120', '120 to 150', '150 to 180', '>180']),
          _buildDataRow([
            '₹${currencyFormat.format(customer.diffYesterdayToday)}',
            '₹${currencyFormat.format(buckets['0 to 7'] ?? 0)}',
            '₹${currencyFormat.format(buckets['7 to 15'] ?? 0)}',
            '₹${currencyFormat.format(buckets['15 to 30'] ?? 0)}',
            '₹${currencyFormat.format(buckets['30 to 45'] ?? 0)}',
            '₹${currencyFormat.format(buckets['45 to 90'] ?? 0)}',
            '₹${currencyFormat.format(buckets['90 to 120'] ?? 0)}',
            '₹${currencyFormat.format(buckets['120 to 150'] ?? 0)}',
            '₹${currencyFormat.format(buckets['150 to 180'] ?? 0)}',
            '₹${currencyFormat.format(buckets['>180'] ?? 0)}',
          ], isAging: true, buckets: buckets),
        ]),
      ],
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)),
    );
  }

  static Widget _buildTableContainer(List<TableRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexusTheme.slate200),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: rows,
        ),
      ),
    );
  }

  static TableRow _buildHeaderRow(List<String> headers) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFE2E8F0)), // Grey header like Excel
      children: headers.map((h) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(h, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate900)),
      )).toList(),
    );
  }

  static TableRow _buildDataRow(List<String> data, {bool isAging = false, Map<String, dynamic>? buckets}) {
    return TableRow(
      children: data.asMap().entries.map((entry) {
        final idx = entry.key;
        final val = entry.value;
        
        Color textColor = NexusTheme.slate900;
        Color? bgColor;

        if (isAging && buckets != null) {
          // Highlight high risk (last bucket)
          if (idx == 9 && (buckets['>180'] ?? 0) > 0) {
            textColor = Colors.red.shade700;
            bgColor = Colors.red.withOpacity(0.05);
          }
          // Highlight mid risk (90-180)
          else if (idx >= 6 && idx <= 8 && val != '₹0') {
            textColor = Colors.orange.shade700;
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(color: bgColor),
          child: Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: textColor)),
        );
      }).toList(),
    );
  }

  // New: Restricted View Widget
  static Widget restrictedView({String message = 'Detailed credit matrix is only visible to Admin & Credit Analytics.'}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, color: Colors.blueGrey.shade400, size: 48), // Larger icon
            const SizedBox(height: 24), // More spacing
            Text(
              'ACCESS DENIED', // More direct message
              style: TextStyle(color: Colors.blueGrey.shade800, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5), // Larger, bolder title
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12, fontWeight: FontWeight.w600), // Slightly larger, darker message
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Optional: Add a button for more info or to request access
            // ElevatedButton(
            //   onPressed: () { /* Handle request access */ },
            //   child: Text('Request Access'),
            // ),
          ],
        ),
      ),
    );
  }

  // 1. Premium Header Button (Used in Master Data, Procurement, etc.)
  static Widget headerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? bgColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NexusTheme.slate200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor ?? NexusTheme.slate900),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textColor ?? NexusTheme.slate900)),
          ],
        ),
      ),
    );
  }

  // 2. Statistics Card (Used in Dashboard and Analytics)
  static Widget statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
              if (trend != null)
                Text(trend, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexusTheme.emerald600)),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -1)),
                ),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Status Badge (Unified across all screens)
  static Widget statusBadge(String status, {Color? color, Color? bgColor}) {
    Color finalColor = color ?? NexusTheme.slate500;
    Color finalBgColor = bgColor ?? NexusTheme.slate100;
    
    if (color == null) {
      switch (status) {
        case 'Pending Credit Approval':
        case 'Pending WH Selection':
        case 'Pending Packing':
          finalColor = Colors.orange.shade700;
          finalBgColor = Colors.orange.shade50;
          break;
        case 'Invoiced':
        case 'Ready for Dispatch':
        case 'Delivered':
        case 'Packed':
          finalColor = NexusTheme.emerald700;
          finalBgColor = NexusTheme.emerald50;
          break;
        case 'Out for Delivery':
        case 'In Transit':
          finalColor = Colors.blue.shade700;
          finalBgColor = Colors.blue.shade50;
          break;
        default:
          finalColor = NexusTheme.slate500;
          finalBgColor = NexusTheme.slate100;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: finalBgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: finalColor, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 0.5),
      ),
    );
  }

  // 4. Empty State View
  static Widget emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: NexusTheme.slate200),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
          Text(subtitle, style: const TextStyle(color: NexusTheme.slate400, fontSize: 13)),
        ],
      ),
    );
  }
}
