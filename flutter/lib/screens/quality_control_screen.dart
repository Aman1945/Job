import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class QualityControlScreen extends StatefulWidget {
  const QualityControlScreen({super.key});

  @override
  State<QualityControlScreen> createState() => _QualityControlScreenState();
}

class _QualityControlScreenState extends State<QualityControlScreen> {
  Order? _selectedOrder;
  final Map<String, bool> _inspectionPoints = {
    'TEMPERATURE STANDARD\nFrozen: -18°C / Fresh: 0-4°C': false,
    'PACKAGING INTEGRITY\nNo leaks, damage or dents': false,
    'NET WEIGHT VERIFIED\nMatch vs Packing Slip': false,
    'LABEL & BATCH CLARITY\nLegible expiry & barcode': false,
    'INVOICE / DC ATTACHED\nPhysical copies with load': false,
  };
  File? _proofImage;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final qcOrders = provider.orders.where((o) => o.status == 'Pending Quality Control').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('3.5 QUALITY CONTROL TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          if (isMobile) {
            return _selectedOrder == null
                ? _buildOrderList(qcOrders, isMobile)
                : _buildInspectionPanel(_selectedOrder!, isMobile);
          }
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(color: const Color(0xFFF8FAFC), child: _buildOrderList(qcOrders, isMobile)),
              ),
              Expanded(
                flex: 3,
                child: _selectedOrder != null
                    ? _buildInspectionPanel(_selectedOrder!, isMobile)
                    : const Center(child: Text('Select a mission to inspect', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
              ),
            ],
          );
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
            const Icon(LucideIcons.clipboardCheck, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('NO PENDING INSPECTIONS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isSelected = _selectedOrder?.id == order.id;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedOrder = order;
            _inspectionPoints.updateAll((key, val) => false);
            _proofImage = null;
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? const Color(0xFF6366F1) : Colors.transparent, width: 2),
              boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.1), blurRadius: 20)] : [],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.shieldCheck, color: Color(0xFF6366F1)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF6366F1))),
                      const SizedBox(height: 4),
                      Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('LOAD: ${order.items.length} SKUs', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInspectionPanel(Order order, bool isMobile) {
    bool allChecked = _inspectionPoints.values.every((v) => v);
    return Container(
      color: const Color(0xFF0F172A),
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Standard Inspection', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('ORDER REF: ${order.id}', style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                onPressed: () => setState(() => _selectedOrder = null),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ..._inspectionPoints.keys.map((label) => _buildChecklistItem(label)),
                  const SizedBox(height: 32),
                  _buildPhotoUploadArea(),
                  if (_proofImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                          const SizedBox(width: 8),
                          const Text('PHOTO READY — WILL UPLOAD ON APPROVAL', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (allChecked && !_isUploading) ? () => _approveInspection(order) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                disabledBackgroundColor: Colors.grey[800],
              ),
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        SizedBox(width: 12),
                        Text('UPLOADING PHOTO...', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.white)),
                      ],
                    )
                  : const Text('APPROVE & PUSH TO LOGISTICS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
          if (!allChecked && !_isUploading)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Center(child: Text('Complete all checks to proceed', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold))),
            ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String label) {
    final title = label.split('\n')[0];
    final subtitle = label.split('\n')[1];
    final isChecked = _inspectionPoints[label] ?? false;
    return GestureDetector(
      onTap: () => setState(() => _inspectionPoints[label] = !isChecked),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isChecked ? const Color(0xFF10B981) : const Color(0xFF334155)),
        ),
        child: Row(
          children: [
            Icon(isChecked ? LucideIcons.checkCircle : LucideIcons.circle,
                color: isChecked ? const Color(0xFF10B981) : const Color(0xFF334155)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isChecked ? Colors.white : const Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUploadArea() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _proofImage != null ? const Color(0xFF10B981) : const Color(0xFF334155),
          width: _proofImage != null ? 2 : 1,
        ),
      ),
      child: _proofImage != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(23), child: Image.file(_proofImage!, fit: BoxFit.cover)),
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _proofImage = null),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.camera, color: Color(0xFF6366F1), size: 32),
                  onPressed: _pickImage,
                ),
                const SizedBox(height: 12),
                const Text('VISUAL VERIFICATION (PHOTO)', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 10)),
                const SizedBox(height: 4),
                const Text('Tap camera to capture proof', style: TextStyle(color: Color(0xFF475569), fontSize: 10)),
              ],
            ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (pickedFile != null) setState(() => _proofImage = File(pickedFile.path));
  }

  void _approveInspection(Order order) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    setState(() => _isUploading = true);

    // Upload QC proof photo to DO Spaces if captured
    String? qcPhotoUrl;
    if (_proofImage != null) {
      qcPhotoUrl = await provider.uploadPhoto(_proofImage!, folder: 'qc-photos');
    }

    // Update order status
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await provider.updateOrderStatus(order.id, 'Pending Logistics Cost', token: auth.token);

    // Save qcPhoto URL to the order record
    if (qcPhotoUrl != null) {
      await provider.patchOrderField(order.id, {'qcPhoto': qcPhotoUrl});
    }

    if (mounted) {
      setState(() { _isUploading = false; _selectedOrder = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(qcPhotoUrl != null
            ? 'Inspection Approved! Photo saved to cloud. ✅'
            : 'Inspection Approved! Sent to Logistics Terminal.')),
      );
    }
  }
}
