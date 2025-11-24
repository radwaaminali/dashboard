import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  List<Map<String, dynamic>> _allCustomers = [];
  List<Map<String, dynamic>> _visibleCustomers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('customers')
          .select('*')
          .order('id', ascending: true);
      final list = List<Map<String, dynamic>>.from(data);

      if (!mounted) return;
      setState(() {
        _allCustomers = list;
        _visibleCustomers = list;
      });
    } catch (e) {
      debugPrint('Error loading customers: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _filterCustomers(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _visibleCustomers = _allCustomers;
      } else {
        _visibleCustomers = _allCustomers.where((c) {
          final name = (c['name'] ?? '').toString().toLowerCase();
          final email = (c['email'] ?? '').toString().toLowerCase();
          final status = (c['status'] ?? '').toString().toLowerCase();
          return name.contains(q) || email.contains(q) || status.contains(q);
        }).toList();
      }
    });
  }

  int get _activeCount =>
      _allCustomers.where((c) => (c['status'] ?? '') == 'Active').length;

  int get _inactiveCount =>
      _allCustomers.where((c) => (c['status'] ?? '') == 'Inactive').length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان + زرار ريفريش
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadCustomers,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // كروت إحصائيات بسيطة
        Row(
          children: [
            _statCard('Total', _allCustomers.length, Icons.people),
            const SizedBox(width: 12),
            _statCard('Active', _activeCount, Icons.check_circle),
            const SizedBox(width: 12),
            _statCard('Inactive', _inactiveCount, Icons.pause_circle),
          ],
        ),
        const SizedBox(height: 20),

        // سيرش
        TextField(
          onChanged: _filterCustomers,
          decoration: InputDecoration(
            hintText: 'Search by name, email or status',
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
        const SizedBox(height: 16),

        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_visibleCustomers.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'No customers found.',
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
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Status')),
              ],
              rows: _visibleCustomers.map((c) {
                return DataRow(
                  cells: [
                    DataCell(Text('${c['id'] ?? ''}')),
                    DataCell(Text(c['name'] ?? '')),
                    DataCell(Text(c['email'] ?? '')),
                    DataCell(Text(c['status'] ?? '')),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _statCard(String title, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF34495E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1ABC9C)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
