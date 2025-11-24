import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _visibleProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('products')
          .select('*')
          .order('id', ascending: true);
      final list = List<Map<String, dynamic>>.from(data);

      if (!mounted) return;
      setState(() {
        _allProducts = list;
        _visibleProducts = list;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _filterProducts(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _visibleProducts = _allProducts;
      } else {
        _visibleProducts = _allProducts.where((p) {
          final name = (p['name'] ?? '').toString().toLowerCase();
          final category = (p['category'] ?? '').toString().toLowerCase();
          return name.contains(q) || category.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Products',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadProducts,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Search Bar
        TextField(
          onChanged: _filterProducts,
          decoration: InputDecoration(
            hintText: 'Search by name or category...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Table
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_visibleProducts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'No products found.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              dataTextStyle: const TextStyle(color: Colors.white),
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Status')),
              ],
              rows: _visibleProducts.map((p) {
                return DataRow(
                  cells: [
                    DataCell(Text('${p['id'] ?? ''}')),
                    DataCell(Text(p['name'] ?? '')),
                    DataCell(Text(p['category'] ?? '')),
                    DataCell(Text('EGP ${p['price'] ?? 0}')),
                    DataCell(Text('${p['stock'] ?? 0}')),
                    DataCell(
                      Text(
                        (p['status'] ?? 'Inactive'),
                        style: TextStyle(
                          color: (p['status'] == 'Active')
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
