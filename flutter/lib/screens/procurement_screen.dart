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
  bool _showInboundForm = false;
  bool _isLoading = true;
  List<dynamic> _inbounds = [];
  final TextEditingController _supplierController = TextEditingController();
  String? _selectedSku;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await Provider.of<NexusProvider>(context, listen: false).fetchProcurementData();
    setState(() {
      _inbounds = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: NexusTheme.slate900, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Procurement Gate Terminal',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1, height: 1.1),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verify supplier inbound requirements & multi-stage\napproval',
                      style: TextStyle(fontSize: 14, color: NexusTheme.slate400, fontWeight: FontWeight.w500, height: 1.4),
                    ),
                    const SizedBox(height: 32),
                    
                    // Log New Inbound Button
                    SizedBox(
                      width: double.infinity,
                      height: 72,
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _showInboundForm = true),
                        icon: const Icon(Icons.add, color: Colors.white, size: 28),
                        label: const Text('LOG NEW INBOUND', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1), // Electric Indigo
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: NexusTheme.slate100, width: 2),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Supplier, SKU Name or Code...',
                      hintStyle: TextStyle(fontSize: 15, color: NexusTheme.slate300, fontWeight: FontWeight.w600),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.search, color: NexusTheme.slate300, size: 28),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Data Table Area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: NexusTheme.slate100),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: _buildProcurementTable(),
                  ),
                ),
              ),
            ],
          ),
          
          if (_showInboundForm) _buildInboundFormOverlay(),
        ],
      ),
    );
  }

  Widget _buildInboundFormOverlay() {
    final products = Provider.of<NexusProvider>(context).products;
    
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.92,
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text('Supply Inbound Form', 
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.cancel_rounded, color: Colors.white24, size: 28),
                      onPressed: () => setState(() => _showInboundForm = false),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                _buildFormLabel('SUPPLIER NAME'),
                const SizedBox(height: 12),
                _buildFormInput('Enter vendor identity...', controller: _supplierController),
                
                const SizedBox(height: 28),
                
                _buildFormLabel('TARGET SKU'),
                const SizedBox(height: 12),
                _buildSkuSelector(products),

                const SizedBox(height: 48),
                
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_supplierController.text.isEmpty) return;
                      final success = await Provider.of<NexusProvider>(context, listen: false).createProcurementEntry({
                        'vendor': _supplierController.text,
                        'sku': _selectedSku ?? (products.isNotEmpty ? products.first.name : 'Unknown SKU'),
                        'code': products.firstWhere(
                          (p) => p.name == _selectedSku, 
                          orElse: () => products.isNotEmpty ? products.first : Product(id: '', skuCode: '', name: '', price: 0, stock: 0, category: 'General')
                        ).skuCode,
                      });
                      if (success) {
                        _supplierController.clear();
                        setState(() {
                          _selectedSku = null;
                          _showInboundForm = false;
                        });
                        await _loadData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('REGISTER INBOUND ENTRY', 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Text(label, style: const TextStyle(color: Color(0xFF818CF8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5));
  }

  Widget _buildFormInput(String hint, {TextEditingController? controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white12, fontSize: 13, fontWeight: FontWeight.w600),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSkuSelector(List<Product> products) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSku,
          hint: Text(products.isNotEmpty ? products.first.name : 'Select SKU...', 
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
            overflow: TextOverflow.ellipsis,
          ),
          dropdownColor: const Color(0xFF1E293B),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
          selectedItemBuilder: (context) {
            return products.map<Widget>((p) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  p.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
          items: products.map((p) => DropdownMenuItem(
            value: p.name,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(p.name, 
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                softWrap: true,
              ),
            ),
          )).toList(),
          onChanged: (v) => setState(() => _selectedSku = v),
        ),
      ),
    );
  }

  Widget _buildProcurementTable() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
    if (_inbounds.isEmpty) return const Center(child: Text('No Inbound Missions Found', style: TextStyle(color: NexusTheme.slate400)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 72,
        dataRowMinHeight: 100,
        dataRowMaxHeight: 100,
        horizontalMargin: 32,
        columnSpacing: 60,
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate200, letterSpacing: 1),
        columns: const [
          DataColumn(label: Text('MISSION REF')),
          DataColumn(label: Text('VENDOR / SUPPLIER')),
          DataColumn(label: Text('MATERIAL SKU')),
          DataColumn(label: Text('CHECKS')),
          DataColumn(label: Text('STAGE')),
        ],
        rows: _inbounds.map((item) {
          return DataRow(cells: [
            DataCell(Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['ref']?.toString() ?? 'PRC-1001', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1), fontSize: 16)),
                const SizedBox(height: 2),
                Text('10/02/2026', style: const TextStyle(color: NexusTheme.slate300, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            )),
            DataCell(Text(item['vendor']?.toString() ?? 'Global Fisheries Ltd', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)))),
            DataCell(Text(item['sku']?.toString() ?? 'Unknown SKU', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)))),
            DataCell(Icon(Icons.check_circle_rounded, color: NexusTheme.emerald500.withOpacity(0.5), size: 20)),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(item['stage']?.toString() ?? 'PENDING', style: const TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1)),
            )),
          ]);
        }).toList(),
      ),
    );
  }
}
