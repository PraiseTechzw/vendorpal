import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vendorpal/databases/database.dart';
import 'dart:ui';

import 'package:vendorpal/modals/packages.dart';
import 'package:vendorpal/widget/saleform.dart';

class SaleListWidget extends StatefulWidget {
  @override
  _SaleListWidgetState createState() => _SaleListWidgetState();
}

class _SaleListWidgetState extends State<SaleListWidget> {
  DateTimeRange? _selectedDateRange;
  String _searchQuery = '';
  double _minQuantity = 0;
  double _maxSaleAmount = 1000;

  @override
  Widget build(BuildContext context) {
    return Consumer<IsarService>(
      builder: (context, isarService, child) {
        return Column(
          children: [
            _buildSearchAndFilterControls(),
            Expanded(
              child: FutureBuilder(
                future: isarService.getAllSaleTransactions(),
                builder:
                    (context, AsyncSnapshot<List<SaleTransaction>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: _buildFirstTimeUserPrompt());
                  } else {
                    // Filter sales based on the criteria
                    List<SaleTransaction> sales = snapshot.data!;
                    if (_searchQuery.isNotEmpty) {
                      sales = sales
                          .where((sale) => sale.itemName
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();
                    }
                    if (_selectedDateRange != null) {
                      sales = sales
                          .where((sale) =>
                              sale.date.isAfter(_selectedDateRange!.start) &&
                              sale.date.isBefore(_selectedDateRange!.end))
                          .toList();
                    }
                    sales = sales
                        .where((sale) => sale.quantitySold >= _minQuantity)
                        .toList();
                    sales = sales
                        .where((sale) => sale.totalSaleAmount <= _maxSaleAmount)
                        .toList();

                    return ListView.builder(
                      itemCount: sales.length,
                      itemBuilder: (context, index) {
                        final sale = sales[index];

                        return Dismissible(
                          key: Key(sale.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              'Delete',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Sale'),
                                content: const Text(
                                  'Are you sure you want to delete this sale?',
                                  style: TextStyle(fontSize: 16),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            );
                            return confirm;
                          },
                          onDismissed: (direction) async {
                            await isarService.deleteSaleTransaction(sale.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sale deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Card(
                            elevation: 10,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                'Product: ${sale.itemName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Date: ${DateFormat('dd-MM-yy HH:mm:ss').format(sale.date)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Quantity Sold: ${sale.quantitySold}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total Sale Amount: \$${sale.totalSaleAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      _buildSaleDetailsDialog(context, sale),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFirstTimeUserPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/empty_state.json',
          width: 250,
          height: 250,
        ),
        const Text(
          'No Data Available',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            shadowColor: Colors.purpleAccent,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => SaleFormWidget(),
            );
          },
          child: const Text(
            'Add Your First Sale',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85), // Dark background for contrast
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white, size: 24),
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search by item name',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_alt, color: Colors.white, size: 24),
              onPressed: () => _showFilterDialog(),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 15,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Filter Sales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Date Range'),
              subtitle: Text(_selectedDateRange == null
                  ? 'Select date range'
                  : 'From ${DateFormat('dd-MM-yyyy').format(_selectedDateRange!.start)} to ${DateFormat('dd-MM-yyyy').format(_selectedDateRange!.end)}'),
              onTap: () async {
                DateTimeRange? newRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  initialDateRange: _selectedDateRange,
                );
                if (newRange != null) {
                  setState(() {
                    _selectedDateRange = newRange;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            _buildMinQuantitySlider(),
            const SizedBox(height: 10),
            _buildMaxSaleAmountSlider(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('Close', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinQuantitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Minimum Quantity Sold', style: TextStyle(fontSize: 16)),
        Slider(
          value: _minQuantity,
          min: 0,
          max: 100,
          divisions: 100,
          label: _minQuantity.round().toString(),
          onChanged: (value) {
            setState(() {
              _minQuantity = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMaxSaleAmountSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Maximum Sale Amount (\$)', style: TextStyle(fontSize: 16)),
        Slider(
          value: _maxSaleAmount,
          min: 0,
          max: 5000,
          divisions: 50,
          label: '\$${_maxSaleAmount.round()}',
          onChanged: (value) {
            setState(() {
              _maxSaleAmount = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSaleDetailsDialog(BuildContext context, SaleTransaction sale) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product: ${sale.itemName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Quantity Sold: ${sale.quantitySold}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Sale Amount: \$${sale.totalSaleAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Date: ${DateFormat('dd-MM-yy HH:mm:ss').format(sale.date)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('Close', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
