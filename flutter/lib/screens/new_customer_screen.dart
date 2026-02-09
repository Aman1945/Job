import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
  String? _selectedState;

  final List<String> _constitutions = ['Proprietorship', 'Partnership', 'Company'];
  final List<String> _states = ['Maharashtra', 'Karnataka', 'Delhi', 'Tamil Nadu', 'Gujarat'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('NEW CUSTOMER ONBOARDING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(),
              const SizedBox(height: 32),

              // Step 1: General Particulars
              _buildSectionHeader('STEP 1: GENERAL PARTICULARS'),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(child: _buildTextField('1. NAME OF CUSTOMER *', _nameController, required: true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildTextField('2. ADDRESS OF CUSTOMER *', _addressController, required: true)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildDropdown('3. CONSTITUTION', _selectedConstitution, _constitutions, (val) => setState(() => _selectedConstitution = val!))),
                  const SizedBox(width: 20),
                  Expanded(child: _buildTextField('4. PARTNERS/DIRECTORS NAMES', _partnersController)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildTextField('5. TELEPHONE & MOBILE *', _phoneController, required: true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildTextField('6. EMAIL ID *', _emailController, required: true)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildTextField('7. GST NO *', _gstController, required: true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildTextField('8. FSSAI LICENSE NO', _fssaiController)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildTextField('9. PAN CARD *', _panController, required: true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDropdown('10. REGION (STATE)', _selectedState ?? 'Select State...', _states, (val) => setState(() => _selectedState = val))),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildDropdown('12. SALES MANAGER', _selectedManager ?? 'Assign Manager...', provider.users.where((u) => u.role.label == 'Sales').map((u) => u.name).toList(), (val) => setState(() => _selectedManager = val))),
                  const SizedBox(width: 20),
                  Expanded(child: _buildReadOnlyField('13. EMPLOYEE RESPONSIBLE', provider.currentUser?.name ?? '')),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildReadOnlyField('15. SALE ORGANIZATION', '5200')),
                  const SizedBox(width: 20),
                  Expanded(child: _buildReadOnlyField('17. DIVISION', '70')),
                ],
              ),
              const SizedBox(height: 32),

              // Step 2: Credit Parameters
              _buildSectionHeader('STEP 2: CREDIT PARAMETERS'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildTextField('1. CREDIT DAYS (LIMIT) *', _creditDaysController, required: true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildTextField('2. CREDIT LIMIT (AMOUNT) *', _creditLimitController, required: true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildTextField('3. CUSTOMER TYPE', TextEditingController(text: 'Distributor'))),
                ],
              ),
              const SizedBox(height: 48),

              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: NexusTheme.emerald50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: NexusTheme.emerald500.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.shieldCheck, color: NexusTheme.emerald600, size: 18),
                        const SizedBox(width: 10),
                        Text('COMPLIANCE CHECK: Verification protocol active', style: TextStyle(color: NexusTheme.emerald700, fontWeight: FontWeight.w900, fontSize: 10)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _handleSubmit,
                      icon: const Icon(LucideIcons.database, size: 20),
                      label: const Text('COMMIT MASTER RECORD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        elevation: 10,
                        shadowColor: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Customer Onboarding', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
              Text('Enterprise Client Registry Setup (End-to-End Workflow)', style: TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
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
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: 0.5)),
      ],
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
          validator: required ? (val) => val!.isEmpty ? 'Field required' : null : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NexusTheme.slate200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: items.contains(value) ? value : null,
              hint: Text(value, style: const TextStyle(fontSize: 14)),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: onChanged,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<NexusProvider>(context, listen: false);
    
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
      'limit': double.tryParse(_creditLimitController.text) ?? 0,
      'creditDays': _creditDaysController.text,
      'type': 'Distributor',
    };

    final success = await provider.createCustomer(customerData);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Onboarded Successfully!')));
    }
  }
}
