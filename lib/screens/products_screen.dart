import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/sio_bottom_nav.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final searchCtrl = TextEditingController();

  bool showLowStockOnly = false;
  static const int lowStockLimit = 10;

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    final query = searchCtrl.text.trim().toLowerCase();

    return products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(query) ||
          product.barcode.toLowerCase().contains(query);

      final matchesStock =
          !showLowStockOnly || product.currentStock <= lowStockLimit;

      return matchesSearch && matchesStock;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  int _totalStock(List<Product> products) {
    return products.fold<int>(
      0,
      (total, product) => total + product.currentStock,
    );
  }

  int _lowStockCount(List<Product> products) {
    return products
        .where((product) => product.currentStock <= lowStockLimit)
        .length;
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(List<Product> products) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF16396E),
            Color(0xFF071827),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventario de productos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Control visual del stock actual, productos críticos y códigos registrados.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _summaryCard(
                icon: Icons.inventory_2_rounded,
                value: '${products.length}',
                label: 'Productos',
                color: const Color(0xFF16A085),
              ),
              const SizedBox(width: 10),
              _summaryCard(
                icon: Icons.warehouse_rounded,
                value: '${_totalStock(products)}',
                label: 'Stock total',
                color: const Color(0xFF4F7BFF),
              ),
              const SizedBox(width: 10),
              _summaryCard(
                icon: Icons.warning_amber_rounded,
                value: '${_lowStockCount(products)}',
                label: 'Stock bajo',
                color: const Color(0xFFFF5C70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchAndFilters() {
    return Column(
      children: [
        TextField(
          controller: searchCtrl,
          style: const TextStyle(color: Colors.white),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o código',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchCtrl.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      searchCtrl.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: const Color(0xFF111827),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _filterChip(
              label: 'Todos',
              selected: !showLowStockOnly,
              color: const Color(0xFF16A085),
              onTap: () {
                setState(() => showLowStockOnly = false);
              },
            ),
            const SizedBox(width: 10),
            _filterChip(
              label: 'Stock bajo',
              selected: showLowStockOnly,
              color: const Color(0xFFFF5C70),
              onTap: () {
                setState(() => showLowStockOnly = true);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color.withOpacity(0.5) : Colors.white10,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : Colors.white54,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: Colors.white38,
            size: 50,
          ),
          SizedBox(height: 12),
          Text(
            'No hay productos para mostrar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Probá cambiar el filtro o cargar productos desde Recepción.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Product product) {
    final isLowStock = product.currentStock <= lowStockLimit;
    final color =
        isLowStock ? const Color(0xFFFF5C70) : const Color(0xFF16A085);

    return InkWell(
      onTap: () {
        _showProductDetail(product);
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isLowStock ? color.withOpacity(0.45) : Colors.white10,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isLowStock
                    ? Icons.warning_amber_rounded
                    : Icons.inventory_2_rounded,
                color: color,
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
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Código: ${product.barcode}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Caja/paquete: ${product.conversionFactor} unidades',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12.5,
                    ),
                  ),
                  if (isLowStock) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Stock crítico',
                        style: TextStyle(
                          color: Color(0xFFFF5C70),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${product.currentStock}',
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'unidades',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                IconButton(
                  onPressed: () {
                    _confirmDelete(
                      context,
                      product.barcode,
                      product.name,
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetail(Product product) {
    final isLowStock = product.currentStock <= lowStockLimit;
    final color =
        isLowStock ? const Color(0xFFFF5C70) : const Color(0xFF16A085);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 22),
              Icon(
                isLowStock
                    ? Icons.warning_amber_rounded
                    : Icons.inventory_2_rounded,
                color: color,
                size: 46,
              ),
              const SizedBox(height: 14),
              Text(
                product.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              _detailRow('Código', product.barcode),
              _detailRow(
                'Stock actual',
                '${product.currentStock} unidades',
              ),
              _detailRow(
                'Unidades por caja/paquete',
                '${product.conversionFactor}',
              ),
              _detailRow(
                'Estado',
                isLowStock ? 'Stock bajo' : 'Stock normal',
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(
                      context,
                      product.barcode,
                      product.name,
                    );
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Eliminar producto'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF071827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String barcode,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF121E2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Eliminar producto',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Querés eliminar "$name"?\n\nEsta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await ref.read(productProvider.notifier).deleteProduct(barcode);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF071827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Productos'),
      ),
      bottomNavigationBar: const SioBottomNav(
        currentRoute: AppRouter.products,
      ),
      body: productsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => const Center(
          child: Text(
            'No se pudieron cargar los productos',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        data: (products) {
          final filteredProducts = _filterProducts(products);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _header(products),
                const SizedBox(height: 18),
                _searchAndFilters(),
                const SizedBox(height: 18),
                if (filteredProducts.isEmpty)
                  _emptyState()
                else
                  ...filteredProducts.map(_productCard),
              ],
            ),
          );
        },
      ),
    );
  }
}