import 'dart:io';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vendorpal/constants/pdf_services.dart';
import 'package:vendorpal/modals/packages.dart';

class IsarService extends ChangeNotifier {
  static late Isar db;
  final PdfService _pdfService = PdfService(); // Instantiate the PdfService

  /// Initialize the database
  Future<void> initializeDB() async {
    db = await openDB();
  }

  /// Open the Isar database
  Future<Isar> openDB() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          StockItemSchema,
          SaleTransactionSchema,
          ReportSchema,
          DailyStatsSchema, // Add this
          WeeklyStatsSchema, // Add this
          MonthlyStatsSchema,
        ],
        directory: dir.path,
      );
    } catch (e) {
      debugPrint("Error opening Isar database: $e");
      rethrow;
    }
  }

  /// Add a stock item to the database
  Future<void> addStockItem(StockItem item) async {
    try {
      await db.writeTxn(() => db.stockItems.put(item));
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding stock item: $e");
    }
  }

  /// Add a sale transaction to the database
  Future<void> addSaleTransaction(SaleTransaction transaction) async {
    try {
      await db.writeTxn(() => db.saleTransactions.put(transaction));

      // Retrieve cost from StockItem
      final cost = await _getItemCost(transaction.itemName);

      // Update daily, weekly, and monthly stats
      await _updateDailyStats(transaction, cost);
      await _updateWeeklyStats(transaction, cost);
      await _updateMonthlyStats(transaction, cost);

      notifyListeners();
    } catch (e) {
      debugPrint("Error adding sale transaction: $e");
    }
  }

  Future<double> _getItemCost(String itemName) async {
    final item = await db.stockItems
        .where()
        .filter()
        .itemNameEqualTo(itemName)
        .findFirst();
    if (item != null) {
      return item.purchasePrice; // Assuming purchasePrice is the cost
    } else {
      throw Exception("Item not found");
    }
  }

  Future<void> _updateDailyStats(
      SaleTransaction transaction, double cost) async {
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);

    final existingStats = await db.dailyStats
        .where()
        .filter()
        .dateEqualTo(startOfDay)
        .findFirst();

    if (existingStats != null) {
      existingStats.totalSales += transaction.totalSaleAmount;
      existingStats.totalProfit += (transaction.totalSaleAmount - cost);
      existingStats.totalQuantitySold += transaction.quantitySold;
      await db.writeTxn(() => db.dailyStats.put(existingStats));
    } else {
      final newStats = DailyStats()
        ..date = startOfDay
        ..totalSales = transaction.totalSaleAmount
        ..totalProfit = (transaction.totalSaleAmount - cost)
        ..totalQuantitySold = transaction.quantitySold;
      await db.writeTxn(() => db.dailyStats.put(newStats));
    }
  }

  Future<void> _updateWeeklyStats(
      SaleTransaction transaction, double cost) async {
    final DateTime today = DateTime.now();
    final DateTime startOfWeek =
        today.subtract(Duration(days: today.weekday - 1));

    final existingStats = await db.weeklyStats
        .where()
        .filter()
        .startOfWeekEqualTo(startOfWeek)
        .findFirst();

    if (existingStats != null) {
      existingStats.totalSales += transaction.totalSaleAmount;
      existingStats.totalProfit += (transaction.totalSaleAmount - cost);
      existingStats.totalQuantitySold += transaction.quantitySold;
      await db.writeTxn(() => db.weeklyStats.put(existingStats));
    } else {
      final newStats = WeeklyStats()
        ..startOfWeek = startOfWeek
        ..totalSales = transaction.totalSaleAmount
        ..totalProfit = (transaction.totalSaleAmount - cost)
        ..totalQuantitySold = transaction.quantitySold;
      await db.writeTxn(() => db.weeklyStats.put(newStats));
    }
  }

  Future<void> _updateMonthlyStats(
      SaleTransaction transaction, double cost) async {
    final DateTime today = DateTime.now();
    final DateTime startOfMonth = DateTime(today.year, today.month, 1);

    final existingStats = await db.monthlyStats
        .where()
        .filter()
        .monthEqualTo(startOfMonth)
        .findFirst();

    if (existingStats != null) {
      existingStats.totalSales += transaction.totalSaleAmount;
      existingStats.totalProfit += (transaction.totalSaleAmount - cost);
      existingStats.totalQuantitySold += transaction.quantitySold;
      await db.writeTxn(() => db.monthlyStats.put(existingStats));
    } else {
      final newStats = MonthlyStats()
        ..month = startOfMonth
        ..totalSales = transaction.totalSaleAmount
        ..totalProfit = (transaction.totalSaleAmount - cost)
        ..totalQuantitySold = transaction.quantitySold;
      await db.writeTxn(() => db.monthlyStats.put(newStats));
    }
  }

  /// Add a report to the database
  Future<void> addReport(Report report) async {
    try {
      await db.writeTxn(() => db.reports.put(report));
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding report: $e");
    }
  }

  /// Get all stock items
  Future<List<StockItem>> getAllStockItems() async {
    return await db.stockItems.where().findAll();
  }

  /// Get total stock
  Future<int> getTotalStock() async {
    final stockItems = await db.stockItems.where().findAll();
    return stockItems.fold<int>(0, (sum, item) => sum + item.stockQuantity);
  }

  /// Get all sale transactions
  Future<List<SaleTransaction>> getAllSaleTransactions() async {
    return await db.saleTransactions.where().findAll();
  }

  /// Get all reports
  Future<List<Report>> getAllReports() async {
    return await db.reports.where().findAll();
  }

  /// Get total sales amount
  Future<double> getTotalSales() async {
    final sales = await db.saleTransactions.where().findAll();
    return sales.fold<double>(0.0, (sum, sale) => sum + sale.totalSaleAmount);
  }

  /// Get total profit
  Future<double> getTotalProfit() async {
    final sales = await db.saleTransactions.where().findAll();
    double totalProfit = 0.0;

    for (final sale in sales) {
      final stockItem = await db.stockItems
          .where()
          .filter()
          .itemNameEqualTo(sale.itemName)
          .findFirst();

      if (stockItem != null) {
        totalProfit += (stockItem.sellingPrice - stockItem.purchasePrice) *
            sale.quantitySold;
      }
    }
    notifyListeners();

    return totalProfit;
  }

  /// Get total inventory value
  Future<double> getTotalInventory() async {
    final stockItems = await db.stockItems.where().findAll();
    return stockItems.fold<double>(
        0.0, (sum, item) => sum + (item.stockQuantity * item.purchasePrice));
  }

  /// Get total quantity sold
  Future<int> getTotalQuantitySold() async {
    final sales = await db.saleTransactions.where().findAll();
    return sales.fold<int>(0, (sum, sale) => sum + sale.quantitySold);
  }

  /// Calculate sales growth
  Future<double> calculateSalesGrowth() async {
    try {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      final previousMonth = DateTime(now.year, now.month - 1);

      final currentMonthSales = await db.saleTransactions
          .where()
          .filter()
          .dateBetween(currentMonth, now)
          .findAll();

      final previousMonthSales = await db.saleTransactions
          .where()
          .filter()
          .dateBetween(previousMonth, currentMonth)
          .findAll();

      final currentMonthTotal = currentMonthSales.fold<double>(
          0.0, (sum, sale) => sum + sale.totalSaleAmount);
      final previousMonthTotal = previousMonthSales.fold<double>(
          0.0, (sum, sale) => sum + sale.totalSaleAmount);

      if (previousMonthTotal == 0) {
        return currentMonthTotal > 0 ? 100.0 : 0.0;
      }

      final growth =
          ((currentMonthTotal - previousMonthTotal) / previousMonthTotal) * 100;

      return growth;
    } catch (e) {
      debugPrint("Error calculating sales growth: $e");
      return 0.0;
    }
  }

  /// Get low stock items based on a threshold
  Future<List<StockItem>> getLowStockItems(int threshold) async {
    try {
      return await db.stockItems
          .where()
          .filter()
          .stockQuantityLessThan(threshold)
          .findAll();
    } catch (e) {
      debugPrint("Error fetching low stock items: $e");
      return [];
    }
  }

  /// Delete a stock item by ID
  Future<void> deleteStockItem(int id) async {
    try {
      await db.writeTxn(() => db.stockItems.delete(id));
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting stock item: $e");
    }
  }

  /// Update a stock item
  Future<void> updateStockItem(StockItem item) async {
    try {
      await db.writeTxn(() => db.stockItems.put(item));
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating stock item: $e");
    }
  }

  /// Delete a sale transaction by ID
  Future<void> deleteSaleTransaction(int id) async {
    try {
      await db.writeTxn(() => db.saleTransactions.delete(id));
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting sale transaction: $e");
    }
  }

  /// Delete a report by ID
  Future<void> deleteReport(int id) async {
    try {
      await db.writeTxn(() => db.reports.delete(id));
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting report: $e");
    }
  }

  /// Get reports within a specific date range
  Future<List<Report>> getReportsInRange(DateTime start, DateTime end) async {
    return await db.reports.where().filter().dateBetween(start, end).findAll();
  }

  // /// Get total sales amount for the current day
  // Future<double> getTotalSalesForToday() async {
  //   DateTime now = DateTime.now();
  //   DateTime startOfDay = DateTime(now.year, now.month, now.day);
  //   final sales = await db.saleTransactions
  //       .where()
  //       .filter()
  //       .dateEqualTo(startOfDay)
  //       .findAll();
  //   return sales.fold<double>(0.0, (sum, sale) => sum + sale.totalSaleAmount);
  // }

  // /// Get total profit for the current day
  // Future<double> getTotalProfitForToday() async {
  //   DateTime now = DateTime.now();
  //   DateTime startOfDay = DateTime(now.year, now.month, now.day);
  //   final sales = await db.saleTransactions
  //       .where()
  //       .filter()
  //       .dateEqualTo(startOfDay)
  //       .findAll();
  //   double totalProfit = 0.0;

  //   for (final sale in sales) {
  //     final stockItem = await db.stockItems
  //         .where()
  //         .filter()
  //         .itemNameEqualTo(sale.itemName)
  //         .findFirst();

  //     if (stockItem != null) {
  //       totalProfit += (stockItem.sellingPrice - stockItem.purchasePrice) *
  //           sale.quantitySold;
  //     }
  //   }
  //   notifyListeners();

  //   return totalProfit;
  // }
  Future<Map<String, double>> getSalesDistribution() async {
    final sales = await getAllSaleTransactions();
    final Map<String, double> salesMap = {};

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek =
        now.add(Duration(days: DateTime.daysPerWeek - now.weekday));

    for (final sale in sales) {
      // Assuming sale.date is the DateTime of the sale
      if (sale.date.isAfter(startOfWeek) && sale.date.isBefore(endOfWeek)) {
        if (salesMap.containsKey(sale.itemName)) {
          salesMap[sale.itemName] =
              salesMap[sale.itemName]! + sale.totalSaleAmount;
        } else {
          salesMap[sale.itemName] = sale.totalSaleAmount;
        }
      }
    }

    return salesMap;
  }

  Future<List<double>> getWeeklySales() async {
    final sales = await getAllSaleTransactions();
    List<double> weeklySales = List.filled(7, 0.0);

    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek =
        startOfWeek.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    for (final sale in sales) {
      DateTime saleDate = sale.date;
      if (saleDate.isAfter(startOfWeek) && saleDate.isBefore(endOfWeek)) {
        int index = saleDate.weekday - 1;
        weeklySales[index] += sale.totalSaleAmount;
        print(
            'Sale on ${saleDate.toString()}: Added \$${sale.totalSaleAmount} to day index $index');
      } else {
        print('Sale on ${saleDate.toString()} not in the current week.');
      }
    }

    print('Final Weekly Sales: $weeklySales');
    return weeklySales;
  }

  Future<double> getTotalSalesForMonth(int year, int month) async {
    DateTime startOfMonth = DateTime(year, month, 1);
    DateTime endOfMonth =
        DateTime(year, month + 1, 1).subtract(Duration(seconds: 1));

    final sales = await db.saleTransactions
        .where()
        .filter()
        .dateBetween(startOfMonth, endOfMonth)
        .findAll();

    return sales.fold<double>(0.0, (sum, sale) => sum + sale.totalSaleAmount);
  }

  Future<double> getTotalSalesForYear(int year) async {
    DateTime startOfYear = DateTime(year, 1, 1);
    DateTime now = DateTime.now();

    final sales = await db.saleTransactions
        .where()
        .filter()
        .dateBetween(startOfYear, now)
        .findAll();

    return sales.fold<double>(0.0, (sum, sale) => sum + sale.totalSaleAmount);
  }

  Future<double> getSeasonalityIndexForMonth(int month) async {
    // Implement logic based on historical data to adjust for seasonality
    // For simplicity, return 1.0 (no adjustment)
    return 1.0;
  }

  Future<int> getLastMonthStock() async {
    final now = DateTime.now();
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth =
        DateTime(now.year, now.month, 1).subtract(Duration(seconds: 1));

    final stockItems = await db.stockItems
        .where()
        .filter()
        .dateAddedBetween(startOfLastMonth, endOfLastMonth)
        .findAll();

    return stockItems.fold<int>(0, (sum, item) => sum + item.stockQuantity);
  }

  /// Fetch stock items added in the current month
  Future<int> getCurrentMonthStock() async {
    final now = DateTime.now();
    final startOfCurrentMonth = DateTime(now.year, now.month, 1);

    final stockItems = await db.stockItems
        .where()
        .filter()
        .dateAddedGreaterThan(startOfCurrentMonth)
        .findAll();

    return stockItems.fold<int>(0, (sum, item) => sum + item.stockQuantity);
  }

  /// Fetch stock items added year-to-date
  Future<int> getYearToDateStock() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);

    final stockItems = await db.stockItems
        .where()
        .filter()
        .dateAddedGreaterThan(startOfYear)
        .findAll();

    return stockItems.fold<int>(0, (sum, item) => sum + item.stockQuantity);
  }

  Future<DailyStats?> getDailyStats(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return await db.dailyStats
        .where()
        .filter()
        .dateEqualTo(startOfDay)
        .findFirst();
  }

  Future<WeeklyStats?> getWeeklyStats(DateTime date) async {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return await db.weeklyStats
        .where()
        .filter()
        .startOfWeekEqualTo(startOfWeek)
        .findFirst();
  }

  Future<MonthlyStats?> getMonthlyStats(DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    return await db.monthlyStats
        .where()
        .filter()
        .monthEqualTo(startOfMonth)
        .findFirst();
  }

  Future<double> getTotalProfitForToday() async {
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);

    final dailyStats = await db.dailyStats
        .where()
        .filter()
        .dateEqualTo(startOfDay)
        .findFirst();

    return dailyStats?.totalProfit ?? 0.0;
  }

  Future<double> getTotalProfitForWeek() async {
    final DateTime today = DateTime.now();
    final DateTime startOfWeek =
        today.subtract(Duration(days: today.weekday - 1));

    final weeklyStats = await db.weeklyStats
        .where()
        .filter()
        .startOfWeekEqualTo(startOfWeek)
        .findFirst();

    return weeklyStats?.totalProfit ?? 0.0;
  }

  Future<double> getTotalProfitForMonth() async {
    final DateTime today = DateTime.now();
    final DateTime startOfMonth = DateTime(today.year, today.month, 1);

    final monthlyStats = await db.monthlyStats
        .where()
        .filter()
        .monthEqualTo(startOfMonth)
        .findFirst();

    return monthlyStats?.totalProfit ?? 0.0;
  }

  Future<int> getTotalQuantitySoldForToday() async {
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);

    final dailyStats = await db.dailyStats
        .where()
        .filter()
        .dateEqualTo(startOfDay)
        .findFirst();

    return dailyStats?.totalQuantitySold ?? 0;
  }

  Future<int> getTotalQuantitySoldForWeek() async {
    final DateTime today = DateTime.now();
    final DateTime startOfWeek =
        today.subtract(Duration(days: today.weekday - 1));

    final weeklyStats = await db.weeklyStats
        .where()
        .filter()
        .startOfWeekEqualTo(startOfWeek)
        .findFirst();

    return weeklyStats?.totalQuantitySold ?? 0;
  }

  Future<int> getTotalQuantitySoldForMonth() async {
    final DateTime today = DateTime.now();
    final DateTime startOfMonth = DateTime(today.year, today.month, 1);

    final monthlyStats = await db.monthlyStats
        .where()
        .filter()
        .monthEqualTo(startOfMonth)
        .findFirst();

    return monthlyStats?.totalQuantitySold ?? 0;
  }

  Future<double> getTotalSalesForWeek() async {
    final DateTime today = DateTime.now();
    final DateTime startOfWeek =
        today.subtract(Duration(days: today.weekday - 1));

    final weeklyStats = await db.weeklyStats
        .where()
        .filter()
        .startOfWeekEqualTo(startOfWeek)
        .findFirst();

    return weeklyStats?.totalSales ?? 0.0;
  }

  /// Get total stock within a date range
  Future<int> getTotalStock1(DateTime startDate, DateTime endDate) async {
    final stockItems = await db.stockItems.where().findAll();
    return stockItems.fold<int>(0, (sum, item) => sum + item.stockQuantity);
  }

  /// Get total sales amount within a date range
  Future<double> getTotalSales1(DateTime startDate, DateTime endDate) async {
    final sales = await db.saleTransactions
        .where()
        .filter()
        .dateBetween(startDate, endDate)
        .findAll();
    return sales.fold<double>(0.0, (sum, sale) => sum + sale.totalSaleAmount);
  }

  /// Get total profit within a date range
  Future<double> getTotalProfit1(DateTime startDate, DateTime endDate) async {
    final sales = await db.saleTransactions
        .where()
        .filter()
        .dateBetween(startDate, endDate)
        .findAll();
    double totalProfit = 0.0;

    for (final sale in sales) {
      final stockItem = await db.stockItems
          .where()
          .filter()
          .itemNameEqualTo(sale.itemName)
          .findFirst();

      if (stockItem != null) {
        totalProfit += (stockItem.sellingPrice - stockItem.purchasePrice) *
            sale.quantitySold;
      }
    }

    return totalProfit;
  }

  /// Get total inventory value within a date range
  Future<double> getTotalInventory1(
      DateTime startDate, DateTime endDate) async {
    final stockItems = await db.stockItems.where().findAll();
    return stockItems.fold<double>(
        0.0, (sum, item) => sum + (item.stockQuantity * item.purchasePrice));
  }

  /// Calculate sales growth within a date range
  Future<double> calculateSalesGrowth1(
      DateTime startDate, DateTime endDate) async {
    try {
      final previousPeriodStartDate =
          DateTime(startDate.year, startDate.month - 1);
      final previousPeriodEndDate = DateTime(endDate.year, endDate.month - 1);

      final currentPeriodSales = await db.saleTransactions
          .where()
          .filter()
          .dateBetween(startDate, endDate)
          .findAll();

      final previousPeriodSales = await db.saleTransactions
          .where()
          .filter()
          .dateBetween(previousPeriodStartDate, previousPeriodEndDate)
          .findAll();

      final currentPeriodTotal = currentPeriodSales.fold<double>(
          0.0, (sum, sale) => sum + sale.totalSaleAmount);
      final previousPeriodTotal = previousPeriodSales.fold<double>(
          0.0, (sum, sale) => sum + sale.totalSaleAmount);

      if (previousPeriodTotal == 0) {
        return currentPeriodTotal > 0 ? 100.0 : 0.0;
      }

      final growth =
          ((currentPeriodTotal - previousPeriodTotal) / previousPeriodTotal) *
              100;

      return growth;
    } catch (e) {
      debugPrint("Error calculating sales growth: $e");
      return 0.0;
    }
  }

  Future<void> requestPermissions() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        throw Exception("Storage permission not granted");
      }
    }
  }

  Future<void> generateReport(DateTime reportDate) async {
    try {
      // Request necessary permissions
      await requestPermissions();

      // Fetching data for the report from the database
      final totalSales = await getTotalSales();
      final totalProfits = await getTotalProfit();
      final totalInventory = await getTotalInventory();
      final totalQuantitySold = await getTotalQuantitySold();
      final totalStockValue = await getTotalStock();
      final lowStockAlert =
          (await getLowStockItems(5)).length; // Adjust threshold as needed
      final salesGrowth = await calculateSalesGrowth();
      final double profitMargin =
          totalSales != 0 ? (totalProfits / totalSales) * 100 : 0.0;
      final double cogs =
          await getCostOfGoodsSold(); // Assuming this method exists
      final double averageOrderValue = totalSales /
          (await getTotalOrders()); // Assuming getTotalOrders() exists
      final int totalCustomers =
          await getTotalCustomers(); // Assuming getTotalCustomers() exists

      // Fetching detailed product information
      final allStockItems = await getAllStockItems();
      List<Map<String, dynamic>> productDetails = allStockItems.map((item) {
        final profitPerItem = item.sellingPrice - item.purchasePrice;
        return {
          'name': item.itemName,
          'category':
              item.category, // assuming category exists, if not remove it
          'quantitySold': item.stockQuantity,
          'totalSales':
              item.sellingPrice * item.stockQuantity, // or another logic
          'inventoryValue': item.purchasePrice * item.stockQuantity,
          'profitPerItem': profitPerItem,
          'totalProfit': profitPerItem * item.stockQuantity,
        };
      }).toList();

      // Fetch sales by category and customer metrics (placeholders for now)
      final List<Map<String, dynamic>> salesByCategory =
          await getSalesByCategory(); // Assuming this method exists
      final List<Map<String, dynamic>> customerMetrics =
          await getCustomerMetrics(); // Assuming this method exists

      // Generate the PDF with dynamically fetched data and product details
      final pdfData = await _pdfService.generateReportPdf(
        startDate: DateTime(reportDate.year, reportDate.month,
            1), // Example start date (beginning of the month)
        endDate: reportDate,
        totalSales: totalSales,
        totalProfits: totalProfits,
        totalInventory: totalInventory,
        totalQuantitySold: totalQuantitySold,
        totalStockValue: totalStockValue,
        lowStockAlert: lowStockAlert,
        salesGrowth: salesGrowth,
        profitMargin: profitMargin,
        cogs: cogs,
        averageOrderValue: averageOrderValue,
        totalCustomers: totalCustomers,
        productDetails:
            productDetails, // Pass the product details to the PDF generator
        salesByCategory: salesByCategory,
        customerMetrics: customerMetrics,
      );

      // Determine the path for saving the PDF in the Documents folder
      final directory = Directory(
          '/storage/emulated/0/VendorPal/Documents'); // Documents directory
      final path =
          "${directory.path}/report_${DateFormat('yyyyMMddHHmmss').format(reportDate)}.pdf";
      final file = File(path);

      // Create directory if it does not exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Write the PDF data to file
      await file.writeAsBytes(pdfData);

      print("Report generated successfully at ${file.path}.");
    } catch (e) {
      // Handle errors and provide feedback
      print("Error generating report: $e");
      // You might want to show a Snackbar or dialog here to inform the user
    }
  }

  Future<double> getCostOfGoodsSold() async {
    final isar = Isar.getInstance();
    final sales = await isar!.saleTransactions.where().findAll();

    double totalCogs = 0.0;

    for (final sale in sales) {
      final stockItem = await isar.stockItems
          .filter()
          .itemNameEqualTo(sale.itemName)
          .findFirst();

      if (stockItem != null) {
        totalCogs += stockItem.purchasePrice * sale.quantitySold;
      }
    }

    return totalCogs;
  }

  Future<int> getTotalOrders() async {
    final isar = Isar.getInstance();
    final totalOrders = await isar!.saleTransactions.count();

    return totalOrders;
  }

  Future<int> getTotalCustomers() async {
    // Implementation to fetch total number of customers
    return 0;
  }

  Future<List<Map<String, dynamic>>> getSalesByCategory() async {
    final isar = Isar.getInstance();
    final sales = await isar!.saleTransactions.where().findAll();

    final Map<String, double> salesByCategory = {};

    for (final sale in sales) {
      if (salesByCategory.containsKey(sale.category)) {
        salesByCategory[sale.category] =
            salesByCategory[sale.category]! + sale.totalSaleAmount;
      } else {
        salesByCategory[sale.category] = sale.totalSaleAmount;
      }
    }

    return salesByCategory.entries
        .map((entry) => {'category': entry.key, 'totalSales': entry.value})
        .toList();
  }

  Future<List<Map<String, dynamic>>> getCustomerMetrics() async {
    // Implementation to fetch customer metrics
    return [];
  }
}
