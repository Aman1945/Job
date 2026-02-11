import 'package:flutter/material.dart';
import 'package:nexus_oms_mobile/models/models.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';

class ProcurementScreen extends StatefulWidget {
  const ProcurementScreen({super.key});

  @override
  State<ProcurementScreen> createState() => _ProcurementScreenState();
}

class _ProcurementScreenState extends State<ProcurementScreen> {
  bool _showForm = false;
  String _searchTerm = '';
  final _supplierController = TextEditingController();
  final _skuCodeController = TextEditingController();
  final _skuNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NexusProvider>(context, listen: false).fetchProcurementItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final user = provider.currentUser;
    final isStaff = user?.role == UserRole.procurement || user?.role == UserRole.admin;
    final isHead = user?.role == UserRole.procurementHead || user?.role == UserRole.admin;

    final filteredItems = provider.procurementItems.where((item) =>
      item.supplierName.toLowerCase().contains(_searchTerm.toLowerCase()) ||
      item.skuName.toLowerCase().contains(_searchTerm.toLowerCase()) ||
      item.id.toLowerCase().contains(_searchTerm.toLowerCase())
    ).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('PROCUREMENT GATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: NexusTheme.slate900, letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NexusTheme.slate900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isStaff),
                const SizedBox(height: 32),
                _buildSearchBar(),
                const SizedBox(height: 24),
                if (_showForm) _buildInboundForm(provider),
                _buildItemsList(filteredItems, isMobile, isStaff, isHead, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isStaff) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Inbound Terminal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.5)),
              Text('Verify supply requirements & clearances', style: TextStyle(fontSize: 13, color: NexusTheme.slate400, fontWeight: FontWeight.w500)),
            ],
          ),
          if (isStaff)
            IconButton.filled(
              onPressed: () => setState(() => _showForm = !_showForm),
              icon: Icon(_showForm ? Icons.close : Icons.add),
              style: IconButton.styleFrom(backgroundColor: NexusTheme.indigo600, foregroundColor: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 52,
        decoration: BoxDecoration(color: NexusTheme.slate50, borderRadius: BorderRadius.circular(16), border: Border.all(color: NexusTheme.slate100)),
        child: TextField(
          onChanged: (v) => setState(() => _searchTerm = v),
          decoration: const InputDecoration(
            hintText: 'Search Supplier, SKU or ID...',
            hintStyle: TextStyle(fontSize: 14, color: NexusTheme.slate300, fontWeight: FontWeight.w600),
            prefixIcon: Icon(Icons.search, size: 20, color: NexusTheme.slate300),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildInboundForm(NexusProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LOG NEW INBOUND', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          _buildInput('SUPPLIER NAME', _supplierController, 'Enter vendor...'),
          const SizedBox(height: 20),
          _buildInput('SKU NAME', _skuNameController, 'e.g. Broken Rice'),
          const SizedBox(height: 20),
          _buildInput('SKU CODE', _skuCodeController, 'e.g. SKU-101'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                if (_supplierController.text.isEmpty) return;
                final success = await provider.createProcurementEntry({
                  'supplierName': _supplierController.text,
                  'skuName': _skuNameController.text,
                  'skuCode': _skuCodeController.text,
                });
                if (success) {
                  setState(() => _showForm = false);
                  _supplierController.clear();
                  _skuNameController.clear();
                  _skuCodeController.clear();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: NexusTheme.indigo600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('REGISTER ENTRY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF818CF8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white12), border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(List<ProcurementItem> items, bool isMobile, bool isStaff, bool isHead, NexusProvider provider) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: const Center(child: Text('ALL CLEAR. NO MISSIONS DETECTED.', style: TextStyle(color: NexusTheme.slate200, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic))),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: items.map((item) => _buildItemCard(item, isStaff, isHead, provider)).toList(),
      ),
    );
  }

  Widget _buildItemCard(ProcurementItem item, bool isStaff, bool isHead, NexusProvider provider) {
    final Color statusColor = item.status == 'Approved' ? NexusTheme.emerald600 : item.status == 'Pending' ? NexusTheme.amber600 : NexusTheme.indigo600;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: NexusTheme.slate100)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(item.status == 'Approved' ? Icons.check_circle_rounded : Icons.inventory_2_rounded, color: statusColor, size: 24),
        ),
        title: Row(
          children: [
            Text(item.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: NexusTheme.indigo600)),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  item.status.toUpperCase(),
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: statusColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(item.supplierName.toUpperCase(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 16),
                Text(item.skuName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('CODE: ${item.skuCode}', style: const TextStyle(fontSize: 10, color: NexusTheme.indigo600, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCheck(Icons.fact_check_rounded, 'SIP', item.sipChecked, () => _toggle(provider, item, 'sipChecked', !item.sipChecked)),
                    _buildCheck(Icons.label_important_rounded, 'LBL', item.labelsChecked, () => _toggle(provider, item, 'labelsChecked', !item.labelsChecked)),
                    _buildCheck(Icons.file_present_rounded, 'DOC', item.docsChecked, () => _toggle(provider, item, 'docsChecked', !item.docsChecked)),
                  ],
                ),
                const SizedBox(height: 24),
                if (item.status == 'Pending' && isStaff)
                  _buildActionButton('SUBMIT TO HEAD', Icons.send_rounded, NexusTheme.indigo600, () => _updateStatus(provider, item, 'Awaiting Head Approval')),
                if (item.status == 'Awaiting Head Approval' && isHead)
                  _buildActionButton('FINAL APPROVAL', Icons.verified_user_rounded, NexusTheme.emerald600, () => _updateStatus(provider, item, 'Approved')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheck(IconData icon, String label, bool checked, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: checked ? NexusTheme.indigo600 : NexusTheme.slate50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: checked ? Colors.white : NexusTheme.slate300, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: checked ? NexusTheme.indigo600 : NexusTheme.slate300)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  void _toggle(NexusProvider provider, ProcurementItem item, String field, bool value) {
    provider.updateProcurementItem(item.id, {field: value});
  }

  void _updateStatus(NexusProvider provider, ProcurementItem item, String status) {
    if (!item.sipChecked || !item.labelsChecked || !item.docsChecked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete all checks first!')));
      return;
    }
    provider.updateProcurementItem(item.id, {'status': status});
  }
}
