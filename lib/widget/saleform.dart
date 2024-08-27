import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vendorpal/databases/database.dart';
import 'package:vendorpal/modals/packages.dart';

class SaleFormWidget extends StatefulWidget {
  @override
  _SaleFormWidgetState createState() => _SaleFormWidgetState();
}

class _SaleFormWidgetState extends State<SaleFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedItem;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _saleAmountController = TextEditingController();
  final now = DateTime.now();
  List<StockItem> _stockItems = [];
  StockItem? _selectedStockItem;

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  Future<void> _loadStockItems() async {
    final items = await Provider.of<IsarService>(context, listen: false)
        .getAllStockItems();
    setState(() {
      _stockItems = items;
    });
  }

  void _updateTotalSaleAmount() {
    if (_selectedStockItem != null && _quantityController.text.isNotEmpty) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final totalSaleAmount = quantity * _selectedStockItem!.sellingPrice;
      _saleAmountController.text = totalSaleAmount.toStringAsFixed(2);
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Record New Sale',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedItem,
                decoration: InputDecoration(
                  labelText: 'Select Product',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedItem = value;
                    _selectedStockItem = _stockItems
                        .firstWhere((stockItem) => stockItem.itemName == value);
                    _updateTotalSaleAmount();
                  });
                },
                items: _stockItems.map((stockItem) {
                  return DropdownMenuItem<String>(
                    value: stockItem.itemName,
                    child: Text(stockItem.itemName),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select a product' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity Sold',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateTotalSaleAmount(),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter quantity' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _saleAmountController,
                decoration: InputDecoration(
                  labelText: 'Total Sale Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter sale amount' : null,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final saleTransaction = SaleTransaction(
                itemName: _selectedItem!,
                quantitySold: int.parse(_quantityController.text),
                totalSaleAmount: double.parse(_saleAmountController.text),
                date: now,
                category: _selectedStockItem!.category,
              );
              await Provider.of<IsarService>(context, listen: false)
                  .addSaleTransaction(saleTransaction);

              // Update stock quantity
              _selectedStockItem!.stockQuantity -=
                  int.parse(_quantityController.text);
              await Provider.of<IsarService>(context, listen: false)
                  .updateStockItem(_selectedStockItem!);

              _showToast('Sale recorded successfully');
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
