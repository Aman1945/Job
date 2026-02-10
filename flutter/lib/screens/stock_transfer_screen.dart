import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class StockTransferScreen extends StatefulWidget {
  const StockTransferScreen({super.key});

  @override
  State<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends State<StockTransferScreen> {
  String? selectedSource;
  String? selectedDestination;
  List<Map<String, dynamic>> transferItems = [];
  final _remarksController = TextEditingController();

  final List<String> warehouses = [
    'IOPL Kurla',
    'IOPL DP WORLD',
    'IOPL Arihant Delhi',
    'IOPL Jolly Bng',
    'IOPL Hyderabad',
    'IOPL Chennai'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NexusProvider>(context, listen: false).fetchProducts();
    });
  }

  void _addLineItem() {
    setState(() {
      transferItems.add({
        'productId': '',
        'productName': 'Select SKU...',
        'skuCode': '',
        'quantity': 1,
        'unit': 'PCS',
      });
    });
  }

  void _updateLineItem(int index, Product product) {
    setState(() {
      transferItems[index] = {
        'productId': product.id,
        'productName': product.name,
        'skuCode': product.skuCode,
        'quantity': 1,
        'unit': 'PCS',
      };
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      transferItems.removeAt(index);
    });
  }

  Future<void> _submitSTN() async {
    if (selectedSource == null || selectedDestination == null || transferItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select origin, destination and items')));
      return;
    }

    if (selectedSource == selectedDestination) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Origin and Destination cannot be same')));
      return;
    }

    final provider = Provider.of<NexusProvider>(context, listen: false);
    final success = await provider.createSTN({
      'sourceWarehouse': selectedSource,
      'destinationWarehouse': selectedDestination,
      'items': transferItems,
      'remarks': _remarksController.text,
      'customerName': selectedDestination, // For generic order tracking
      'customerId': selectedDestination,
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('STN Dispatched Successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('1.1 STOCK TRANSFER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
            IconButton(onPressed: () => setState(() {
                  selectedSource = null;
                  selectedDestination = null;
                  transferItems = [];
                  _remarksController.clear();
            }), icon: const Icon(Icons.refresh, size: 20))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          children: [
             // Header Card matching screenshot
            _buildSTNHeaderCard(isMobile),
            const SizedBox(height: 32),

            // Origin & Destination Row
            _buildResponsiveLayout(isMobile, [
                _buildWarehouseSelector('SOURCE WAREHOUSE (FROM)', selectedSource, (val) => setState(() => selectedSource = val), Icons.home_work_outlined),
                _buildWarehouseSelector('DESTINATION WAREHOUSE (TO)', selectedDestination, (val) => setState(() => selectedDestination = val), Icons.arrow_forward),
            ]),
            const SizedBox(height: 32),

            // Inventory List Section
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Expanded(child: _buildMiniSectionHeader('INVENTORY LIST FOR TRANSFER')),
                            const SizedBox(width: 12),
                            _buildAddButton(),
                        ],
                    ),
                    const SizedBox(height: 24),
                    if (!isMobile) _buildTableHeader(),
                    const SizedBox(height: 12),
                    ...transferItems.asMap().entries.map((e) => _buildItemRow(e.key, e.value, provider.products, isMobile)),
                    if (transferItems.isEmpty) _buildEmptyState(),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Remarks Section
            _buildRemarksSection(),
            const SizedBox(height: 32),

            // Info Box and Dispatch Button
            _buildFooter(isMobile),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSTNHeaderCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1), // Purple from screenshot
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Expanded(
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stock Transfer Note (STN)', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                const SizedBox(height: 8),
                Text('Internal facility movement - No credit approval required', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
             ),
           ),
           if (!isMobile)
             const Icon(LucideIcons.repeat, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildWarehouseSelector(String label, String? value, Function(String?) onChanged, IconData icon) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
         const SizedBox(height: 12),
         Container(
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(20),
             border: Border.all(color: value != null ? const Color(0xFF6366F1).withOpacity(0.5) : NexusTheme.slate200),
           ),
           child: DropdownButtonHideUnderline(
             child: DropdownButton2<String>(
               isExpanded: true,
               hint: Text(value ?? 'Select...', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
               items: warehouses.map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))).toList(),
               onChanged: onChanged,
               buttonStyleData: ButtonStyleData(height: 64, padding: const EdgeInsets.symmetric(horizontal: 20)),
               iconStyleData: IconStyleData(icon: Icon(icon, color: NexusTheme.slate300, size: 24)),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              offset: const Offset(0, -4),
            ),
             ),
           ),
         ),
       ],
     );
  }

  Widget _buildMiniSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1));
  }

  Widget _buildAddButton() {
     return ElevatedButton.icon(
        onPressed: _addLineItem,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('ADD LINE ITEM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
     );
  }

  Widget _buildTableHeader() {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
              children: [
                  Expanded(flex: 5, child: Text('MATERIAL DESCRIPTION / SKU', style: _headerStyle)),
                  Expanded(flex: 1, child: Text('UNIT', style: _headerStyle, textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('TRANSFER QTY', style: _headerStyle, textAlign: TextAlign.center)),
                  const Expanded(flex: 1, child: Text('ACTION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400), textAlign: TextAlign.center)),
              ],
          ),
      );
  }

  TextStyle get _headerStyle => const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5);

  Widget _buildItemRow(int index, Map<String, dynamic> item, List<Product> products, bool isMobile) {
      if (isMobile) {
          return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16), border: Border.all(color: NexusTheme.slate200)),
              child: Column(
                  children: [
                       _buildSKUDropdown(index, item, products),
                       const SizedBox(height: 12),
                       Row(
                           children: [
                               Expanded(child: _buildUnitDisplay('PCS')),
                               const SizedBox(width: 12),
                               Expanded(child: _buildQtyInput(index, item['quantity'])),
                               const SizedBox(width: 12),
                               IconButton(onPressed: () => _removeLineItem(index), icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20)),
                           ],
                       ),
                  ],
              ),
          );
      }

      return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16), border: Border.all(color: NexusTheme.slate200)),
          child: Row(
              children: [
                  Expanded(flex: 5, child: _buildSKUDropdown(index, item, products)),
                  const SizedBox(width: 12),
                  Expanded(flex: 1, child: _buildUnitDisplay('PCS')),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildQtyInput(index, item['quantity'])),
                  const SizedBox(width: 12),
                  Expanded(flex: 1, child: IconButton(onPressed: () => _removeLineItem(index), icon: const Icon(LucideIcons.trash2, color: NexusTheme.slate200, size: 18))),
              ],
          ),
      );
  }

  Widget _buildSKUDropdown(int index, Map<String, dynamic> item, List<Product> products) {
      return DropdownButtonHideUnderline(
          child: DropdownButton2<Product>(
              isExpanded: true,
              hint: Text(item['productName'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              items: products.map((p) => DropdownMenuItem(value: p, child: Text('${p.skuCode} - ${p.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
              onChanged: (val) => _updateLineItem(index, val!),
              buttonStyleData: ButtonStyleData(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5)), color: Colors.white),
              ),
          ),
      );
  }

  Widget _buildUnitDisplay(String unit) {
      return Container(
          height: 38,
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(unit, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B))),
      );
  }

  Widget _buildQtyInput(int index, int qty) {
      return Container(
          height: 44,
          decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(12)),
          child: TextFormField(
              initialValue: qty.toString(),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              onChanged: (val) => transferItems[index]['quantity'] = int.tryParse(val) ?? 1,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
          ),
      );
  }

  Widget _buildEmptyState() {
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text('NO ITEMS LISTED IN STN.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate300, letterSpacing: 1)),
      );
  }

  Widget _buildRemarksSection() {
       return Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
               _buildMiniSectionHeader('REMARKS / REASON FOR TRANSFER'),
               const SizedBox(height: 16),
               Container(
                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: NexusTheme.slate200.withOpacity(0.5))),
                   padding: const EdgeInsets.all(20),
                   child: TextFormField(
                       controller: _remarksController,
                       maxLines: 4,
                       decoration: const InputDecoration(
                           hintText: 'e.g. Stock replenishment for North Hub, Regional balance update...',
                           hintStyle: TextStyle(fontSize: 13, color: NexusTheme.slate400),
                           border: InputBorder.none,
                       ),
                   ),
               ),
           ],
       );
  }

  Widget _buildFooter(bool isMobile) {
      return _buildResponsiveLayout(isMobile, [
           Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.withOpacity(0.2))),
               child: Row(
                   children: [
                       const Icon(LucideIcons.package, color: Colors.orange, size: 24),
                       const SizedBox(width: 16),
                       const Expanded(
                           child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                   Text('BYPASSING CREDIT CONTROL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.orange)),
                                   Text('STN request routes directly to Warehouse Selection', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w500)),
                               ],
                           ),
                       ),
                   ],
               ),
           ),
           SizedBox(
               height: 64,
               width: double.infinity,
               child: ElevatedButton.icon(
                   onPressed: _submitSTN,
                   icon: const Icon(LucideIcons.filePlus, size: 18),
                   label: const Text('DISPATCH STN REQUEST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                   style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFFC7D2FE), // Light blueish/purple from screenshot
                       foregroundColor: const Color(0xFF6366F1),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                   ),
               ),
           ),
      ]);
  }

  Widget _buildResponsiveLayout(bool isMobile, List<Widget> children) {
       if (isMobile) {
           return Column(children: children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 20), child: w)).toList());
       }
       return Row(
           children: children.map((w) => Expanded(child: Padding(padding: EdgeInsets.only(right: children.indexOf(w) == children.length - 1 ? 0 : 24), child: w))).toList(),
       );
  }
}
