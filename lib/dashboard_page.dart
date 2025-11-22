import 'package:flutter/material.dart';
import 'package:myapp/sidebar_widget.dart';
import 'package:myapp/topbar_widget.dart';
import 'package:myapp/stats_cards.dart';
import 'package:myapp/sales_chart.dart';
import 'package:myapp/orders_table.dart';
import 'package:myapp/orders_page.dart';
import 'package:myapp/customers_page.dart'; // ✅ تم إضافة صفحة العملاء الجديدة

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  String selectedPage = "Dashboard";
  String selectedMetric = "Today's Sales";

  void changePage(String page) {
    setState(() => selectedPage = page);
  }

  void updateMetric(String metric) {
    setState(() => selectedMetric = metric);
  }

  Widget getCurrentPage() {
    switch (selectedPage) {
      case "Dashboard":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatsCards(onCardSelected: updateMetric),
            const SizedBox(height: 20),
            SalesChart(metric: selectedMetric),
            const SizedBox(height: 20),
            OrdersTable(),
          ],
        );

      case "Orders":
        return const OrdersPage(); // ✅ صفحة الأوردرات

      case "Customers":
        return const CustomersPage(); // ✅ صفحة العملاء متصلة فعليًا

      default:
        return Center(
          child: Text(
            "$selectedPage Page (Coming Soon)",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Row(
        children: [
          SidebarWidget(selectedPage: selectedPage, onItemSelected: changePage),
          Expanded(
            child: Column(
              children: [
                TopBarWidget(currentPage: selectedPage),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: getCurrentPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
