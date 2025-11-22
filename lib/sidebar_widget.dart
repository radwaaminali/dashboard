import 'package:flutter/material.dart';

class SidebarWidget extends StatelessWidget {
  final String selectedPage;
  final Function(String) onItemSelected;

  const SidebarWidget({
    super.key,
    required this.selectedPage,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: const Color(0xFF2C3E50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ العنوان العلوي
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            decoration: const BoxDecoration(color: Color(0xFF1ABC9C)),
            child: const Text(
              "Luna Store Admin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ✅ القوائم
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                buildMenuItem("Dashboard", Icons.dashboard),
                buildMenuItem("Orders", Icons.shopping_cart),
                buildMenuItem("Customers", Icons.people),
                buildMenuItem("Products", Icons.inventory),
                buildMenuItem("Settings", Icons.settings),
              ],
            ),
          ),

          const Divider(color: Colors.white24, height: 1),

          // ✅ زر تسجيل الخروج في الأسفل
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () => onItemSelected("Logout"),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem(String title, IconData icon) {
    final bool isActive = selectedPage == title;

    return InkWell(
      onTap: () => onItemSelected(title),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1ABC9C) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isActive) const Icon(Icons.arrow_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
