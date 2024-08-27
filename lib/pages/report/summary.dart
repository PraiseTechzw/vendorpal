import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vendorpal/databases/database.dart';
import 'package:vendorpal/modals/packages.dart';

class SummarySection extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const SummarySection({
    Key? key,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  State<SummarySection> createState() => _SummarySectionState();
}

class _SummarySectionState extends State<SummarySection> {
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _dataFuture = _fetchData();
  }

  Future<List<dynamic>> _fetchData() async {
    final isarService = Provider.of<IsarService>(context, listen: false);
    return Future.wait([
      isarService.getTotalStock1(widget.startDate, widget.endDate),
      isarService.getTotalSales1(widget.startDate, widget.endDate),
      isarService.getTotalProfit1(widget.startDate, widget.endDate),
      isarService.getTotalInventory1(widget.startDate, widget.endDate),
      isarService.calculateSalesGrowth1(widget.startDate, widget.endDate),
      isarService.getLowStockItems(5),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final totalStock = snapshot.data![0] as int;
          final totalSales = snapshot.data![1] as double;
          final totalProfit = snapshot.data![2] as double;
          final totalInventory = snapshot.data![3] as double;
          final salesGrowth = snapshot.data![4] as double;
          final lowStockItems = snapshot.data![5] as List<StockItem>;

          return Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSummaryGrid(
                totalStock,
                totalSales,
                totalProfit,
                totalInventory,
                salesGrowth,
                lowStockItems.length,
              ),
            ],
          );
        } else {
          return const Center(child: Text('No data available.'));
        }
      },
    );
  }

  Widget _buildHeader() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final dateRange =
        '${dateFormat.format(widget.startDate)} - ${dateFormat.format(widget.endDate)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Summary Report',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              dateRange,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(
    int totalStock,
    double totalSales,
    double totalProfit,
    double totalInventory,
    double salesGrowth,
    int lowStockItemsCount,
  ) {
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    // Wrapping GridView.builder in a SizedBox to give it a defined height
    return SizedBox(
      // You can adjust the height based on your layout needs
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildSummaryTile(
            index: index,
            totalStock: totalStock,
            totalSales: totalSales,
            totalProfit: totalProfit,
            totalInventory: totalInventory,
            salesGrowth: salesGrowth,
            lowStockItemsCount: lowStockItemsCount,
          );
        },
      ),
    );
  }

  Widget _buildSummaryTile({
    required int index,
    required int totalStock,
    required double totalSales,
    required double totalProfit,
    required double totalInventory,
    required double salesGrowth,
    required int lowStockItemsCount,
  }) {
    String title;
    String value;
    IconData icon;
    Color color;

    switch (index) {
      case 0:
        title = 'Total Stock';
        value = '$totalStock';
        icon = Icons.store;
        color = Colors.blueAccent;
        break;
      case 1:
        title = 'Total Sales';
        value = '\$$totalSales';
        icon = Icons.attach_money;
        color = Colors.greenAccent;
        break;
      case 2:
        title = 'Total Profit';
        value = '\$$totalProfit';
        icon = Icons.trending_up;
        color = totalProfit >= 0 ? Colors.green : Colors.red;
        break;
      case 3:
        title = 'Stock Value';
        value = '\$$totalInventory';
        icon = Icons.inventory;
        color = Colors.orangeAccent;
        break;
      case 4:
        title = 'Sales Growth';
        value = '${salesGrowth.toStringAsFixed(2)}%';
        icon = Icons.show_chart;
        color = salesGrowth >= 0 ? Colors.green : Colors.redAccent;
        break;
      case 5:
        title = 'Low Stock Items';
        value = '$lowStockItemsCount';
        icon = Icons.warning;
        color = Colors.redAccent;
        break;
      default:
        title = '';
        value = '';
        icon = Icons.info;
        color = Colors.grey;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
