import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class BatchPickingScreen extends StatefulWidget {
  final Order order;
  const BatchPickingScreen({super.key, required this.order});

  @override
  State<BatchPickingScreen> createState() => _BatchPickingScreenState();
}

class _BatchPickingScreenState extends State<BatchPickingScreen> {
  bool isAutoScan = true;
  late List<Map<String, dynamic>> pickingItems;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    pickingItems = widget.order.items.map((i) => {
      'productId': i.productId,
      'skuCode': i.skuCode,
      'productName': i.productName,
      'orderedQty': i.quantity,
      'allocatedQty': 0.0,
      'unit': i.unit ?? 'KG',
      'batchNo': '',
      'mfgDate': '',
      'expiryDate': '',
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(isMobile),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 40),
                child: Column(
                  children: [
                    _buildMainHeader(isMobile),
                    const SizedBox(height: 32),
                    _buildBodyLayout(isMobile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 16, color: NexusTheme.slate400),
                const SizedBox(width: 8),
                Text('RETURN TO QUEUE', 
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 8 : 10, letterSpacing: 1.5, color: NexusTheme.slate400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 40),
        border: Border.all(color: NexusTheme.slate200.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.order.id, 
                  style: TextStyle(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: NexusTheme.slate900)),
                const SizedBox(height: 4),
                Text('${widget.order.customerName} • Private Ltd', 
                  style: TextStyle(color: NexusTheme.slate500, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('ORDER BOOKING VALUE', 
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text('₹${NumberFormat('#,##,###').format(widget.order.total)}', 
                style: TextStyle(fontSize: isMobile ? 24 : 48, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyLayout(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildPickingTerminal(isMobile),
          const SizedBox(height: 24),
          _buildWorkflowTrace(isMobile),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildPickingTerminal(isMobile),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            children: [
              _buildIntelligenceInsight(isMobile),
              const SizedBox(height: 32),
              _buildWorkflowTrace(isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickingTerminal(bool isMobile) {
    return Column(
      children: [
        _buildTerminalHeader(isMobile),
        _buildPickingList(isMobile),
        _buildTerminalFooter(isMobile),
      ],
    );
  }

  Widget _buildTerminalHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: const BoxDecoration(
        color: Color(0xFF034A3E),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.package, color: Color(0xFF10B981), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('3. Batch Picking Terminal', 
                      style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 24, fontWeight: FontWeight.w900)),
                    const Text('SOURCING FROM: IOPL KURLA', 
                      style: TextStyle(color: Color(0xFF10B981), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
              ),
              if (!isMobile) ...[
                _buildModeToggle(),
                const SizedBox(width: 12),
                _buildLoadUnitsCounter(),
              ],
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 20),
            _buildModeToggle(),
            const SizedBox(height: 16),
            _buildLoadUnitsCounter(),
          ],
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _buildToggleButton('AUTO-SCAN', LucideIcons.scan, isAutoScan, () => setState(() => isAutoScan = true)),
          _buildToggleButton('MANUAL', LucideIcons.send, !isAutoScan, () => setState(() => isAutoScan = false)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF10B981) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active ? [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 8)] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: active ? Colors.white : Colors.white60),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadUnitsCounter() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.box, color: Color(0xFF10B981), size: 16),
          const SizedBox(width: 12),
          const Text('13', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(width: 12),
          const Text('LOAD UNITS', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildPickingList(bool isMobile) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildPickingListHeader(isMobile),
          const Divider(height: 1),
          ...pickingItems.map((item) => _buildPickingItemRow(item, isMobile)).toList(),
        ],
      ),
    );
  }

  Widget _buildPickingListHeader(bool isMobile) {
    if (isMobile) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Row(
        children: [
          const Expanded(flex: 3, child: Text('ITEM IDENTITY / BARCODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1))),
          const Expanded(flex: 1, child: Center(child: Text('ORDERED QTY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)))),
          const Expanded(flex: 1, child: Center(child: Text('ALLOCATED QTY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0D9488), letterSpacing: 1)))),
          const Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('BATCH DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)))),
        ],
      ),
    );
  }

  Widget _buildPickingItemRow(Map<String, dynamic> item, bool isMobile) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: NexusTheme.slate100)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['productName'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            Text(item['skuCode'], style: const TextStyle(color: NexusTheme.slate400, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildScanArea(isMobile),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildInfoCol('ORDERED QTY', '${item['orderedQty']} ${item['unit']}')),
                Expanded(child: _buildInfoCol('ALLOCATED QTY', '${item['allocatedQty']} ${item['unit']}', color: const Color(0xFF0D9488))),
              ],
            ),
            const SizedBox(height: 24),
            _buildBatchForm(item, true),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: NexusTheme.slate100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['productName'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text(item['skuCode'], style: const TextStyle(color: NexusTheme.slate400, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildScanArea(false),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Text('${item['orderedQty']} ${item['unit']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Text('${item['allocatedQty']} ${item['unit']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0D9488))),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildBatchForm(item, false),
          ),
        ],
      ),
    );
  }

  Widget _buildScanArea(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 200,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isAutoScan ? LucideIcons.scan : LucideIcons.keyboard, color: NexusTheme.slate300, size: 24),
          const SizedBox(height: 12),
          Text(isAutoScan ? 'Tap to Scan\nSKU' : 'TYPE BARCODE', 
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: NexusTheme.slate400, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildInfoCol(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color ?? NexusTheme.slate900)),
      ],
    );
  }

  Widget _buildBatchForm(Map<String, dynamic> item, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BATCH NO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                _buildBatchInput('BATCH'),
              ],
            )),
            const SizedBox(width: 8),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('MFG DATE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                _buildDateInput('mm/dd/yy', LucideIcons.calendar),
              ],
            )),
            const SizedBox(width: 8),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('EXP DATE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                _buildDateInput('mm/dd/yy', LucideIcons.calendar),
              ],
            )),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: DottedBorder(
            color: const Color(0xFF10B981),
            strokeWidth: 2,
            dashPattern: const [6, 3],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 16, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  const Text('ALLOCATE UNITS', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchInput(String hint) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate300),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDateInput(String hint, IconData icon) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate300),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          Icon(icon, size: 14, color: NexusTheme.slate400),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTerminalFooter(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: const BoxDecoration(
        color: Color(0xFF034A3E),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: isMobile 
        ? Column(
            children: [
              _buildAggPickingValue(),
              const SizedBox(height: 24),
              _buildSubmitButton(true),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAggPickingValue(),
              _buildSubmitButton(false),
            ],
          ),
    );
  }

  Widget _buildAggPickingValue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AGGREGATE PICKING VALUE', style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 4),
        const Text('₹0', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildSubmitButton(bool isFullWidth) {
    return SizedBox(
      height: 64,
      width: isFullWidth ? double.infinity : 400,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(LucideIcons.arrowRight, size: 18),
        label: const Text('PUSH TO QUALITY CONTROL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }

  // Common Sidebar Components (Intelligence Insight & Workflow Trace)
  Widget _buildIntelligenceInsight(bool isMobile) {
     return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              const Text('INTELLIGENCE INSIGHT', 
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '"**Risk Factor:** The customer poses a high credit risk due to a significant overdue balance of ₹2.5L and severe ageing of 95 days. Despite the negligible order value, the long-standing delinquency indicates poor payment behavior. **Recommendation:** **Flag** (Hold for partial payment collection before release)."',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowTrace(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: NexusTheme.slate200.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('MISSION WORKFLOW TRACE', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: NexusTheme.slate400)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.history, size: 14),
                label: const Text('VIEW LOG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9)),
                style: TextButton.styleFrom(foregroundColor: NexusTheme.indigo600, padding: EdgeInsets.zero),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildTraceStep('PENDING CREDIT APPROVAL', true, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('ON HOLD', false, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('PENDING WH SELECTION', true, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('PENDING PACKING', true, true, isMobile), 
          _buildTraceLine(),
          _buildTraceStep('PART PACKED', false, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('PENDING QUALITY CONTROL', false, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('READY FOR BILLING', false, false, isMobile),
        ],
      ),
    );
  }

  Widget _buildTraceStep(String label, bool completed, bool isActive, bool isMobile) {
    return Row(
      children: [
        Container(
          width: isMobile ? 24 : 28,
          height: isMobile ? 24 : 28,
          decoration: BoxDecoration(
            color: completed ? const Color(0xFFECFDF5) : (isActive ? const Color(0xFFEEF2FF) : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(
              color: completed ? const Color(0xFF10B981) : (isActive ? const Color(0xFF6366F1) : NexusTheme.slate200),
              width: 2,
            ),
          ),
          child: completed 
            ? Icon(Icons.check, size: isMobile ? 12 : 14, color: const Color(0xFF10B981))
            : (isActive ? Container(margin: const EdgeInsets.all(7), decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle)) : null),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, 
                style: TextStyle(
                  fontWeight: FontWeight.w900, 
                  fontSize: isMobile ? 9 : 10, 
                  letterSpacing: 0.5,
                  color: completed ? NexusTheme.slate900 : (isActive ? const Color(0xFF6366F1) : NexusTheme.slate300),
                )),
              if (isActive)
                const Text('ACTIVE STAGE', 
                  style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w900, fontSize: 8)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTraceLine() {
    return Container(
      margin: const EdgeInsets.only(left: 13),
      width: 2,
      height: 24,
      color: NexusTheme.slate100,
    );
  }
}

// Helper Widget for Dotted Border since it's not and Standard widget
class DottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final BorderType borderType;
  final Radius radius;

  const DottedBorder({
    super.key, 
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.dashPattern = const [3, 1],
    this.borderType = BorderType.Rect,
    this.radius = Radius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashPattern: dashPattern,
        borderType: borderType,
        radius: radius,
      ),
      child: child,
    );
  }
}

enum BorderType { Rect, RRect, Circle, Oval }

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final BorderType borderType;
  final Radius radius;

  _DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
    required this.borderType,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Path path;
    if (borderType == BorderType.RRect) {
      path = Path()..addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, radius));
    } else {
      path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    final dashPath = Path();
    for (final pathMetric in path.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < pathMetric.length) {
        final length = dashPattern[draw ? 0 : 1];
        if (draw) {
          dashPath.addPath(
            pathMetric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(_DottedBorderPainter oldDelegate) => false;
}
