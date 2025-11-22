import 'package:flutter/material.dart';

class SalesChart extends StatelessWidget {
  final String metric; // ✅ تعريف الباراميتر المفقود

  const SalesChart({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    List<int> data = [];
    String label = '';

    // 🔹 اختيار نوع البيانات حسب الكارت المختار
    switch (metric) {
      case "Today's Sales":
        data = [10, 20, 30, 40, 50];
        label = "Today's Sales Trend";
        break;
      case "New Orders":
        data = [5, 15, 25, 20, 30];
        label = "Orders Overview";
        break;
      case "New Customers":
        data = [2, 4, 6, 8, 10];
        label = "New Customers Growth";
        break;
      case "Out of Stock":
        data = [1, 3, 2, 5, 4];
        label = "Stock Status";
        break;
      default:
        data = [10, 10, 10, 10, 10];
        label = "Sales Overview";
    }

    return Card(
      color: const Color(0xFF34495E),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: data.map((value) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 20,
                    height: value * 3.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1ABC9C),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
