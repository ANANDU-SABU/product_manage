import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_form_screen.dart';

class ProductViewScreen extends StatefulWidget {
  final String productId;

  const ProductViewScreen({super.key, required this.productId});

  @override
  State<ProductViewScreen> createState() => _ProductViewScreenState();
}

class _ProductViewScreenState extends State<ProductViewScreen> {
  final ApiService apiService = ApiService();

  Product? product;
  bool loading = true;
  bool deleting = false;

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  Future<void> loadProduct() async {
    try {
      final response = await apiService.getProduct(widget.productId);

      if (!mounted) return;

      setState(() {
        product = Product.fromJson(response.data);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> editProduct() async {
    final currentProduct = product;
    if (currentProduct == null) return;

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: currentProduct),
      ),
    );

    if (updated == true && mounted) {
      setState(() {
        loading = true;
      });
      await loadProduct();
    }
  }

  Future<void> deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      deleting = true;
    });

    try {
      await apiService.deleteProduct(widget.productId);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        deleting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: deleting ? null : editProduct,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit product',
          ),
          IconButton(
            onPressed: deleting ? null : deleteProduct,
            icon: deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete product',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : product == null
          ? const Center(child: Text('Product not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F2F4),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 36,
                          color: Color(0xFF176B87),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        product!.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF152B35),
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product!.category,
                        style: const TextStyle(color: Color(0xFF71848A)),
                      ),
                      const SizedBox(height: 26),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _DetailRow(
                                icon: Icons.inventory_outlined,
                                label: 'Quantity in stock',
                                value: '${product!.quantity}',
                              ),
                              const Divider(height: 28),
                              _DetailRow(
                                icon: Icons.payments_outlined,
                                label: 'Unit price',
                                value: '₹${product!.price.toStringAsFixed(2)}',
                              ),
                            ],
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
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF176B87)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF71848A))),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF152B35),
          ),
        ),
      ],
    );
  }
}
