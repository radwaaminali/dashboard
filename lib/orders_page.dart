import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  String? errorMessage;
  List<Order> allOrders = [];
  List<Order> filteredOrders = [];
  String searchQuery = "";
  String selectedStatus = "All";

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await supabase
          .from('orders')
          .select('*')
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);
      allOrders = data.map(Order.fromMap).toList();
      filteredOrders = allOrders;
    } catch (e) {
      errorMessage = 'Failed to load orders: $e';
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _updateFilteredOrders() {
    setState(() {
      filteredOrders = allOrders.where((order) {
        bool matchesSearch =
            order.customerName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            order.id.toString().contains(searchQuery);
        bool matchesStatus =
            selectedStatus == "All" || order.status == selectedStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _updateOrderStatus(Order order) async {
    String newStatus;
    switch (order.status) {
      case 'Pending':
        newStatus = 'Shipped';
        break;
      case 'Shipped':
        newStatus = 'Delivered';
        break;
      default:
        newStatus = order.status;
    }

    try {
      await supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', order.id);
      _loadOrders();
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  Future<void> _generatePDF(Order order) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Invoice #${order.id}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Customer: ${order.customerName}',
                  style: pw.TextStyle(font: font, fontSize: 16),
                ),
                pw.Text(
                  'Status: ${order.status}',
                  style: pw.TextStyle(font: font, fontSize: 14),
                ),
                pw.Text(
                  'Total: \$${order.total.toStringAsFixed(2)}',
                  style: pw.TextStyle(font: font, fontSize: 14),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Text(
                  'Thank you for your order!',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 14,
                    color: PdfColors.blueGrey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${order.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  void _showOrderDetailsDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF34495E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Order #${order.id}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Customer', order.customerName),
              _detailRow('Total', '\$${order.total.toStringAsFixed(2)}'),
              _detailRow('Status', order.status),
              _detailRow(
                'Date',
                order.createdAt.toLocal().toString().split(' ').first,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _generatePDF(order),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text('Download Invoice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateOrderStatus(order);
                    },
                    icon: const Icon(Icons.update, color: Colors.white),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            )
          : errorMessage != null
          ? Center(
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // بحث + فلترة حسب الحالة
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            _updateFilteredOrders();
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Search by ID or Customer...',
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF2C3E50),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                          _updateFilteredOrders();
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'Shipped',
                          child: Text('Shipped'),
                        ),
                        DropdownMenuItem(
                          value: 'Delivered',
                          child: Text('Delivered'),
                        ),
                        DropdownMenuItem(
                          value: 'Cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      dropdownColor: const Color(0xFF2C3E50),
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // عرض الطلبات
                if (filteredOrders.isEmpty)
                  const Text(
                    'No orders found.',
                    style: TextStyle(color: Colors.white70),
                  )
                else
                  _buildOrdersTable(),
              ],
            ),
    );
  }

  Widget _buildOrdersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.resolveWith(
          (_) => const Color(0xFF2C3E50),
        ),
        columns: const [
          DataColumn(
            label: Text(
              'Order ID',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Customer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Total',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Date',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        rows: filteredOrders.map((order) {
          return DataRow(
            onSelectChanged: (_) => _showOrderDetailsDialog(order),
            cells: [
              DataCell(
                Text(
                  '#${order.id}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  order.customerName,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(_buildStatusChip(order.status)),
              DataCell(
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  order.createdAt.toLocal().toString().split(' ').first,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Pending':
        color = const Color(0xFFE67E22);
        break;
      case 'Shipped':
        color = const Color(0xFF3498DB);
        break;
      case 'Delivered':
        color = const Color(0xFF2ECC71);
        break;
      case 'Cancelled':
        color = const Color(0xFFE74C3C);
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class Order {
  final int id;
  final String customerName;
  final double total;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerName,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int,
      customerName: (map['customer_name'] ?? 'Unknown') as String,
      total: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: (map['status'] ?? 'Pending') as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
