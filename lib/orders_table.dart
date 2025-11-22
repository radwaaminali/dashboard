import 'package:flutter/material.dart';

class OrdersTable extends StatefulWidget {
  const OrdersTable({super.key});

  @override
  OrdersTableState createState() => OrdersTableState();
}

class OrdersTableState extends State<OrdersTable> {
  final List<Map<String, String>> orders = [
    {
      'id': '#1234',
      'customer': 'Ali Hassan',
      'status': 'Delivered',
      'total': '\$150.00',
      'date': '2024-05-20',
    },
    {
      'id': '#1235',
      'customer': 'Fatima Ahmed',
      'status': 'Pending',
      'total': '\$200.50',
      'date': '2024-05-21',
    },
    {
      'id': '#1236',
      'customer': 'Khalid Mohammed',
      'status': 'Cancelled',
      'total': '\$50.00',
      'date': '2024-05-21',
    },
    {
      'id': '#1237',
      'customer': 'Sara Ibrahim',
      'status': 'Delivered',
      'total': '\$75.25',
      'date': '2024-05-22',
    },
  ];

  late List<Map<String, String>> filteredOrders;

  @override
  void initState() {
    super.initState();
    filteredOrders = orders;
  }

  void filterOrders(String searchText) {
    setState(() {
      filteredOrders = orders
          .where(
            (order) =>
                order['customer']!.toLowerCase().contains(
                  searchText.toLowerCase(),
                ) ||
                order['status']!.toLowerCase().contains(
                  searchText.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF34495E),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Orders',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: filterOrders,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search by Customer or Status...',
                hintStyle: TextStyle(color: Color(0xFFBDC3C7)),
                prefixIcon: Icon(Icons.search, color: Color(0xFFBDC3C7)),
                filled: true,
                fillColor: Color(0xFF2C3E50),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return buildMobileView();
                } else {
                  return buildDesktopView();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDesktopView() {
    return DataTable(
      columns: const [
        DataColumn(
          label: Text(
            'Order ID',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Customer',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Status',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Total',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Date',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: filteredOrders.map((order) {
        return DataRow(
          cells: [
            DataCell(
              Text(order['id']!, style: const TextStyle(color: Colors.white)),
            ),
            DataCell(
              Text(
                order['customer']!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            DataCell(buildStatusChip(order['status']!)),
            DataCell(
              Text(
                order['total']!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(order['date']!, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget buildMobileView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: const Color(0xFF2C3E50),
          child: ListTile(
            title: Text(
              order['customer']!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${order['id']} - ${order['date']}',
              style: const TextStyle(color: Color(0xFFBDC3C7)),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order['total']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                buildStatusChip(order['status']!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Delivered':
        color = const Color(0xFF2ECC71);
        break;
      case 'Pending':
        color = const Color(0xFFE67E22);
        break;
      case 'Cancelled':
        color = const Color(0xFFE74C3C);
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}
