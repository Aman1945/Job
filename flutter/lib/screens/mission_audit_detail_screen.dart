import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'batch_picking_screen.dart';

class MissionAuditDetailScreen extends StatefulWidget {
  final Order order;
  const MissionAuditDetailScreen({super.key, required this.order});

  @override
  State<MissionAuditDetailScreen> createState() => _MissionAuditDetailScreenState();
}

class _MissionAuditDetailScreenState extends State<MissionAuditDetailScreen> {
  bool isEditing = false;
  late List<Map<String, dynamic>> items;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    items = widget.order.items.map((i) => {
      'productId': i.productId,
      'skuCode': i.skuCode,
      'name': i.productName,
      'quantity': i.quantity,
      'boxCount': i.boxCount ?? 1,
      'price': i.price,
      'prevRate': i.prevRate,
      'unit': i.unit ?? 'KG',
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 1200;
    bool isMobile = screenWidth < 768;

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
                    SizedBox(height: isMobile ? 24 : 32),
                    if (isEditing)
                      _buildEditView(isDesktop, isMobile)
                    else
                      _buildAuditView(isDesktop, isMobile),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Row(
            children: [
              _buildSmallIconButton(
                label: 'EDIT',
                icon: LucideIcons.edit2,
                color: NexusTheme.slate900,
                onPressed: () => setState(() => isEditing = true),
                isMobile: isMobile,
              ),
              const SizedBox(width: 12),
              _buildSmallIconButton(
                label: 'CANCEL',
                icon: LucideIcons.ban,
                color: NexusTheme.rose600,
                outline: true,
                onPressed: () {},
                isMobile: isMobile,
              ),
              const SizedBox(width: 12),
              _buildSmallIconButton(
                label: 'PACK MISSION',
                icon: LucideIcons.package,
                color: const Color(0xFF10B981),
                onPressed: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => BatchPickingScreen(order: widget.order))
                ),
                isMobile: isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton({
    required String label, 
    required IconData icon, 
    required Color color, 
    bool outline = false,
    required VoidCallback onPressed,
    bool isMobile = false,
  }) {
    return SizedBox(
      height: isMobile ? 32 : 36,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isMobile ? 10 : 12, color: outline ? color : Colors.white),
        label: Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 8 : 9, letterSpacing: 1.2, color: outline ? color : Colors.white)),
        style: OutlinedButton.styleFrom(
          backgroundColor: outline ? Colors.transparent : color,
          side: outline ? BorderSide(color: color.withOpacity(0.2)) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16),
        ),
      ),
    );
  }

  Widget _buildMainHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 40),
        border: Border.all(color: NexusTheme.slate200.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      child: isMobile 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBadge(),
              const SizedBox(height: 16),
              Text(widget.order.id, 
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1, color: NexusTheme.slate900)),
              const SizedBox(height: 4),
              Text('${widget.order.customerName} • Private Ltd', 
                style: const TextStyle(color: NexusTheme.slate500, fontSize: 13, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              const Text('ORDER BOOKING VALUE', 
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text('₹${NumberFormat('#,##,###').format(widget.order.total)}', 
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge(),
                  const SizedBox(height: 20),
                  Text(widget.order.id, 
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: NexusTheme.slate900)),
                  const SizedBox(height: 4),
                  Text('${widget.order.customerName} • Private Ltd', 
                    style: const TextStyle(color: NexusTheme.slate500, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('ORDER BOOKING VALUE', 
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text('₹${NumberFormat('#,##,###').format(widget.order.total)}', 
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(widget.order.status.toUpperCase(), 
        style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
    );
  }

  Widget _buildAuditView(bool isDesktop, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildFulfillmentHistory(isMobile),
          const SizedBox(height: 24),
          _buildIntelligenceInsight(isMobile),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildFulfillmentHistory(isMobile),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: _buildIntelligenceInsight(isMobile),
        ),
      ],
    );
  }

  Widget _buildFulfillmentHistory(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
        border: Border.all(color: NexusTheme.slate200.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FULFILLMENT HISTORY', 
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: NexusTheme.slate900)),
          SizedBox(height: isMobile ? 24 : 32),
          ...widget.order.items.map((item) => _buildFulfillmentItem(item, isMobile)).toList(),
        ],
      ),
    );
  }

  Widget _buildFulfillmentItem(OrderItem item, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, 
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 14 : 16, color: NexusTheme.slate900)),
                const SizedBox(height: 4),
                Text('0 / ${item.quantity} ${item.unit ?? "KG"} DELIVERED', 
                  style: const TextStyle(color: NexusTheme.slate400, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${NumberFormat('#,##,###').format(item.price * item.quantity)}', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 14 : 16, color: NexusTheme.slate900)),
              const SizedBox(height: 4),
              Text('SHORT: ${item.quantity} UNITS', 
                style: const TextStyle(color: NexusTheme.rose600, fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntelligenceInsight(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488),
        borderRadius: BorderRadius.circular(isMobile ? 32 : 40),
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
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            '"**Summary:** The customer has a significant overdue balance of ₹1,20,000 (31% of total outstanding) with a 60-day ageing, indicating poor payment history. While the current order value is minimal, the existing delinquency represents a high credit risk. **Recommendation:** **Flag** (Hold order until a partial payment is received against the overdue amount)."',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isMobile ? 14 : 18, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEditView(bool isDesktop, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildTabularEditor(isMobile),
          const SizedBox(height: 24),
          _buildWorkflowTrace(isMobile),
          const SizedBox(height: 24),
          _buildIntelligenceInsight(isMobile),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildTabularEditor(isMobile),
              const SizedBox(height: 40),
              _buildIntelligenceInsight(isMobile),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: _buildWorkflowTrace(isMobile),
        ),
      ],
    );
  }

  Widget _buildTabularEditor(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 40)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.edit3, size: 14, color: NexusTheme.indigo600),
              const SizedBox(width: 10),
              const Text('EDIT SUPPLY MISSION', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: NexusTheme.slate900, letterSpacing: 0.5)),
              const Spacer(),
              IconButton(onPressed: () => setState(() => isEditing = false), icon: const Icon(Icons.close, size: 18)),
            ],
          ),
          SizedBox(height: isMobile ? 24 : 32),
          if (!isMobile) _buildTableHeader(),
          if (!isMobile) const Divider(height: 40),
          ...items.asMap().entries.map((entry) => _buildEditorRow(entry.key, entry.value, isMobile)).toList(),
          const SizedBox(height: 20),
          _buildAddLineButton(),
          Divider(height: isMobile ? 40 : 60),
          _buildEditorFooter(isMobile),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Row(
      children: [
        Expanded(flex: 3, child: Text('PRODUCT / SKU', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1))),
        Expanded(child: Center(child: Text('QTY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)))),
        Expanded(child: Center(child: Text('UNIT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)))),
        Expanded(flex: 2, child: Center(child: Text('APPLIED RATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)))),
        Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('TOTAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)))),
        SizedBox(width: 40),
      ],
    );
  }

  void _addLineItem() {
    setState(() {
      items.add({
        'productId': '',
        'skuCode': 'SELECT SKU',
        'name': '',
        'quantity': 1,
        'boxCount': 1,
        'unit': 'KG',
        'price': 0.0,
        'prevRate': 0.0,
      });
    });
  }

  Future<void> _commitChanges() async {
    setState(() => isSaving = true);
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final List<OrderItem> orderItems = items.where((i) => i['productId'].isNotEmpty).map((i) => OrderItem(
      productId: i['productId'],
      skuCode: i['skuCode'],
      productName: i['name'],
      quantity: i['quantity'],
      boxCount: i['boxCount'] ?? 1,
      price: i['price'].toDouble(),
      prevRate: (i['prevRate'] ?? 0.0).toDouble(),
      unit: i['unit'],
    )).toList();

    double subTotal = orderItems.fold(0, (sum, item) => sum + (item.price * item.quantity * (item.boxCount ?? 1)));
    double gst = subTotal * 0.18;
    double total = subTotal + gst;

    try {
      final success = await provider.updateOrderItems(
        widget.order.id,
        orderItems,
        total: total,
        subTotal: subTotal,
        gstAmount: gst,
        token: auth.token,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Mission ${widget.order.id} updated and resubmitted'),
          backgroundColor: NexusTheme.emerald500,
        ));
        // Refresh local order data if possible or pop
        await provider.fetchOrders(token: auth.token);
        if (mounted) {
          setState(() {
            isSaving = false;
            isEditing = false;
          });
          // Update the widget.order reference if we can? 
          // For now, let's just pop or let the parent refresh
          Navigator.pop(context); 
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to update items'),
            backgroundColor: NexusTheme.rose600,
          ));
          setState(() => isSaving = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => isSaving = false);
      }
    }
  }

  Widget _buildEditorRow(int index, Map<String, dynamic> item, bool isMobile) {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    
    if (isMobile) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NexusTheme.slate200.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildSkuDropdown(index, item, provider.products, isMobile)),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => setState(() => items.removeAt(index)), 
                  icon: const Icon(LucideIcons.trash2, size: 18, color: NexusTheme.rose600)
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('QTY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
                    _buildNumericField(item['quantity'].toString(), (val) {
                      setState(() => item['quantity'] = int.tryParse(val) ?? item['quantity']);
                    }),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('UNIT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
                    _buildUnitDropdown(index, item),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RATE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
                    _buildNumericField(item['price'].toString(), (val) {
                      setState(() => item['price'] = double.tryParse(val) ?? item['price']);
                    }),
                  ],
                )),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('LINE TOTAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
                Text('₹${NumberFormat('#,##,###').format(item['price'] * item['quantity'] * (item['boxCount'] ?? 1))}', 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: NexusTheme.slate900)),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildSkuDropdown(index, item, provider.products, isMobile),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildNumericField(item['quantity'].toString(), (val) {
              setState(() => item['quantity'] = int.tryParse(val) ?? item['quantity']);
            })),
            const SizedBox(width: 16),
            Expanded(child: _buildUnitDropdown(index, item)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildNumericField(item['price'].toString(), (val) {
              setState(() => item['price'] = double.tryParse(val) ?? item['price']);
            })),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('₹${NumberFormat('#,##,###').format(item['price'] * item['quantity'] * (item['boxCount'] ?? 1))}', 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: NexusTheme.slate900)),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => setState(() => items.removeAt(index)), 
              icon: const Icon(LucideIcons.minusCircle, size: 20, color: NexusTheme.slate200)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkuDropdown(int index, Map<String, dynamic> item, List<Product> products, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexusTheme.slate200.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: item['productId'].isEmpty ? null : item['productId'],
          hint: Text('SELECT SKU', style: TextStyle(fontSize: isMobile ? 9 : 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: NexusTheme.slate400),
          items: products.map((p) => DropdownMenuItem(
            value: p.id,
            child: Text('${p.skuCode} • ${p.name}', 
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 10 : 11, overflow: TextOverflow.ellipsis)),
          )).toList(),
          onChanged: (val) {
            if (val == null) return;
            final p = products.firstWhere((prod) => prod.id == val);
            setState(() {
              item['productId'] = p.id;
              item['skuCode'] = p.skuCode;
              item['name'] = p.name;
              item['price'] = p.price > 0 ? p.price : (p.mrp ?? 0.0);
            });
          },
        ),
      ),
    );
  }

  Widget _buildUnitDropdown(int index, Map<String, dynamic> item) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: NexusTheme.slate200, width: 2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: item['unit'],
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: NexusTheme.slate900),
          alignment: Alignment.center,
          items: ['KG', 'PCS', 'PKT'].map((u) => DropdownMenuItem(
            value: u,
            child: Center(child: Text(u)),
          )).toList(),
          onChanged: (val) => setState(() => item['unit'] = val),
        ),
      ),
    );
  }

  Widget _buildNumericField(String value, Function(String) onChanged) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: NexusTheme.slate200, width: 2)),
      ),
      child: TextFormField(
        initialValue: value,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: NexusTheme.slate900),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAddLineButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _addLineItem,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('ADD NEW ITEM LINE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1)),
        style: TextButton.styleFrom(foregroundColor: NexusTheme.slate400),
      ),
    );
  }

  Widget _buildEditorFooter(bool isMobile) {
    double revisedTotal = items.fold(0.0, (sum, i) => sum + (i['price'] * i['quantity'] * (i['boxCount'] ?? 1))) * 1.18;
    
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('REVISED VALUATION', 
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('₹${NumberFormat('#,##,###').format(revisedTotal)}', 
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : _commitChanges,
              icon: isSaving 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(LucideIcons.checkSquare, size: 18),
              label: Text(isSaving ? 'UPLOADING...' : 'COMMIT & RESUBMIT', 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => setState(() => isEditing = false),
              child: const Text('DISCARD CHANGES', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: NexusTheme.slate400)),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('REVISED VALUATION', 
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text('₹${NumberFormat('#,##,###').format(revisedTotal)}', 
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
          ],
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => isEditing = false),
              child: const Text('DISCARD CHANGES', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: NexusTheme.slate400)),
            ),
            const SizedBox(width: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : _commitChanges,
                icon: isSaving 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(LucideIcons.checkSquare, size: 18),
                label: Text(isSaving ? 'UPLOADING...' : 'COMMIT & RESUBMIT FOR APPROVAL', 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkflowTrace(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
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
                label: const Text('VIEW FULL LOG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9)),
                style: TextButton.styleFrom(foregroundColor: NexusTheme.indigo600, padding: EdgeInsets.zero),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildTraceStep('PENDING CREDIT APPROVAL', true, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('ON HOLD', false, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('PENDING WH SELECTION', true, true, isMobile), 
          _buildTraceLine(),
          _buildTraceStep('PENDING PACKING', false, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('PART PACKED', false, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('PENDING QUALITY CONTROL', false, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('READY FOR BILLING', false, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('PENDING LOGISTICS', false, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('READY FOR DISPATCH', false, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('DISPATCHED', false, false, isMobile),
          _buildTraceLine(),
          _buildTraceStep('DELIVERED', false, false, isMobile),
        ],
      ),
    );
  }

  Widget _buildTraceStep(String label, bool completed, bool isActive, bool isMobile) {
    return Row(
      children: [
        Container(
          width: isMobile ? 24 : 32,
          height: isMobile ? 24 : 32,
          decoration: BoxDecoration(
            color: completed ? const Color(0xFFECFDF5) : (isActive ? const Color(0xFFEEF2FF) : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(
              color: completed ? const Color(0xFF10B981) : (isActive ? const Color(0xFF6366F1) : NexusTheme.slate200),
              width: 2,
            ),
          ),
          child: completed 
            ? Icon(Icons.check, size: isMobile ? 14 : 16, color: const Color(0xFF10B981))
            : (isActive ? Container(margin: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle)) : null),
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
      margin: const EdgeInsets.only(left: 15),
      width: 2,
      height: 32,
      color: NexusTheme.slate100,
    );
  }
}
