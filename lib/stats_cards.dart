import 'package:flutter/material.dart';

class StatsCards extends StatelessWidget {
  final Function(String) onCardSelected; // 🔹 Callback للتفاعل

  const StatsCards({super.key, required this.onCardSelected});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stats = [
      {
        'title': "Today's Sales",
        'value': '\$1,250',
        'icon': Icons.monetization_on,
      },
      {'title': "New Orders", 'value': '12', 'icon': Icons.shopping_cart},
      {'title': "New Customers", 'value': '5', 'icon': Icons.person_add},
      {'title': "Out of Stock", 'value': '3', 'icon': Icons.warning},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 1100) crossAxisCount = 2;
        if (constraints.maxWidth < 600) crossAxisCount = 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth < 600 ? 3 : 1.5,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final item = stats[index];
            return InkWell(
              onTap: () => onCardSelected(item['title']),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: const Color(0xFF34495E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.transparent, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'],
                        size: 40,
                        color: const Color(0xFF1ABC9C),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['title'],
                        style: const TextStyle(color: Color(0xFFBDC3C7)),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['value'],
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
