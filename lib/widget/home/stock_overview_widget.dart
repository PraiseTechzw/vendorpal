import 'package:flutter/material.dart';

class StockOverview extends StatelessWidget {
  final PageController stockPageController;
  final int totalStock;
  final int lowStockItemsCount;
  final int lastMonthStock;
  final int currentMonthStock;
  final int yearToDateStock;

  const StockOverview({
    required this.stockPageController,
    required this.totalStock,
    required this.lowStockItemsCount,
    required this.lastMonthStock,
    required this.currentMonthStock,
    required this.yearToDateStock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stock Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240, // Increased height for more space
          child: PageView(
            controller: stockPageController,
            children: [
              _buildOverviewCard(
                icon: Icons.inventory,
                title: 'Total Stock',
                subtitle: 'Items in Inventory',
                value: '$totalStock',
                gradientColors: [Colors.blueAccent, Colors.cyan],
              ),
              _buildOverviewCard(
                icon: Icons.warning,
                title: 'Low Stock Items',
                subtitle: 'Below Threshold',
                value: '$lowStockItemsCount',
                gradientColors: [Colors.redAccent, Colors.orange],
              ),
              _buildOverviewCard(
                icon: Icons.trending_up,
                title: 'Last Month Stock',
                subtitle: 'Stock Level',
                value: '$lastMonthStock',
                gradientColors: [Colors.greenAccent, Colors.teal],
              ),
              _buildOverviewCard(
                icon: Icons.timeline,
                title: 'Current Month Stock',
                subtitle: 'Stock Level',
                value: '$currentMonthStock',
                gradientColors: [Colors.orangeAccent, Colors.deepOrange],
              ),
              _buildOverviewCard(
                icon: Icons.calendar_today,
                title: 'Year-to-Date Stock',
                subtitle: 'Stock Level',
                value: '$yearToDateStock',
                gradientColors: [Colors.purpleAccent, Colors.indigo],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<Color> gradientColors,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.6),
            child: Icon(icon, color: gradientColors.first, size: 28),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          trailing: Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
