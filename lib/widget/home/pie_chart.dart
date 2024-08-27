import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PieChartWidget extends StatelessWidget {
  final Future<Map<String, double>> salesDistributionFuture;

  const PieChartWidget({required this.salesDistributionFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: salesDistributionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          final data = snapshot.data ?? {};
          final total = data.values.fold(0.0, (sum, value) => sum + value);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales Distribution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sections: data.entries.map((entry) {
                      final percentage = (entry.value / total) * 100;
                      return PieChartSectionData(
                        value: percentage,
                        title: '${entry.key} ${percentage.toStringAsFixed(1)}%',
                        color: _getColorForProduct(entry.key),
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Color _getColorForProduct(String product) {
    // You can customize this method to map specific products to specific colors
    final random = Random(product.hashCode);
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }
}
