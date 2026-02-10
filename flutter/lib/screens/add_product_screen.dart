import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _skuCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _mrpController = TextEditingController();
  final _priceController = TextEditingController();
  final _baseRateController = TextEditingController();
  final _gstController = TextEditingController();
  final _hsnCodeController = TextEditingController();
  final _stockController = TextEditingController();
  final _barcodeController = TextEditingController();

  String _selectedChannel = 'RETAIL/HD';
  String _selectedSpecie = 'FISH';
  String _selectedPacking = 'PKTS';
  String _selectedCountry = 'INDIA';
  String _selectedCategory = 'Frozen Seafood';
  String _selectedUnit = 'PCS';

  final List<String> _channels = ['RETAIL/HD', 'WHOLESALE', 'HORECA'];
  final List<String> _species = ['FISH', 'PRAWNS', 'CHICKEN', 'MUTTON', 'SALMON', 'TUNA', 'SQUID', 'CRAB', 'LOBSTER'];
  final List<String> _packings = ['PKTS', 'CANS', 'BOXES', 'TRAYS'];
  final List<String> _countries = ['INDIA', 'JAPAN', 'NORWAY', 'THAILAND', 'CANADA', 'USA'];
  final List<String> _categories = ['Frozen Seafood', 'Frozen Poultry', 'Frozen Meat', 'Premium Seafood', 'Canned Seafood'];
  final List<String> _units = ['PCS', 'KG', 'BOXES'];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('ADD NEW PRODUCT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
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
              _buildHeaderCard(isMobile),
              const SizedBox(height: 32),

              _buildSectionHeader('PRODUCT IDENTIFICATION'),
              const SizedBox(height: 24),
              
              _buildResponsiveLayout(isMobile, [
                _buildTextField('SKU CODE *', _skuCodeController, required: true),
                _buildTextField('PRODUCT NAME *', _nameController, required: true),
              ]),

              _buildResponsiveLayout(isMobile, [
                _buildTextField('SHORT NAME', _shortNameController),
                _buildDropdown('DISTRIBUTION CHANNEL', _selectedChannel, _channels, (val) => setState(() => _selectedChannel = val!)),
              ]),

              const SizedBox(height: 32),
              _buildSectionHeader('PRODUCT SPECIFICATIONS'),
              const SizedBox(height: 24),

              _buildResponsiveLayout(isMobile, [
                _buildDropdown('SPECIE/TYPE', _selectedSpecie, _species, (val) => setState(() => _selectedSpecie = val!)),
                _buildTextField('WEIGHT (KG) *', _weightController, required: true, keyboardType: TextInputType.number),
              ]),

              _buildResponsiveLayout(isMobile, [
                _buildDropdown('PACKING TYPE', _selectedPacking, _packings, (val) => setState(() => _selectedPacking = val!)),
                _buildDropdown('UNIT', _selectedUnit, _units, (val) => setState(() => _selectedUnit = val!)),
              ]),

              const SizedBox(height: 32),
              _buildSectionHeader('PRICING & TAX'),
              const SizedBox(height: 24),

              _buildResponsiveLayout(isMobile, [
                _buildTextField('MRP *', _mrpController, required: true, keyboardType: TextInputType.number),
                _buildTextField('SELLING PRICE *', _priceController, required: true, keyboardType: TextInputType.number),
              ]),

              _buildResponsiveLayout(isMobile, [
                _buildTextField('BASE RATE *', _baseRateController, required: true, keyboardType: TextInputType.number),
                _buildTextField('GST % *', _gstController, required: true, keyboardType: TextInputType.number),
              ]),

              const SizedBox(height: 32),
              _buildSectionHeader('ADDITIONAL DETAILS'),
              const SizedBox(height: 24),

              _buildResponsiveLayout(isMobile, [
                _buildTextField('HSN CODE', _hsnCodeController),
                _buildDropdown('COUNTRY OF ORIGIN', _selectedCountry, _countries, (val) => setState(() => _selectedCountry = val!)),
              ]),

              _buildResponsiveLayout(isMobile, [
                _buildDropdown('CATEGORY', _selectedCategory, _categories, (val) => setState(() => _selectedCategory = val!)),
                _buildTextField('INITIAL STOCK *', _stockController, required: true, keyboardType: TextInputType.number),
              ]),

              _buildResponsiveLayout(isMobile, [
                _buildTextField('BARCODE', _barcodeController),
              ]),

              const SizedBox(height: 48),
              _buildFooter(isMobile),
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
                const Text('Add New Product', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
                Text('SKU Master Data Entry', style: TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: NexusTheme.indigo600, borderRadius: BorderRadius.circular(20)),
              child: const Icon(LucideIcons.package, color: Colors.white, size: 32),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 24, decoration: BoxDecoration(color: NexusTheme.indigo600, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: 0.5))),
      ],
    );
  }

  Widget _buildResponsiveLayout(bool isMobile, List<Widget> children) {
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

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NexusTheme.slate200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NexusTheme.slate200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NexusTheme.indigo600, width: 2)),
          ),
          validator: required ? (val) => (val == null || val.isEmpty) ? 'Required' : null : null,
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
            dropdownStyleData: DropdownStyleData(
              maxHeight: 250,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
              offset: const Offset(0, -4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isMobile) {
    return SizedBox(
      height: 54,
      width: isMobile ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: _handleSubmit,
        icon: const Icon(LucideIcons.database, size: 20),
        label: const Text('SAVE PRODUCT TO DATABASE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: NexusTheme.indigo600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<NexusProvider>(context, listen: false);
    
    final productData = {
      'skuCode': _skuCodeController.text,
      'name': _nameController.text,
      'productShortName': _shortNameController.text.isEmpty ? _nameController.text : _shortNameController.text,
      'distributionChannel': _selectedChannel,
      'specie': _selectedSpecie,
      'productWeight': _weightController.text,
      'productPacking': _selectedPacking,
      'mrp': double.tryParse(_mrpController.text) ?? 0,
      'price': double.tryParse(_priceController.text) ?? 0,
      'baseRate': double.tryParse(_baseRateController.text) ?? 0,
      'gst': int.tryParse(_gstController.text) ?? 0,
      'hsnCode': _hsnCodeController.text,
      'countryOfOrigin': _selectedCountry,
      'category': _selectedCategory,
      'unit': _selectedUnit,
      'stock': int.tryParse(_stockController.text) ?? 0,
      'barcode': _barcodeController.text,
    };

    final success = await provider.createProduct(productData);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Added Successfully!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add product')),
      );
    }
  }
}
