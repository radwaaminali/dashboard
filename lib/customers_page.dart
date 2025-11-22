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
  List<Map<String, dynamic>> customers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  /// ✅ تحميل بيانات العملاء من Supabase
  Future<void> _fetchCustomers() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('customers')
          .select('id, name, email, status');

      debugPrint("📦 Customers fetched: ${response.length}");
      debugPrint("🔹 Sample: ${response.isNotEmpty ? response[0] : 'Empty'}");

      setState(() {
        customers = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (error) {
      debugPrint('❌ Error fetching customers: $error');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: const Color(0xFF1ABC9C),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCustomers,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : customers.isEmpty
          ? const Center(
              child: Text(
                "No customers found.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final c = customers[index];
                return Card(
                  color: const Color(0xFF34495E),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1ABC9C),
                      child: Text(
                        c['id'].toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      c['name'] ?? 'N/A',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      c['email'] ?? 'N/A',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      c['status'] ?? 'Unknown',
                      style: TextStyle(
                        color: (c['status'] == 'Active')
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
