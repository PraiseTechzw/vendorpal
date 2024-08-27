import 'package:isar/isar.dart';

part 'packages.g.dart';

@Collection()
class StockItem {
  Id id = Isar.autoIncrement;

  late String itemName;
  late String category;
  late double purchasePrice;
  late double sellingPrice;
  late int stockQuantity;
  late DateTime dateAdded; // Add this line

  StockItem({
    required this.itemName,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.dateAdded, // Add this line
  });
}

@Collection()
class SaleTransaction {
  Id id = Isar.autoIncrement;

  final String itemName;
  final String category;
  final int quantitySold;
  final double totalSaleAmount;
  final DateTime date;

  SaleTransaction({
    required this.itemName,
    required this.category,
    required this.quantitySold,
    required this.totalSaleAmount,
    required this.date,
  });
}

@Collection()
class Report {
  Id id = Isar.autoIncrement;

  late DateTime date;
  late double totalSales;
  late double totalProfits;
  late double totalInventory;
  late int totalQuantitySold;
  late double totalStockValue;
  late int lowStockAlert;
  late double salesGrowth;
  late double profitMargin;

  Report({
    required this.date,
    required this.totalSales,
    required this.totalProfits,
    required this.totalInventory,
    required this.totalQuantitySold,
    required this.totalStockValue,
    required this.lowStockAlert,
    required this.salesGrowth,
    required this.profitMargin,
  });
}

@Collection()
class DailyStats {
  Id id = Isar.autoIncrement;
  late DateTime date;
  late double totalSales;
  late double totalProfit;
  late int totalQuantitySold;
}

@Collection()
class WeeklyStats {
  Id id = Isar.autoIncrement;
  late DateTime startOfWeek;
  late double totalSales;
  late double totalProfit;
  late int totalQuantitySold;
}

@Collection()
class MonthlyStats {
  Id id = Isar.autoIncrement;
  late DateTime month;
  late double totalSales;
  late double totalProfit;
  late int totalQuantitySold;
}
