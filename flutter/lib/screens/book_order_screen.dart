import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BookOrderScreen extends StatefulWidget {
  const BookOrderScreen({super.key});

  @override
  State<BookOrderScreen> createState() => _BookOrderScreenState();
}

class _BookOrderScreenState extends State<BookOrderScreen> {
  Customer? selectedCustomer;
  List<Map<String, dynamic>> cartItems = [];
  final _remarksController = TextEditingController();
  final List<File?> _salesPhotos = [null, null, null]; // 3 sales photo slots
  bool _isSubmitting = false;

  // Zone & Hierarchy state
  String _selectedZone = 'PAN INDIA';
  User? _selectedRSM;
  User? _selectedASM;
  User? _selectedSE;

  static const List<String> _zones = ['PAN INDIA', 'NORTH', 'SOUTH', 'EAST', 'WEST'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NexusProvider>(context, listen: false);
      provider.fetchProducts();
      provider.fetchCustomers();
      provider.fetchUsers();
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
        'imageUrl': '',
      });
    });
  }

  void _updateLineItem(int index, Product product) {
    final rate = product.price > 0 ? product.price : (product.mrp ?? 0.0);
    setState(() {
      cartItems[index] = {
        'productId': product.id,
        'productName': product.name,
        'skuCode': product.skuCode,
        'quantity': 1,
        'price': rate,
        'prevRate': 0.0,
        'imageUrl': product.imageUrl ?? '',
        'mrp': product.mrp ?? rate,
        'gst': product.gst ?? 18.0,
      };
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  double get _cartSubTotal {
    return cartItems.fold(0, (sum, item) => sum + ((item['price'] as num) * (item['quantity'] as num)));
  }

  double get _gstTotal => _cartSubTotal * 0.18;
  double get _cartTotal => _cartSubTotal + _gstTotal;

  void _submitOrder() async {
    if (selectedCustomer == null || cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select customer and items')));
      return;
    }
    setState(() => _isSubmitting = true);
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false); // Added to get token
    final photos = _salesPhotos.whereType<File>().toList();
    
    try {
      final success = await provider.createOrder(
        selectedCustomer!.id,
        selectedCustomer!.name,
        cartItems,
        photos: photos,
        remarks: _remarksController.text,
        token: authProvider.token, // Passing token
      );

      if (mounted) setState(() => _isSubmitting = false);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supply Request Committed Successfully! 🚀')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit order: $e'),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Deduplicated customers filtered by zone
  List<Customer> _filteredCustomers(List<Customer> all) {
    // Deduplicate by ID first (fixes assertion error)
    final seen = <String>{};
    final unique = all.where((c) => seen.add(c.id)).toList();

    // Zone selection removed for mission creation – always show all customers
    return unique;
  }

  /// Users filtered by zone (non-admin)
  List<User> _zoneUsers(List<User> users) {
    // Zone selection removed – allow assigning from all non-admin users
    return users.where((u) => u.role != UserRole.admin).toList();
  }

  /// RSM list from zone users
  List<User> _rsmList(List<User> users) => _zoneUsers(users)
      .where((u) => u.role == UserRole.rsm || u.role == UserRole.sales)
      .toList();

  /// ASM list
  List<User> _asmList(List<User> users) => _zoneUsers(users)
      .where((u) => u.role == UserRole.asm)
      .toList();

  /// Sales Executive list
  List<User> _seList(List<User> users) => _zoneUsers(users)
      .where((u) => u.role == UserRole.salesExecutive ||
                    u.role.label.toLowerCase().contains('executive'))
      .toList();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 768;
    final bool isAdmin = authProvider.currentUser?.role == UserRole.admin;

    final filteredCustomers = _filteredCustomers(provider.customers);

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

            // ── CUSTOMER SELECTION ───────────────────────────────────────
            _buildSectionHeader('CUSTOMER SELECTION'),
            const SizedBox(height: 16),
            _buildCustomerDropdown(filteredCustomers),
            const SizedBox(height: 20),

            // ── CREDIT EXPOSURE TABLE ────────────────────────────────────
            if (selectedCustomer != null) ...[
              _buildCreditExposureTable(selectedCustomer!),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 12),

            // ── SKU Selection & Pricing Hub ──────────────────────────────
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
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

            // ── Documentation & Instructions ─────────────────────────────
            _buildResponsiveLayout(isMobile, [
              _buildDocumentationUpload(),
              _buildRemarksField(),
            ]),
            const SizedBox(height: 48),

            // ── Footer ───────────────────────────────────────────────────
            _buildFooter(isMobile),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Zone Chips ────────────────────────────────────────────────────────────

  Widget _buildZoneChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _zones.map((zone) {
          final isSelected = zone == _selectedZone;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedZone = zone;
              _selectedRSM = null;
              _selectedASM = null;
              _selectedSE = null;
              selectedCustomer = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    zone == 'PAN INDIA' ? Icons.public : Icons.location_on_outlined,
                    size: 13,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    zone,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Hierarchy Panel ───────────────────────────────────────────────────────

  Widget _buildHierarchyPanel(List<User> users, bool isMobile) {
    final rsmList = _rsmList(users);
    final asmList = _asmList(users);
    final seList = _seList(users);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NexusTheme.indigo600.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.account_tree_outlined, size: 16, color: NexusTheme.indigo600),
              ),
              const SizedBox(width: 10),
              const Text(
                'SALES HIERARCHY',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (_selectedRSM != null || _selectedASM != null || _selectedSE != null)
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedRSM = null;
                    _selectedASM = null;
                    _selectedSE = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('CLEAR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.red.shade400)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          isMobile
              ? Column(
                  children: [
                    _buildHierarchyDropdown('RSM', rsmList, _selectedRSM, (u) => setState(() { _selectedRSM = u; _selectedASM = null; _selectedSE = null; })),
                    const SizedBox(height: 12),
                    _buildHierarchyDropdown('ASM', asmList, _selectedASM, (u) => setState(() { _selectedASM = u; _selectedSE = null; })),
                    const SizedBox(height: 12),
                    _buildHierarchyDropdown('SALES EXECUTIVE', seList, _selectedSE, (u) => setState(() => _selectedSE = u)),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildHierarchyDropdown('RSM', rsmList, _selectedRSM, (u) => setState(() { _selectedRSM = u; _selectedASM = null; _selectedSE = null; }))),
                    const SizedBox(width: 12),
                    const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: _buildHierarchyDropdown('ASM', asmList, _selectedASM, (u) => setState(() { _selectedASM = u; _selectedSE = null; }))),
                    const SizedBox(width: 12),
                    const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: _buildHierarchyDropdown('SALES EXECUTIVE', seList, _selectedSE, (u) => setState(() => _selectedSE = u))),
                  ],
                ),
          // Selected team summary
          if (_selectedRSM != null || _selectedASM != null || _selectedSE != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (_selectedRSM != null) _buildAssignedChip('RSM', _selectedRSM!.name, const Color(0xFF7C3AED)),
                if (_selectedASM != null) _buildAssignedChip('ASM', _selectedASM!.name, NexusTheme.indigo600),
                if (_selectedSE != null) _buildAssignedChip('SE', _selectedSE!.name, const Color(0xFF059669)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHierarchyDropdown(String label, List<User> users, User? selected, ValueChanged<User?> onChanged) {
    // Deduplicate users by id
    final seen = <String>{};
    final unique = users.where((u) => seen.add(u.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Color(0xFF94A3B8),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected != null ? NexusTheme.indigo600.withOpacity(0.4) : const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<User>(
              isExpanded: true,
              hint: Text(
                unique.isEmpty ? 'No ${label}s in zone' : 'Select $label...',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
              items: unique.map((u) => DropdownMenuItem<User>(
                value: u,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(u.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    Text(u.zone, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                  ],
                ),
              )).toList(),
              value: selected,
              onChanged: unique.isEmpty ? null : onChanged,
              buttonStyleData: ButtonStyleData(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 250,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignedChip(String role, String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            '$role: $name',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  // ── Section Headers ───────────────────────────────────────────────────────

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

  // ── Customer Dropdown (deduplicated + zone-filtered) ──────────────────────

  Widget _buildCustomerDropdown(List<Customer> customers) {
    // Ensure selectedCustomer is still in the filtered list; if not, clear it
    if (selectedCustomer != null && !customers.any((c) => c.id == selectedCustomer!.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => selectedCustomer = null);
      });
    }
    // Deduplicate customers by ID to prevent DropdownButton duplicate value AssertionErrors
    final seen = <String>{};
    final uniqueCustomers = customers.where((c) => seen.add(c.id)).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<Customer>(
          isExpanded: true,
          hint: Text(
            uniqueCustomers.isEmpty
                ? 'No customers in $_selectedZone zone'
                : 'Search Organization Client Base...',
            style: const TextStyle(fontSize: 14, color: NexusTheme.slate400, fontWeight: FontWeight.bold),
          ),
          items: uniqueCustomers.map((Customer customer) => DropdownMenuItem<Customer>(
            value: customer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(customer.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                if (customer.location != null)
                  Text(customer.location!, style: const TextStyle(fontSize: 10, color: NexusTheme.slate400)),
              ],
            ),
          )).toList(),
          value: uniqueCustomers.any((c) => c.id == selectedCustomer?.id) ? selectedCustomer : null,
          onChanged: uniqueCustomers.isEmpty ? null : (val) => setState(() => selectedCustomer = val),
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
          dropdownSearchData: DropdownSearchData(
            searchController: TextEditingController(),
            searchInnerWidgetHeight: 50,
            searchInnerWidget: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextFormField(
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  hintText: 'Search customer...',
                  hintStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              return item.value!.name.toLowerCase().contains(searchValue.toLowerCase());
            },
          ),
        ),
      ),
    );
  }

  // ── Table ─────────────────────────────────────────────────────────────────

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
          Expanded(flex: 2, child: Text('FINAL RATE', style: _tableHeaderStyle, textAlign: TextAlign.center)),
          const SizedBox(width: 48),
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
          Expanded(flex: 2, child: _buildFinalRateDisplay((item['price'] as num) * (item['quantity'] as num))),
          const SizedBox(width: 16),
          IconButton(onPressed: () => _removeLineItem(index), icon: const Icon(LucideIcons.trash2, color: NexusTheme.slate200, size: 18)),
        ],
      ),
    );
  }

  Widget _buildSKUDropdown(int index, Map<String, dynamic> item, List<Product> products) {
    // Deduplicate products by id
    final seen = <String>{};
    final unique = products.where((p) => seen.add(p.id)).toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton2<Product>(
        isExpanded: true,
        hint: Text(item['productName'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NexusTheme.slate800)),
        items: unique.map((Product p) => DropdownMenuItem<Product>(
          value: p,
          child: Text('${p.skuCode} - ${p.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        )).toList(),
        onChanged: (val) => _updateLineItem(index, val!),
        buttonStyleData: ButtonStyleData(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexusTheme.indigo600.withOpacity(0.5)),
            color: Colors.white,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 400,
          width: 400,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
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
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // QTY value
          SizedBox(
            width: 28,
            child: Text(
              qty.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          // Vertical up/down arrows
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => cartItems[index]['quantity'] = qty + 1),
                child: const Icon(Icons.keyboard_arrow_up_rounded, size: 18, color: Color(0xFF64748B)),
              ),
              GestureDetector(
                onTap: () {
                  if (qty > 1) setState(() => cartItems[index]['quantity'] = qty - 1);
                },
                child: Icon(Icons.keyboard_arrow_down_rounded, size: 18,
                    color: qty > 1 ? const Color(0xFF64748B) : const Color(0xFFCBD5E1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Credit Exposure Table ─────────────────────────────────────────────────

  Widget _buildCreditExposureTable(Customer customer) {
    final limit   = customer.limit;
    final balance = customer.osBalance;
    final overdue = customer.overdue;
    // Pull aging buckets from agingData map if available
    final aging = customer.agingData;
    final bucket0  = (aging['0to7']   ?? aging['0-7']   ?? (overdue == 0 ? balance : 0)).toDouble();
    final bucket7  = (aging['7to15']  ?? aging['7-15']  ?? 0).toDouble();
    final bucket15 = (aging['15to30'] ?? aging['15-30'] ?? 0).toDouble();
    final bucket30 = (aging['30to45'] ?? aging['30-45'] ?? 0).toDouble();
    final bucket45 = (aging['45to90'] ?? aging['45-90'] ?? 0).toDouble();
    final bucket90 = (aging['90to120']  ?? aging['90-120']  ?? 0).toDouble();
    final bucket120= (aging['120to150'] ?? aging['120-150'] ?? 0).toDouble();
    final bucket150= (aging['150to180'] ?? aging['150-180'] ?? 0).toDouble();
    final bucket180= (aging['>180']     ?? aging['180+']    ?? 0).toDouble();

    String fmt(double v) => v == 0 ? '-' : '₹${v.toStringAsFixed(0)}';

    const headers = [
      'Limit', 'O/s Balance', 'Overdue',
      '0 to 7', '7 to 15', '15 to 30',
      '30 to 45', '45 to 90', '90 to 120',
      '120 to 150', '150 to 180', '>180',
    ];

    final values = [
      '₹${(limit / 1000).toStringAsFixed(0)}K',
      '₹${balance.toStringAsFixed(0)}',
      overdue == 0 ? '₹0' : '₹${overdue.toStringAsFixed(0)}',
      fmt(bucket0), fmt(bucket7), fmt(bucket15),
      fmt(bucket30), fmt(bucket45), fmt(bucket90),
      fmt(bucket120), fmt(bucket150), fmt(bucket180),
    ];

    final isOverdue = <bool>[
      false, false, overdue > 0,
      false, false, false, false, false, false, false, false, false,
    ];

    // Highlighted column indices (15-30 and 90-120 in image)
    final highlighted = {5, 9};

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            // Dark header
            Container(
              color: const Color(0xFF0D2137),
              child: Row(
                children: [
                  // Lightning bolt icon + label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: Color(0xFFFFAB40), size: 14),
                        const SizedBox(width: 6),
                        const Text(
                          'CREDIT EXPOSURE TABLE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Column headers row
            Container(
              color: const Color(0xFF1A3050),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: headers.asMap().entries.map((e) {
                    final isH = highlighted.contains(e.key);
                    return Container(
                      width: e.key < 3 ? 90 : 78,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.08))),
                        color: isH ? const Color(0xFF1ABFA1).withOpacity(0.15) : Colors.transparent,
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: e.key == 2 ? Colors.redAccent.shade100 : Colors.white70,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Data row
            Container(
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: values.asMap().entries.map((e) {
                    final isRed = isOverdue[e.key] && e.value != '-';
                    final isH = highlighted.contains(e.key);
                    return Container(
                      width: e.key < 3 ? 90 : 78,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: const Color(0xFFE2E8F0))),
                        color: isH ? const Color(0xFF1ABFA1).withOpacity(0.04) : Colors.white,
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isRed ? Colors.red : const Color(0xFF1E293B),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalRateDisplay(num total) {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text('₹${NumberFormat('#,##,###').format(total.toInt())}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
    final labels = ['PO COPY', 'PHOTO 2', 'PHOTO 3'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMiniSectionHeader('SALES PHOTOS (Max 3)', color: NexusTheme.emerald500),
        const SizedBox(height: 16),
        const Text('TAP SLOT TO UPLOAD — CAMERA OR GALLERY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: NexusTheme.slate400)),
        const SizedBox(height: 12),
        Row(
          children: List.generate(3, (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
              child: _buildPhotoSlot(i, labels[i]),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildPhotoSlot(int index, String label) {
    final file = _salesPhotos[index];
    final icons = [LucideIcons.fileText, LucideIcons.camera, LucideIcons.camera];
    return GestureDetector(
      onTap: () => _showPhotoPickerSheet(index),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: file != null ? NexusTheme.emerald500 : NexusTheme.slate200,
            width: file != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: file != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                  // Label badge
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                      child: Text(label, textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                  // Remove button
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _salesPhotos[index] = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: NexusTheme.emerald500.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icons[index], color: NexusTheme.emerald500, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: NexusTheme.slate400),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'TAP TO UPLOAD',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: NexusTheme.slate200),
                  ),
                ],
              ),
      ),
    );
  }

  // Bottom sheet for choosing Camera or Gallery
  void _showPhotoPickerSheet(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Text(
                'Upload ${["PO Copy", "Photo 2", "Photo 3"][index]}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: NexusTheme.indigo600,
                      onTap: () {
                        Navigator.pop(context);
                        _pickSalesPhoto(index, ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPickerOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: NexusTheme.emerald500,
                      onTap: () {
                        Navigator.pop(context);
                        _pickSalesPhoto(index, ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSalesPhoto(int index, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null && mounted) {
      setState(() => _salesPhotos[index] = File(picked.path));
    }
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: NexusTheme.slate200.withOpacity(0.5))),
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
                  const Text('AGGREGATE VALUE (INC. 18% GST)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('₹${NumberFormat('#,##,###').format(_cartTotal)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      const SizedBox(width: 12),
                      Text('(GST: ₹${NumberFormat('#,##,###').format(_gstTotal)})', style: const TextStyle(fontSize: 10, color: NexusTheme.slate400, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
                  onPressed: _isSubmitting ? null : _submitOrder,
                  icon: _isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(LucideIcons.fileText, size: 20),
                  label: Text(
                    _isSubmitting ? 'UPLOADING...' : 'COMMIT SUPPLY REQUEST',
                    style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13),
                  ),
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
