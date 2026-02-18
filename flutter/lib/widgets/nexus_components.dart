import 'package:flutter/material.dart';
import '../utils/theme.dart';

class NexusComponents {
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
