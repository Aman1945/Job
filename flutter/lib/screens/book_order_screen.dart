import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';

class BookOrderScreen extends StatefulWidget {
  const BookOrderScreen({super.key});

  @override
  State<BookOrderScreen> createState() => _BookOrderScreenState();
}

class _BookOrderScreenState extends State<BookOrderScreen> {
  Customer? selectedCustomer;
  List<Map<String, dynamic>> cartItems = [];
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NexusProvider>(context, listen: false);
      provider.fetchProducts();
      provider.fetchCustomers();
    });
  }

  void _addLineItem() {
    setState(() {
      cartItems.add({
        'productId': '',
        'productName': 'Select SKU...',
        'skuCode': '',
        'quantity': 1,
        'price': 0.0,
        'prevRate': 0.0,
      });
    });
  }

  void _updateLineItem(int index, Product product) {
    setState(() {
      cartItems[index] = {
        'productId': product.id,
        'productName': product.name,
        'skuCode': product.skuCode,
        'quantity': 1,
        'price': product.price,
        'prevRate': 0.0, // Example placeholder
      };
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  double get _cartTotal {
    return cartItems.fold(0, (sum, item) => sum + ((item['price'] as num) * (item['quantity'] as num)));
  }

  void _submitOrder() async {
    if (selectedCustomer == null || cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select customer and items')));
      return;
    }
    
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final success = await provider.createOrder(
      selectedCustomer!.id,
      selectedCustomer!.name,
      cartItems,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supply Request Committed Successfully!')),
      );
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
        title: const Text('CREATE NEW MISSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Customer Selection Section
            _buildSectionHeader('CUSTOMER SELECTION'),
            const SizedBox(height: 16),
            _buildCustomerDropdown(provider.customers),
            const SizedBox(height: 32),

            // 2. SKU Selection & Pricing Hub
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)],
              ),
              child: Column(
                children: [
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildMiniSectionHeader('SKU SELECTION & PRICING HUB', color: NexusTheme.indigo600),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _addLineItem,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('ADD LINE ITEM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: NexusTheme.indigo600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _buildMiniSectionHeader('SKU SELECTION & PRICING HUB', color: NexusTheme.indigo600)),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _addLineItem,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('ADD LINE ITEM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NexusTheme.indigo600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 24),
                  if (!isMobile) _buildTableHeader(),
                  const SizedBox(height: 12),
                  ...cartItems.asMap().entries.map((entry) => _buildLineItemRow(entry.key, entry.value, provider.products, isMobile)),
                  if (cartItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text('No items added. Click "+ ADD LINE ITEM" to begin.', style: TextStyle(color: NexusTheme.slate400, fontSize: 13, fontStyle: FontStyle.italic)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. Documentation & Instructions
            _buildResponsiveLayout(isMobile, [
              _buildDocumentationUpload(),
              _buildRemarksField(),
            ]),
            const SizedBox(height: 48),

            // 4. Footer Aggregate & Commit
            _buildFooter(isMobile),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 24, decoration: BoxDecoration(color: NexusTheme.emerald500, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildMiniSectionHeader(String title, {required Color color}) {
    return Row(
      children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1))),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title, 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerDropdown(List<Customer> customers) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<Customer>(
          isExpanded: true,
          hint: const Text('Search Organization Client Base...', style: TextStyle(fontSize: 14, color: NexusTheme.slate400, fontWeight: FontWeight.bold)),
          items: customers.map((Customer customer) => DropdownMenuItem<Customer>(
            value: customer,
            child: Text(customer.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          )).toList(),
          value: selectedCustomer,
          onChanged: (val) => setState(() => selectedCustomer = val),
          buttonStyleData: ButtonStyleData(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.white),
            offset: const Offset(0, -4),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('PRODUCT / SKU', style: _tableHeaderStyle)),
          Expanded(flex: 1, child: Text('UNIT', style: _tableHeaderStyle)),
          Expanded(flex: 1, child: Text('BASE RATE', style: _tableHeaderStyle)),
          Expanded(flex: 1, child: Text('PREV. RATE', style: _tableHeaderStyle)),
          Expanded(flex: 1, child: Text('QTY', style: _tableHeaderStyle)),
          Expanded(flex: 1, child: Text('FINAL RATE', style: _tableHeaderStyle, textAlign: TextAlign.center)),
          const SizedBox(width: 48), // Space for delete icon
        ],
      ),
    );
  }

  TextStyle get _tableHeaderStyle => const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5);

  Widget _buildLineItemRow(int index, Map<String, dynamic> item, List<Product> products, bool isMobile) {
    if (isMobile) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NexusTheme.slate200),
        ),
        child: Column(
          children: [
            _buildSKUDropdown(index, item, products),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildValueBox('QTY', item['quantity'].toString(), controller: true, onChanged: (val) {
                  setState(() => cartItems[index]['quantity'] = int.tryParse(val) ?? 1);
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildValueBox('RATE', '₹${item['price']}')),
                const SizedBox(width: 12),
                IconButton(onPressed: () => _removeLineItem(index), icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20)),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: _buildSKUDropdown(index, item, products)),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: _buildUnitBox('PCS')),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: Text('₹${item['price']}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.slate300, fontSize: 12))),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: Text('₹${item['prevRate']}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.slate300, fontSize: 12))),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: _buildQtyInput(index, item['quantity'])),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: _buildFinalRateDisplay((item['price'] as num) * (item['quantity'] as num))),
          const SizedBox(width: 16),
          IconButton(onPressed: () => _removeLineItem(index), icon: const Icon(LucideIcons.trash2, color: NexusTheme.slate200, size: 18)),
        ],
      ),
    );
  }

  Widget _buildSKUDropdown(int index, Map<String, dynamic> item, List<Product> products) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<Product>(
        isExpanded: true,
        hint: Text(item['productName'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NexusTheme.slate800)),
        items: products.map((Product p) => DropdownMenuItem<Product>(
          value: p,
          child: Text('${p.skuCode} - ${p.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        )).toList(),
        onChanged: (val) => _updateLineItem(index, val!),
        buttonStyleData: ButtonStyleData(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexusTheme.indigo600.withValues(alpha: 0.5)),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUnitBox(String unit) {
    return Container(
      height: 36,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: NexusTheme.slate200)),
      alignment: Alignment.center,
      child: Text(unit, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
    );
  }

  Widget _buildQtyInput(int index, int qty) {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(8)),
      child: TextFormField(
        initialValue: qty.toString(),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        onChanged: (val) {
          setState(() => cartItems[index]['quantity'] = int.tryParse(val) ?? 1);
        },
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _buildFinalRateDisplay(num total) {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text('${total.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildValueBox(String label, String value, {bool controller = false, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: NexusTheme.slate200)),
          alignment: Alignment.centerLeft,
          child: controller 
              ? TextFormField(
                  initialValue: value,
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true),
                )
              : Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildDocumentationUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMiniSectionHeader('DOCUMENTATION (PO / PDC COPY)', color: NexusTheme.emerald500),
        const SizedBox(height: 16),
        const Text('UPLOAD SCANNED DOCUMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: NexusTheme.slate400)),
        const SizedBox(height: 12),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: NexusTheme.slate200, style: BorderStyle.solid), // Should be dashed in reality
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: NexusTheme.slate50, shape: BoxShape.circle), child: const Icon(Icons.file_upload_outlined, color: NexusTheme.slate400)),
              const SizedBox(height: 16),
              const Text('ATTACH PO OR PDC SNAPSHOT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NexusTheme.slate800)),
              const Text('Supports JPG, PNG, PDF', style: TextStyle(fontSize: 9, color: NexusTheme.slate400, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('INTERNAL INSTRUCTIONS / REMARKS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: NexusTheme.slate400)),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: NexusTheme.slate200.withValues(alpha:0.5))),
          child: TextFormField(
            controller: _remarksController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Mention any special billing or delivery notes...',
              hintStyle: TextStyle(fontSize: 12, color: NexusTheme.slate400),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveLayout(bool isMobile, List<Widget> children) {
    if (isMobile) {
      return Column(children: children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 24), child: w)).toList());
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((w) => Expanded(child: Padding(padding: EdgeInsets.only(right: children.indexOf(w) == children.length - 1 ? 0 : 20), child: w))).toList(),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AGGREGATE VALUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400)),
                  const SizedBox(height: 4),
                  Text('₹${NumberFormat('#,##,###').format(_cartTotal)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitOrder,
                  icon: const Icon(LucideIcons.fileText, size: 18),
                  label: const Text('COMMIT SUPPLY REQUEST', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AGGREGATE VALUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400)),
                    Text('₹${NumberFormat('#,##,###').format(_cartTotal)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: _submitOrder,
                  icon: const Icon(LucideIcons.fileText, size: 20),
                  label: const Text('COMMIT SUPPLY REQUEST', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                  ),
                ),
              ),
            ],
          );
  }
}
