import 'package:flutter/material.dart';
import 'package:vendorpal/databases/database.dart';

class SalesForecast extends StatefulWidget {
  final IsarService isarService;

  const SalesForecast({Key? key, required this.isarService}) : super(key: key);

  @override
  _SalesForecastState createState() => _SalesForecastState();
}

class _SalesForecastState extends State<SalesForecast> {
  late PageController _forecastPageController;
  double _totalSales = 0.0;
  double _projectedSales = 0.0;
  double _yearToDateSales = 0.0;

  @override
  void initState() {
    super.initState();
    _forecastPageController = PageController();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    // Fetch total sales for each month of the current year
    DateTime now = DateTime.now();
    double totalSalesForCurrentMonth =
        await widget.isarService.getTotalSalesForMonth(now.year, now.month);
    double totalSalesForPreviousMonth =
        await widget.isarService.getTotalSalesForMonth(now.year, now.month - 1);

    // Calculate the growth rate between the current and previous months
    double growthRate = (totalSalesForPreviousMonth != 0)
        ? (totalSalesForCurrentMonth - totalSalesForPreviousMonth) /
            totalSalesForPreviousMonth
        : 0.0;

    // Adjust growth rate for seasonality
    double seasonalityIndex =
        await widget.isarService.getSeasonalityIndexForMonth(now.month);
    _projectedSales =
        totalSalesForCurrentMonth * (1 + growthRate) * seasonalityIndex;

    // Fetch the total sales for the current month
    _totalSales =
        await widget.isarService.getTotalSalesForMonth(now.year, now.month);

    // Fetch the year-to-date sales
    _yearToDateSales = await widget.isarService.getTotalSalesForYear(now.year);

    setState(() {});
  }

  @override
  void dispose() {
    _forecastPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sales Forecast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView(
            controller: _forecastPageController,
            children: [
              OverviewCard(
                icon: Icons.trending_up,
                title: 'Projected Sales',
                subtitle: 'Next Month',
                value: '\$${_projectedSales.toStringAsFixed(2)}',
                backgroundGradient: const LinearGradient(
                  colors: [Colors.pinkAccent, Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                iconColor: Colors.redAccent,
              ),
              OverviewCard(
                icon: Icons.date_range,
                title: 'Current Month',
                subtitle: 'Sales So Far',
                value: '\$${_totalSales.toStringAsFixed(2)}',
                backgroundGradient: const LinearGradient(
                  colors: [Colors.lightBlueAccent, Colors.cyanAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                iconColor: Colors.blueAccent,
              ),
              OverviewCard(
                icon: Icons.timeline,
                title: 'Year-to-Date',
                subtitle: 'Total Sales',
                value: '\$${_yearToDateSales.toStringAsFixed(2)}',
                backgroundGradient: const LinearGradient(
                  colors: [Colors.tealAccent, Colors.greenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                iconColor: Colors.greenAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final LinearGradient backgroundGradient;
  final Color iconColor;

  const OverviewCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.backgroundGradient,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
