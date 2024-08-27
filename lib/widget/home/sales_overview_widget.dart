import 'package:flutter/material.dart';

class SalesOverview extends StatefulWidget {
  final PageController salesPageController;
  final double dailySales;
  final double weeklySales;
  final double monthlySales;
  final double dailyProfits;
  final double weeklyProfits;
  final double monthlyProfits;
  final int dailyQuantitySold;
  final int weeklyQuantitySold;
  final int monthlyQuantitySold;

  const SalesOverview({
    Key? key,
    required this.salesPageController,
    required this.dailySales,
    required this.weeklySales,
    required this.monthlySales,
    required this.dailyProfits,
    required this.weeklyProfits,
    required this.monthlyProfits,
    required this.dailyQuantitySold,
    required this.weeklyQuantitySold,
    required this.monthlyQuantitySold,
  }) : super(key: key);

  @override
  _SalesOverviewState createState() => _SalesOverviewState();
}

class _SalesOverviewState extends State<SalesOverview> {
  String selectedPeriod = 'Day';

  @override
  Widget build(BuildContext context) {
    double totalSales, totalProfits;
    int totalQuantitySold;

    // Determine values based on the selected period
    switch (selectedPeriod) {
      case 'Week':
        totalSales = widget.weeklySales;
        totalProfits = widget.weeklyProfits;
        totalQuantitySold = widget.weeklyQuantitySold;
        break;
      case 'Month':
        totalSales = widget.monthlySales;
        totalProfits = widget.monthlyProfits;
        totalQuantitySold = widget.monthlyQuantitySold;
        break;
      default:
        totalSales = widget.dailySales;
        totalProfits = widget.dailyProfits;
        totalQuantitySold = widget.dailyQuantitySold;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title of the section
          const Text(
            'Sales Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Period selection row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Period: $selectedPeriod',
                style: const TextStyle(fontSize: 16),
              ),
              DropdownButton<String>(
                value: selectedPeriod,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPeriod = newValue!;
                  });
                },
                items: <String>['Day', 'Week', 'Month']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Overview cards showing sales, profits, and quantity sold
          SizedBox(
            height: 220,
            child: PageView(
              controller: widget.salesPageController,
              children: [
                OverviewCard(
                  icon: Icons.attach_money,
                  title: 'Total Sales',
                  subtitle: 'Amount Earned',
                  value: '\$${totalSales.toStringAsFixed(2)}',
                  backgroundColor: Colors.white.withOpacity(0.15),
                  iconColor: Colors.greenAccent,
                ),
                OverviewCard(
                  icon: Icons.show_chart,
                  title: 'Total Profits',
                  subtitle: 'Profits Earned',
                  value: '\$${totalProfits.toStringAsFixed(2)}',
                  backgroundColor: Colors.white.withOpacity(0.15),
                  iconColor: Colors.orangeAccent,
                ),
                OverviewCard(
                  icon: Icons.shopping_cart,
                  title: 'Items Sold',
                  subtitle: 'Total Quantity Sold',
                  value: '$totalQuantitySold',
                  backgroundColor: Colors.white.withOpacity(0.15),
                  iconColor: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Color backgroundColor;
  final Color iconColor;

  const OverviewCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.backgroundColor,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon representation
          Icon(
            icon,
            size: 40,
            color: iconColor,
          ),
          const SizedBox(height: 8),

          // Title of the card
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const Spacer(),

          // Value displayed prominently
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
