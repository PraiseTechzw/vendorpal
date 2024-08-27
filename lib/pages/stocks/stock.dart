import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vendorpal/modals/packages.dart';

class AnalyticsView extends StatefulWidget {
  final List<StockItem> products;

  AnalyticsView({required this.products});

  @override
  _AnalyticsViewState createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  int _touchedIndex = -1;
  Map<String, Color> _categoryColors = {};
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _generateCategoryColors();
  }

  void _generateCategoryColors() {
    final colors = [
      Colors.blueAccent,
      const Color.fromARGB(255, 7, 236, 126),
      const Color.fromARGB(255, 200, 7, 235),
      Colors.orangeAccent,
      Colors.redAccent,
      const Color.fromARGB(255, 0, 255, 255),
      Colors.yellowAccent,
      Colors.pinkAccent,
      const Color.fromARGB(255, 93, 187, 165),
      const Color.fromARGB(255, 201, 168, 49),
    ];

    // Get unique categories from the products
    final categories = widget.products.map((item) => item.category).toSet();

    // Ensure we have enough colors for the number of unique categories
    if (categories.length > colors.length) {
      // Optionally, handle the case where there are more categories than colors
      // For example, you could generate more colors dynamically or reuse colors
      throw Exception('Not enough unique colors for the number of categories.');
    }

    // Create a list from the colors to avoid modifying the original list
    final availableColors = List<Color>.from(colors);

    // Assign a unique color to each category
    categories.forEach((category) {
      if (!_categoryColors.containsKey(category)) {
        // Shuffle the available colors to ensure randomness
        availableColors.shuffle();
        _categoryColors[category] = availableColors.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalStockValue = widget.products
        .fold(0, (sum, item) => sum + (item.stockQuantity * item.sellingPrice));

    int lowStockCount =
        widget.products.where((item) => item.stockQuantity < 10).length;

    Map<String, int> categoryCounts = {};
    for (var product in widget.products) {
      categoryCounts[product.category] =
          (categoryCounts[product.category] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMotivationSection(lowStockCount, totalStockValue),
          const SizedBox(height: 20),
          const Text(
            'Category Breakdown:',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        _selectedCategory = null;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                      _selectedCategory =
                          categoryCounts.keys.toList()[_touchedIndex];
                    });
                  },
                ),
                sections: _buildPieChartSections(
                    categoryCounts, widget.products.length),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(categoryCounts),
          const SizedBox(height: 30),
          _buildInsightsSection(
              widget.products, totalStockValue, lowStockCount),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      Map<String, int> categoryCounts, int totalItems) {
    return categoryCounts.entries.map((entry) {
      final category = entry.key;
      final count = entry.value;
      final percentage = (count / totalItems) * 100;
      final isTouched =
          categoryCounts.keys.toList().indexOf(category) == _touchedIndex;
      final double radius = isTouched ? 60 : 50;

      return PieChartSectionData(
        value: percentage,
        title:
            isTouched ? '$category\n(${percentage.toStringAsFixed(1)}%)' : '',
        color: _getColorForCategory(category),
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, int> categoryCounts) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categoryCounts.entries.map((entry) {
        final category = entry.key;
        final count = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getColorForCategory(category),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$category ($count)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getColorForCategory(String category) {
    return _categoryColors[category] ?? Colors.grey;
  }

  Widget _buildMotivationSection(int lowStockCount, double totalStockValue) {
    String message;
    IconData icon;
    Color color;

    if (lowStockCount > 5) {
      message =
          'Warning: Many items are running low on stock! Consider reordering soon to avoid disruptions.';
      icon = Icons.warning_amber_rounded;
      color = Colors.redAccent;
    } else if (lowStockCount > 0) {
      message =
          'Keep an eye on your stock levels! A few items are running low, so make sure to reorder them.';
      icon = Icons.lightbulb_outline;
      color = Colors.orange;
    } else if (totalStockValue > totalStockValue * 2) {
      message =
          'Great job! Your stock value is strong. Consider focusing on sales strategies to boost turnover.';
      icon = Icons.thumb_up_alt;
      color = Colors.green;
    } else {
      message =
          'Your stock levels are healthy, but keep monitoring to maintain this balance.';
      icon = Icons.check_circle_outline;
      color = Colors.blueAccent;
    }

    double? categoryProfit;
    List<StockItem>? categoryItems;
    if (_selectedCategory != null) {
      // Calculate the total profit for the selected category
      double totalCost = widget.products
          .where((item) => item.category == _selectedCategory!)
          .fold(0.0,
              (sum, item) => sum + (item.purchasePrice * item.stockQuantity));

      double totalRevenue = widget.products
          .where((item) => item.category == _selectedCategory!)
          .fold(0.0,
              (sum, item) => sum + (item.sellingPrice * item.stockQuantity));

      categoryProfit = totalRevenue - totalCost;

      // Get the list of items in the selected category
      categoryItems = widget.products
          .where((item) => item.category == _selectedCategory!)
          .toList();
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (_selectedCategory != null) ...[
            const SizedBox(height: 20),
            Text(
              'Category: $_selectedCategory!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Number of Items: ${categoryItems?.length ?? 0}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 10),
            if (categoryProfit != null)
              Text(
                'Profit: \$${categoryProfit.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              ),
            const SizedBox(height: 10),
            if (categoryItems != null) ...[
              const Text(
                'Products in this category:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              ...categoryItems.map((item) => Text(
                    '- ${item.itemName} (Stock: ${item.stockQuantity}, Profit: \$${((item.sellingPrice - item.purchasePrice) * item.stockQuantity).toStringAsFixed(2)})',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  )),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInsightsSection(
      List<StockItem> products, double totalStockValue, int lowStockCount) {
    double avgPurchasePrice =
        products.fold(0.0, (sum, item) => sum + item.purchasePrice) /
            products.length;
    double avgSellingPrice =
        products.fold(0.0, (sum, item) => sum + item.sellingPrice) /
            products.length;

    List<String> suggestions = [];
    if (avgSellingPrice > avgPurchasePrice * 1.5) {
      suggestions.add(
          'Your profit margins are strong. Consider reinvesting in high-performing categories.');
    } else if (avgSellingPrice < avgPurchasePrice * 1.2) {
      suggestions.add(
          'Your profit margins are tight. Look for ways to reduce costs or optimize pricing.');
    }

    if (totalStockValue >= 50) {
      suggestions.add(
          'Your total stock value is high. Focus on converting inventory into sales to avoid overstocking.');
    } else if (totalStockValue <= 100) {
      suggestions.add(
          'Consider increasing your inventory to ensure you can meet customer demand.');
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.tealAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Insights:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '1. Total Stock Value: \$${totalStockValue.toStringAsFixed(2)}\n'
            '   - Regularly monitor this metric to assess inventory health.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '2. Average Purchase Price: \$${avgPurchasePrice.toStringAsFixed(2)}\n'
            '   - Work with suppliers to reduce costs.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '3. Average Selling Price: \$${avgSellingPrice.toStringAsFixed(2)}\n'
            '   - Ensure your pricing is competitive yet profitable.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '4. Low Stock Items: $lowStockCount\n'
            '   - Implement automatic stock alerts for timely reorders.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '5. Stock Turnover Rate: ${(totalStockValue / 100).toStringAsFixed(2)}\n'
            '   - Aim for a higher turnover rate to maximize sales efficiency.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Suggestions:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 10),
          ...suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  suggestion,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
