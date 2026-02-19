import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
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
        'prevRate': 0.0,
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

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Deduplicated customers filtered by zone
  List<Customer> _filteredCustomers(List<Customer> all) {
    // Deduplicate by ID first (fixes assertion error)
    final seen = <String>{};
    final unique = all.where((c) => seen.add(c.id)).toList();

    if (_selectedZone == 'PAN INDIA') return unique;

    // Filter by location matching zone keyword
    return unique.where((c) {
      final loc = (c.location ?? c.city ?? '').toUpperCase();
      return loc.contains(_selectedZone);
    }).toList();
  }

  /// Users filtered by zone (non-admin)
  List<User> _zoneUsers(List<User> users) {
    return users.where((u) {
      if (u.role == UserRole.admin) return false;
      if (_selectedZone == 'PAN INDIA') return true;
      return u.zone.toUpperCase() == _selectedZone;
    }).toList();
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
            // ── ZONE SELECTION ──────────────────────────────────────────
            _buildSectionHeader('ZONE SELECTION'),
            const SizedBox(height: 12),
            _buildZoneChips(),
            const SizedBox(height: 20),

            // ── SALES HIERARCHY (Admin only) ─────────────────────────────
            if (isAdmin) ...[
              _buildSectionHeader('ASSIGN SALES TEAM'),
              const SizedBox(height: 12),
              _buildHierarchyPanel(provider.users, isMobile),
              const SizedBox(height: 20),
            ],

            // ── CUSTOMER SELECTION ───────────────────────────────────────
            _buildSectionHeader('CUSTOMER SELECTION'),
            const SizedBox(height: 16),
            _buildCustomerDropdown(filteredCustomers),
            const SizedBox(height: 32),

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
            customers.isEmpty
                ? 'No customers in $_selectedZone zone'
                : 'Search Organization Client Base...',
            style: const TextStyle(fontSize: 14, color: NexusTheme.slate400, fontWeight: FontWeight.bold),
          ),
          items: customers.map((Customer customer) => DropdownMenuItem<Customer>(
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
          value: customers.any((c) => c.id == selectedCustomer?.id) ? selectedCustomer : null,
          onChanged: customers.isEmpty ? null : (val) => setState(() => selectedCustomer = val),
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
          Expanded(flex: 1, child: Text('FINAL RATE', style: _tableHeaderStyle, textAlign: TextAlign.center)),
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
          Expanded(flex: 1, child: _buildFinalRateDisplay((item['price'] as num) * (item['quantity'] as num))),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.remove, color: Colors.white, size: 16),
            onPressed: () {
              if (qty > 1) setState(() => cartItems[index]['quantity'] = qty - 1);
            },
          ),
          SizedBox(
            width: 30,
            child: Text(qty.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            onPressed: () => setState(() => cartItems[index]['quantity'] = qty + 1),
          ),
        ],
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
            border: Border.all(color: NexusTheme.slate200, style: BorderStyle.solid),
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
