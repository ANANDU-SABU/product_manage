import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_form_screen.dart';
import 'product_view_screen.dart';
import 'signin_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService apiService = ApiService();

  List<Product> products = [];
  bool loading = true;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    loadUserEmail();
    loadProducts();
  }

  Future<void> loadUserEmail() async {
    final email = await apiService.getUserEmail();

    if (!mounted) return;

    setState(() {
      userEmail = email;
    });
  }

  Future<void> loadProducts() async {
    try {
      final response = await apiService.getProducts();

      if (!mounted) return;

      setState(() {
        products = (response.data as List)
            .map((item) => Product.fromJson(item))
            .toList();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await apiService.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete product')));
    }
  }

  Future<void> logout() async {
    await apiService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SigninScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stockroom', style: TextStyle(fontWeight: FontWeight.w800)),
            Text(
              'Product inventory',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? _EmptyState(onAdd: _openProductForm)
          : RefreshIndicator(
              onRefresh: loadProducts,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                children: [
                  Text(
                    'Welcome, ${userEmail ?? 'there'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF152B35),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Here is your inventory at a glance.',
                    style: TextStyle(color: Color(0xFF71848A)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${products.length} ${products.length == 1 ? 'item' : 'items'}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF152B35),
                            ),
                      ),
                      Text(
                        'Pull to refresh',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF71848A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...products.map(_productTile),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openProductForm,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add product'),
      ),
    );
  }

  Widget _productTile(Product product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductViewScreen(productId: product.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F2F4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF176B87),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF152B35),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${product.category}  |  Qty ${product.quantity}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF71848A)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF152B35),
                      ),
                    ),
                    IconButton(
                      onPressed: () => deleteProduct(product.id),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: const Color(0xFFB65F5F),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Delete product',
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

  Future<void> _openProductForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );

    if (mounted) {
      loadProducts();
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                size: 34,
                color: Color(0xFF176B87),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your inventory is empty',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF152B35),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first product to start tracking stock.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF71848A)),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add product'),
            ),
          ],
        ),
      ),
    );
  }
}
