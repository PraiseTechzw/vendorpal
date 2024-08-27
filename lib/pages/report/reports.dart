import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vendorpal/databases/database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vendorpal/databases/pdf_database.dart';
import 'package:vendorpal/main.dart';
import 'package:vendorpal/modals/packages.dart';
import 'package:vendorpal/pages/report/summary.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  bool isLoading = true;
  late Future<void> _fetchDataFuture;
  late List<SaleTransaction> salesData = [];
  late List<StockItem> stockItems = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    final isarService = Provider.of<IsarService>(context, listen: false);
    try {
      final results = await Future.wait([
        isarService.getAllSaleTransactions(),
        isarService.getAllStockItems(),
      ]);

      setState(() {
        salesData = results[0] as List<SaleTransaction>;
        stockItems = results[1] as List<StockItem>;
        isLoading = false;
      });

      print('Sales data: $salesData');
      print('Stock items: $stockItems');
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $error')),
      );
    }
  }

  Future<void> _generatePDF() async {
    try {
      await _requestPermissions();

      final isarService = Provider.of<IsarService>(context, listen: false);

      print("Generating PDF report...");
      await isarService.generateReport(DateTime.now());
      print("PDF report generated successfully.");

      await _showNotification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report generated successfully!')),
      );
    } catch (e) {
      if (await Permission.manageExternalStorage.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Storage permission denied. Please enable it from settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      } else {
        print("Error generating PDF report: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    if (!await Permission.manageExternalStorage.isGranted) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        throw Exception("Storage permission not granted");
      }
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'report_channel_id',
      'Report Notifications',
      channelDescription: 'Notifications for report generation',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'PDF Report Generated',
      'Your report has been successfully generated.',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Vendor Sales Report'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SummarySection(
                    startDate: startDate,
                    endDate: endDate,
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generatePDF,
        tooltip: 'Download Report',
        child: const Icon(Icons.download),
      ),
    );
  }
}
