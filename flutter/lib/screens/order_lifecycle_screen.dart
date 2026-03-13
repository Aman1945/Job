import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class OrderLifecycleScreen extends StatelessWidget {
  final Order order;

  const OrderLifecycleScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: NexusTheme.slate700, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('NEXUS OMS', style: TextStyle(color: NexusTheme.slate400, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
            Text('Supply Chain', style: TextStyle(color: NexusTheme.slate900, fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: NexusTheme.slate700), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('ACTIVE SHIPMENT', style: TextStyle(color: NexusTheme.primaryBlue, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ),
                  const Text('Updated 2m ago', style: TextStyle(color: NexusTheme.slate400, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Text(
                'Order Lifecycle: #${order.id.isNotEmpty ? order.id.toUpperCase() : "NX-882910"}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.5),
              ),
            ),
            
            // Stats Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildStatCard('TOTAL UNITS', '1,240', '0%', NexusTheme.primaryBlue),
                  const SizedBox(width: 16),
                  _buildStatCard('CURRENT STAGE', 'Dispatch', '60%', NexusTheme.primaryBlue, isProgress: true),
                  const SizedBox(width: 16),
                  _buildStatCard('SLA STATUS', 'On Track', '+2%', const Color(0xFF10B981), isStatus: true),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Technical Timeline Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 40, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Technical Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
                      Icon(Icons.tune_rounded, color: NexusTheme.slate400, size: 20),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  _buildTimelineItem(
                    'Creation',
                    'Jan 10, 2024 • 08:00 AM',
                    'Order initialized by system: NEX-AUTO-GEN',
                    TimelineStatus.completed,
                  ),
                  _buildTimelineItem(
                    'Placed Order',
                    'Jan 10, 2024 • 09:30 AM',
                    '',
                    TimelineStatus.completed,
                  ),
                  _buildTimelineItem(
                    'Dispatch',
                    'Est. Completion: Jan 11, 14:00',
                    'Assigned to Carrier: BlueDart Logistics',
                    TimelineStatus.processing,
                  ),
                  _buildTimelineItem(
                    'Receiving',
                    'Scheduled for Warehouse A4',
                    '',
                    TimelineStatus.pending,
                  ),
                  _buildTimelineItem(
                    'Stocking',
                    'Awaiting receiving scan',
                    '',
                    TimelineStatus.inactive,
                    icon: Icons.local_shipping_outlined,
                  ),
                  _buildTimelineItem(
                    'Picking',
                    '',
                    '',
                    TimelineStatus.inactive,
                    icon: Icons.directions_walk_rounded,
                  ),
                  _buildTimelineItem(
                    'Packaging',
                    '',
                    '',
                    TimelineStatus.inactive,
                    icon: Icons.inventory_2_outlined,
                  ),
                  _buildTimelineItem(
                    'Final Shipping',
                    '',
                    '',
                    TimelineStatus.inactive,
                    icon: Icons.rocket_launch_outlined,
                  ),
                  _buildTimelineItem(
                    'Delivery',
                    '',
                    '',
                    TimelineStatus.inactive,
                    icon: Icons.home_outlined,
                  ),
                  _buildTimelineItem(
                    'Returns',
                    '',
                    '',
                    TimelineStatus.inactive,
                    icon: Icons.replay_rounded,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String subValue, Color color, {bool isProgress = false, bool isStatus = false}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.primaryBlue, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          if (isProgress)
            Stack(
              children: [
                Container(height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
                FractionallySizedBox(widthFactor: 0.6, child: Container(height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
              ],
            )
          else if (isStatus)
            Row(
              children: [
                Icon(Icons.check_circle, color: color, size: 14),
                const SizedBox(width: 4),
                Text(subValue, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
              ],
            )
          else
            Row(
              children: [
                const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 14),
                const SizedBox(width: 4),
                Text(subValue, style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String meta, String subContent, TimelineStatus status, {IconData? icon, bool isLast = false}) {
    Color iconColor;
    Color circleColor;
    Widget iconWidget;
    bool hasCheck = false;

    switch (status) {
      case TimelineStatus.completed:
        iconColor = Colors.white;
        circleColor = const Color(0xFF10B981);
        iconWidget = const Icon(Icons.check, color: Colors.white, size: 14);
        hasCheck = true;
        break;
      case TimelineStatus.processing:
        iconColor = Colors.white;
        circleColor = const Color(0xFF93C5FD);
        iconWidget = Icon(icon ?? Icons.local_shipping_rounded, color: Colors.white, size: 14);
        break;
      case TimelineStatus.pending:
        iconColor = NexusTheme.slate400;
        circleColor = const Color(0xFFF8FAFC);
        iconWidget = Icon(icon ?? Icons.inventory_2_outlined, color: NexusTheme.slate400, size: 14);
        break;
      case TimelineStatus.inactive:
        iconColor = NexusTheme.slate200;
        circleColor = Colors.white;
        iconWidget = Icon(icon ?? Icons.circle, color: NexusTheme.slate200, size: 14);
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: status == TimelineStatus.pending || status == TimelineStatus.inactive
                      ? Border.all(color: const Color(0xFFF1F5F9), width: 1.5)
                      : null,
                ),
                child: Center(child: iconWidget),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: const Color(0xFFF1F5F9),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: status == TimelineStatus.inactive ? NexusTheme.slate300 : NexusTheme.slate900)),
                      if (status == TimelineStatus.completed)
                        _buildTag('COMPLETED', const Color(0xFFDCFCE7), const Color(0xFF16A34A))
                      else if (status == TimelineStatus.processing)
                        _buildTag('PROCESSING', const Color(0xFFEFF6FF), NexusTheme.primaryBlue)
                      else if (status == TimelineStatus.pending)
                        _buildTag('PENDING', const Color(0xFFF8FAFC), NexusTheme.slate400),
                    ],
                  ),
                  if (meta.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(meta, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: status == TimelineStatus.inactive ? NexusTheme.slate200 : NexusTheme.slate500)),
                    ),
                  if (subContent.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: status == TimelineStatus.processing
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_shipping_rounded, color: NexusTheme.primaryBlue, size: 14),
                                const SizedBox(width: 8),
                                Expanded(child: Text(subContent, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.primaryBlue))),
                              ],
                            ),
                          )
                        : Text(subContent, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: status == TimelineStatus.inactive ? NexusTheme.slate200 : NexusTheme.slate400, fontStyle: FontStyle.italic)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }
}

enum TimelineStatus { completed, processing, pending, inactive }
