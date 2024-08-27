import 'package:flutter/material.dart';
import 'package:vendorpal/widget/saleform.dart';
import 'package:vendorpal/widget/salelistwidget.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Sales'),
      ),
      body: SaleListWidget(),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(eccentricity: 0),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => SaleFormWidget(),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Record New Sale',
      ),
    );
  }
}
