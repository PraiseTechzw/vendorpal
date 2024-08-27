// File: lib/widgets/sales_overview_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MetricCardWidget extends StatelessWidget {
  final double data;
  final String label;
  final IconData icon;
  final Color color;

  MetricCardWidget({
    required this.data,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              NumberFormat.currency(symbol: '\$').format(data),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesOverviewWidget extends StatelessWidget {
  final double totalSales;
  final double totalProfits;
  final int totalQuantitySold;

  SalesOverviewWidget({
    required this.totalSales,
    required this.totalProfits,
    required this.totalQuantitySold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sales Overview',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MetricCardWidget(
              data: totalSales,
              label: 'Total Sales',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            MetricCardWidget(
              data: totalProfits,
              label: 'Total Profits',
              icon: Icons.trending_up,
              color: Colors.blue,
            ),
            MetricCardWidget(
              data: totalQuantitySold.toDouble(),
              label: 'Total Quantity Sold',
              icon: Icons.shopping_cart,
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }
}
