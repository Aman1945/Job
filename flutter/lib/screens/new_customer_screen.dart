import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../widgets/address_management_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewCustomerScreen extends StatefulWidget {
  const NewCustomerScreen({super.key});

  @override
  State<NewCustomerScreen> createState() => _NewCustomerScreenState();
}

class _NewCustomerScreenState extends State<NewCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _partnersController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstController = TextEditingController();
  final _fssaiController = TextEditingController();
  final _panController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _creditDaysController = TextEditingController();

  String _selectedConstitution = 'Proprietorship';
  String? _selectedManager;
  String? _selectedEmployee;
  String? _selectedState;
  
  // Multi-address support
  List<CustomerAddress> _deliveryAddresses = [];

  // Document photos
  File? _gstPhoto;
  File? _panPhoto;
  File? _chequePhoto;
  bool _isSubmitting = false;

  final _picker = ImagePicker();

  final List<String> _constitutions = ['Proprietorship', 'Partnership', 'Company'];
  final List<String> _states = ['Maharashtra', 'Karnataka', 'Delhi', 'Tamil Nadu', 'Gujarat'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 768;

    // Unified list for Managers and Employees
    final List<String> staffList = provider.users.map((u) => u.name).toList();
    if (staffList.isEmpty) staffList.add('Animesh Jamuar'); // Demo fallback

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('NEW CUSTOMER ONBOARDING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(isMobile),
              const SizedBox(height: 32),

              // Step 1: General Particulars
              _buildSectionHeader('STEP 1: GENERAL PARTICULARS'),
              const SizedBox(height: 24),
              
              _buildResponsiveLayout(isMobile, [
                _buildTextField('1. NAME OF CUSTOMER *', _nameController, required: true),
                _buildTextField('2. ADDRESS OF CUSTOMER *', _addressController, required: true),
              ]),

              _buildResponsiveLayout(isMobile, [
                _buildPremiumDropdown('3. CONSTITUTION', _selectedConstitution, _constitutions, (val) => setState(() => _selectedConstitution = val!)),
                _buildTextField('4. PARTNERS/DIRECTORS NAMES', _partnersController),
              ]),

              _buildResponsiveLayout(isMobile, [
                _buildTextField('5. TELEPHONE & MOBILE *', _phoneController, required: true),
                _buildTextField('6. EMAIL ID *', _emailController, required: true),
              ]),

              _buildResponsiveLayout(isMobile, [
                _buildTextField('7. GST NO *', _gstController, required: true),
                _buildTextField('8. FSSAI LICENSE NO', _fssaiController),
              ]),

              _buildResponsiveLayout(isMobile, [
                _buildTextField('9. PAN CARD *', _panController, required: true),
                _buildPremiumDropdown('10. REGION (STATE)', _selectedState ?? 'Select State...', _states, (val) => setState(() => _selectedState = val)),
              ]),

              _buildResponsiveLayout(isMobile, [
                _buildPremiumDropdown('12. SALES MANAGER', _selectedManager ?? 'Assign Manager...', staffList, (val) => setState(() => _selectedManager = val)),
                _buildPremiumDropdown('13. EMPLOYEE RESPONSIBLE', _selectedEmployee ?? 'Select Employee...', staffList, (val) => setState(() => _selectedEmployee = val)),
              ]),

              _buildResponsiveLayout(isMobile, [
                _buildReadOnlyField('15. SALE ORGANIZATION', '5200'),
                _buildReadOnlyField('17. DIVISION', '70'),
              ]),
              const SizedBox(height: 32),

              // Step 2: Credit Parameters
              _buildSectionHeader('STEP 2: CREDIT PARAMETERS'),
              const SizedBox(height: 24),
              _buildResponsiveLayout(isMobile, [
                _buildTextField('1. CREDIT DAYS (LIMIT) *', _creditDaysController, required: true),
                _buildTextField('2. CREDIT LIMIT (AMOUNT) *', _creditLimitController, required: true),
                _buildTextField('3. CUSTOMER TYPE', TextEditingController(text: 'Distributor')),
              ], triple: true),
              const SizedBox(height: 32),

              // Step 3: Delivery Addresses
              AddressManagementWidget(
                addresses: _deliveryAddresses,
                onAddressesChanged: (addresses) {
                  setState(() => _deliveryAddresses = addresses);
                },
              ),
              // Step 3: Document Repository
              const SizedBox(height: 32),
              _buildSectionHeader('STEP 3: DOCUMENT REPOSITORY'),
              const SizedBox(height: 24),
              _buildDocumentRepository(isMobile),
              const SizedBox(height: 48),

              // Footer Actions
              _buildResponsiveFooter(isMobile),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Customer Onboarding', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
                Text('Enterprise Client Registry Setup', style: TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: NexusTheme.emerald500, borderRadius: BorderRadius.circular(20)),
              child: const Icon(LucideIcons.userPlus, color: Colors.white, size: 32),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 24, decoration: BoxDecoration(color: NexusTheme.emerald500, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: 0.5))),
      ],
    );
  }

  Widget _buildResponsiveLayout(bool isMobile, List<Widget> children, {bool triple = false}) {
    if (isMobile) {
      return Column(
        children: children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 20), child: w)).toList(),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((w) => Expanded(child: Padding(padding: EdgeInsets.only(right: children.indexOf(w) == children.length - 1 ? 0 : 20), child: w))).toList(),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NexusTheme.slate200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NexusTheme.slate200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NexusTheme.emerald500, width: 2)),
          ),
          validator: required ? (val) => (val == null || val.isEmpty) ? 'Field required' : null : null,
        ),
      ],
    );
  }

  Widget _buildPremiumDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Text(value, style: const TextStyle(fontSize: 14, color: NexusTheme.slate800, fontWeight: FontWeight.bold)),
            items: items.map((String item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            )).toList(),
            value: items.contains(value) ? value : null,
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(
              height: 54,
              padding: const EdgeInsets.only(left: 14, right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NexusTheme.slate200),
                color: Colors.white,
              ),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(Icons.keyboard_arrow_down_rounded),
              iconSize: 24,
              iconEnabledColor: NexusTheme.slate400,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              offset: const Offset(0, -4),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: WidgetStateProperty.all(6),
                thumbVisibility: WidgetStateProperty.all(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 48,
              padding: EdgeInsets.only(left: 14, right: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
        ),
      ],
    );
  }

  Future<void> _pickDocPhoto(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;
    setState(() {
      final file = File(picked.path);
      if (index == 0) _gstPhoto = file;
      else if (index == 1) _panPhoto = file;
      else _chequePhoto = file;
    });
  }

  Widget _buildDocumentRepository(bool isMobile) {
    final labels = ['GST CERTIFICATE', 'PAN CARD COPY', 'SECURITY CHEQUE'];
    final icons = [
      Icons.description_outlined,
      Icons.credit_card_outlined,
      Icons.account_balance_outlined,
    ];
    final photos = [_gstPhoto, _panPhoto, _chequePhoto];

    Widget docSlot(int index) {
      final photo = photos[index];
      return GestureDetector(
        onTap: () => _pickDocPhoto(index),
        child: _DashedBox(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: photo != null
                  ? NexusTheme.emerald50
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                if (photo != null) ...([
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(photo, height: 80, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: NexusTheme.emerald500, size: 14),
                      SizedBox(width: 6),
                      Text('UPLOADED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.emerald600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Tap to change', style: TextStyle(fontSize: 9, color: NexusTheme.slate400)),
                ]) else ...[
                  const SizedBox(height: 8),
                  Icon(icons[index], size: 36, color: const Color(0xFFCDD5E0)),
                  const SizedBox(height: 12),
                  Text(
                    labels[index],
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF334155), letterSpacing: 0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text('Tap to upload', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (isMobile) {
      return Column(
        children: List.generate(3, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: docSlot(i),
        )),
      );
    }

    return Row(
      children: List.generate(3, (i) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: i < 2 ? 16 : 0),
          child: docSlot(i),
        ),
      )),
    );
  }

  Widget _buildResponsiveFooter(bool isMobile) {
    final buttons = [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: NexusTheme.emerald50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NexusTheme.emerald500.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.shieldCheck, color: NexusTheme.emerald600, size: 18),
            SizedBox(width: 10),
            Text('COMPLIANCE ACTIVE', style: TextStyle(color: NexusTheme.emerald700, fontWeight: FontWeight.w900, fontSize: 10)),
          ],
        ),
      ),
      const SizedBox(height: 16, width: 20),
      SizedBox(
        height: 54,
        width: isMobile ? double.infinity : null,
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _handleSubmit,
          icon: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(LucideIcons.database, size: 20),
          label: Text(
            _isSubmitting ? 'UPLOADING...' : 'COMMIT MASTER RECORD',
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            elevation: 10,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
        ),
      ),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buttons,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buttons[0],
        buttons[2],
      ],
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final provider = Provider.of<NexusProvider>(context, listen: false);

    // Upload documents to DO Spaces with organized folder structure
    String? gstUrl, panUrl, chequeUrl;
    final dateStr = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final safeCustomer = _nameController.text.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final docsFolder = 'Customers/$safeCustomer/Docs_$dateStr';
    if (_gstPhoto != null) gstUrl = await provider.uploadPhoto(_gstPhoto!, folder: docsFolder);
    if (_panPhoto != null) panUrl = await provider.uploadPhoto(_panPhoto!, folder: docsFolder);
    if (_chequePhoto != null) chequeUrl = await provider.uploadPhoto(_chequePhoto!, folder: docsFolder);

    final customerData = {
      'name': _nameController.text,
      'address': _addressController.text,
      'constitution': _selectedConstitution,
      'partners': _partnersController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'gst': _gstController.text,
      'fssai': _fssaiController.text,
      'pan': _panController.text,
      'region': _selectedState,
      'salesManager': _selectedManager,
      'employeeResponsible': _selectedEmployee,
      'limit': double.tryParse(_creditLimitController.text) ?? 0,
      'creditDays': _creditDaysController.text,
      'type': 'Distributor',
      'addresses': _deliveryAddresses.map((a) => a.toJson()).toList(),
      if (gstUrl != null) 'gstPhotoUrl': gstUrl,
      if (panUrl != null) 'panPhotoUrl': panUrl,
      if (chequeUrl != null) 'chequePhotoUrl': chequeUrl,
    };

    final success = await provider.createCustomer(customerData);
    if (mounted) setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Customer Onboarded Successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_deliveryAddresses.length} delivery address(es) added', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: NexusTheme.emerald600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

/// Draws a dashed rounded border around its child (matches the reference design).
class _DashedBox extends StatelessWidget {
  final Widget child;
  const _DashedBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const radius = Radius.circular(20);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );

    const dashWidth = 6.0;
    const dashSpace = 5.0;
    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        final start = metric.getTangentForOffset(dist)?.position;
        final end = metric.getTangentForOffset(dist + dashWidth)?.position;
        if (start != null && end != null) {
          canvas.drawLine(start, end, paint);
        }
        dist += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
