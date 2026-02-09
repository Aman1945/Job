import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class BookOrderScreen extends StatefulWidget {
  const BookOrderScreen({super.key});

  @override
  State<BookOrderScreen> createState() => _BookOrderScreenState();
}

class _BookOrderScreenState extends State<BookOrderScreen> {
  Customer? selectedCustomer;
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NexusProvider>(context, listen: false);
      provider.fetchProducts();
      provider.fetchCustomers();
    });
  }

  void _addToCart(Product product) {
    setState(() {
      final index = cartItems.indexWhere((item) => item['productId'] == product.id);
      if (index == -1) {
        cartItems.add({
          'productId': product.id,
          'productName': product.name,
          'skuCode': product.skuCode,
          'quantity': 1,
          'price': product.price,
        });
      } else {
        cartItems[index]['quantity']++;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${product.name} to cart')),
    );
  }

  double get _cartTotal {
    return cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void _submitOrder() async {
    if (selectedCustomer == null || cartItems.isEmpty) return;
    
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final success = await provider.createOrder(
      selectedCustomer!.id,
      selectedCustomer!.name,
      cartItems,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order Created Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('CREATE NEW MISSION')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SELECT CUSTOMER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: NexusTheme.slate400)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NexusTheme.slate200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Customer>(
                  isExpanded: true,
                  hint: const Text('Select a Customer'),
                  value: selectedCustomer,
                  items: provider.customers.map((Customer customer) {
                    return DropdownMenuItem<Customer>(value: customer, child: Text(customer.name));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedCustomer = val),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (cartItems.isNotEmpty) ...[
               Text('CART TOTAL: ₹$_cartTotal', style: const TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.emerald900)),
               const SizedBox(height: 8),
            ],
            const Text('AVAILABLE INVENTORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: NexusTheme.slate400)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: provider.products.length,
                itemBuilder: (context, index) {
                  final product = provider.products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('SKU: ${product.skuCode} | Stock: ${product.stock}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('₹${product.price}', style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.emerald900)),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: NexusTheme.emerald500),
                            onPressed: () => _addToCart(product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (selectedCustomer == null || cartItems.isEmpty) ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusTheme.emerald900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('INITIALIZE MISSION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class OrderItem {
  final Product product;
  int quantity;
  OrderItem({required this.product, this.quantity = 1});
}
