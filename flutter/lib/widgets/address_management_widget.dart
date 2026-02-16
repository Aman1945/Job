import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class AddressManagementWidget extends StatefulWidget {
  final List<CustomerAddress> addresses;
  final Function(List<CustomerAddress>) onAddressesChanged;

  const AddressManagementWidget({
    super.key,
    required this.addresses,
    required this.onAddressesChanged,
  });

  @override
  State<AddressManagementWidget> createState() => _AddressManagementWidgetState();
}

class _AddressManagementWidgetState extends State<AddressManagementWidget> {
  late List<CustomerAddress> _addresses;

  @override
  void initState() {
    super.initState();
    _addresses = List.from(widget.addresses);
  }

  void _addNewAddress() {
    showDialog(
      context: context,
      builder: (context) => _AddressDialog(
        onSave: (address) {
          setState(() {
            _addresses.add(address);
            widget.onAddressesChanged(_addresses);
          });
        },
      ),
    );
  }

  void _editAddress(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddressDialog(
        address: _addresses[index],
        onSave: (address) {
          setState(() {
            _addresses[index] = address;
            widget.onAddressesChanged(_addresses);
          });
        },
      ),
    );
  }

  void _deleteAddress(int index) {
    setState(() {
      _addresses.removeAt(index);
      widget.onAddressesChanged(_addresses);
    });
  }

  void _setDefaultAddress(int index) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = CustomerAddress(
          id: _addresses[i].id,
          label: _addresses[i].label,
          street: _addresses[i].street,
          city: _addresses[i].city,
          state: _addresses[i].state,
          pincode: _addresses[i].pincode,
          type: _addresses[i].type,
          isDefault: i == index,
        );
      }
      widget.onAddressesChanged(_addresses);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 400;
            return isNarrow 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderTitle(),
                    const SizedBox(height: 8),
                    _buildAddButton(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderTitle(),
                    _buildAddButton(),
                  ],
                );
          },
        ),
        const SizedBox(height: 16),
        if (_addresses.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: NexusTheme.slate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NexusTheme.slate200, style: BorderStyle.solid),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.location_off, size: 48, color: NexusTheme.slate300),
                  SizedBox(height: 12),
                  Text(
                    'No delivery addresses added',
                    style: TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = _addresses[index];
              return _buildAddressCard(address, index);
            },
          ),
      ],
    );
  }

  Widget _buildHeaderTitle() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: NexusTheme.emerald500,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'DELIVERY ADDRESSES',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return TextButton.icon(
      onPressed: _addNewAddress,
      icon: const Icon(Icons.add_location_alt, size: 18),
      label: const Text('ADD ADDRESS'),
      style: TextButton.styleFrom(
        foregroundColor: NexusTheme.emerald600,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildAddressCard(CustomerAddress address, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault ? NexusTheme.emerald500 : NexusTheme.slate200,
          width: address.isDefault ? 2 : 1,
        ),
        boxShadow: address.isDefault
            ? [BoxShadow(color: NexusTheme.emerald500.withOpacity(0.1), blurRadius: 10)]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: address.type == 'Billing'
                            ? NexusTheme.indigo50
                            : NexusTheme.emerald50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        address.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: address.type == 'Billing'
                              ? NexusTheme.indigo600
                              : NexusTheme.emerald600,
                        ),
                      ),
                    ),
                    if (address.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: NexusTheme.amber50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 12, color: NexusTheme.amber600),
                            SizedBox(width: 4),
                            Text(
                              'DEFAULT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: NexusTheme.amber600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 20),
                itemBuilder: (context) => [
                  if (!address.isDefault)
                    PopupMenuItem(
                      onTap: () => _setDefaultAddress(index),
                      child: const Row(
                        children: [
                          Icon(Icons.star, size: 16),
                          SizedBox(width: 8),
                          Text('Set as Default'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    onTap: () => _editAddress(index),
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () => _deleteAddress(index),
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            address.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: NexusTheme.slate900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            address.street,
            style: const TextStyle(fontSize: 13, color: NexusTheme.slate600),
          ),
          const SizedBox(height: 4),
          Text(
            '${address.city}, ${address.state} - ${address.pincode}',
            style: const TextStyle(fontSize: 13, color: NexusTheme.slate600),
          ),
        ],
      ),
    );
  }
}

class _AddressDialog extends StatefulWidget {
  final CustomerAddress? address;
  final Function(CustomerAddress) onSave;

  const _AddressDialog({this.address, required this.onSave});

  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  String _selectedType = 'Delivery';

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?.label ?? '');
    _streetController = TextEditingController(text: widget.address?.street ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _pincodeController = TextEditingController(text: widget.address?.pincode ?? '');
    _selectedType = widget.address?.type ?? 'Delivery';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: NexusTheme.emerald600),
                    const SizedBox(width: 12),
                    Text(
                      widget.address == null ? 'Add New Address' : 'Edit Address',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField('Address Label', _labelController, 'e.g., Main Office'),
                const SizedBox(height: 16),
                _buildTextField('Street Address', _streetController, 'Enter street address'),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 300) {
                      return Column(
                        children: [
                          _buildTextField('City', _cityController, 'City'),
                          const SizedBox(height: 16),
                          _buildTextField('State', _stateController, 'State'),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: _buildTextField('City', _cityController, 'City')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('State', _stateController, 'State')),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField('Pincode', _pincodeController, '000000'),
                const SizedBox(height: 16),
                const Text(
                  'ADDRESS TYPE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: NexusTheme.slate400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Delivery'),
                        value: 'Delivery',
                        groupValue: _selectedType,
                        onChanged: (val) => setState(() => _selectedType = val!),
                        activeColor: NexusTheme.emerald600,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Billing'),
                        value: 'Billing',
                        groupValue: _selectedType,
                        onChanged: (val) => setState(() => _selectedType = val!),
                        activeColor: NexusTheme.indigo600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NexusTheme.emerald600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('SAVE ADDRESS'),
                    ),
                  ],
                ),
              ],
            ),
          ), 
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: NexusTheme.slate400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: NexusTheme.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: NexusTheme.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: NexusTheme.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: NexusTheme.emerald500, width: 2),
            ),
          ),
          validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final address = CustomerAddress(
      id: widget.address?.id ?? 'ADDR-${DateTime.now().millisecondsSinceEpoch}',
      label: _labelController.text,
      street: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      pincode: _pincodeController.text,
      type: _selectedType,
      isDefault: widget.address?.isDefault ?? false,
    );

    widget.onSave(address);
    Navigator.pop(context);
  }
}
