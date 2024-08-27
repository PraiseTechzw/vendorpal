import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:vendorpal/databases/database.dart';
import 'package:vendorpal/main.dart';
import 'package:vendorpal/modals/packages.dart';
import 'package:vendorpal/widget/home/barchart.dart';
import 'package:vendorpal/widget/home/first_time_user.dart';
import 'package:vendorpal/widget/home/low_stock_items_widget.dart';
import 'package:vendorpal/widget/home/mydarwer.dart';
import 'package:vendorpal/widget/home/sales_focust.dart';
import 'package:vendorpal/widget/home/sales_overview_widget.dart';
import 'package:vendorpal/widget/home/stock_overview_widget.dart';
import 'package:vendorpal/widget/home/pie_chart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoading = true;
  double _totalSales = 0.0;
  int _totalStock = 0;
  int _lastMonthStock = 0;
  int _currentMonthStock = 0;
  int _yearToDateStock = 0;
  List<StockItem> _lowStockItems = [];

  double _dailySales = 0.0;
  double _weeklySales = 0.0;
  double _monthlySales = 0.0;
  double _dailyProfits = 0.0;
  double _weeklyProfits = 0.0;
  double _monthlyProfits = 0.0;
  int _dailyQuantitySold = 0;
  int _weeklyQuantitySold = 0;
  int _monthlyQuantitySold = 0;
  late IsarService _isarService;

  late PageController _salesPageController;
  late PageController _stockPageController;
  late PageController _forecastPageController;

  @override
  void initState() {
    super.initState();
    _isarService = IsarService(); // Initialize your Isar service here

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _salesPageController =
        PageController(viewportFraction: 0.8, initialPage: 0);
    _stockPageController =
        PageController(viewportFraction: 0.8, initialPage: 0);
    _forecastPageController =
        PageController(viewportFraction: 0.8, initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
    _autoScrollCarousel(_salesPageController, 3);
    _autoScrollCarousel(_stockPageController, 5);
    _autoScrollCarousel(_forecastPageController, 3);
  }

  void _autoScrollCarousel(PageController controller, int itemCount) {
    Future.delayed(const Duration(seconds: 3), () {
      if (controller.hasClients) {
        int currentPage = controller.page?.round() ?? 0;
        int nextPage = (currentPage + 1) % itemCount;
        controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        _autoScrollCarousel(controller, itemCount);
      }
    });
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Future.wait([
        _fetchTotalSales(),
        _fetchTotalProfits(),
        _fetchTotalStock(),
        _fetchTotalQuantitySold(),
        _fetchLastMonthStock(),
        _fetchCurrentMonthStock(),
        _fetchYearToDateStock(),
        _fetchLowStockItems(),
        _fetchDailySales(),
        _fetchWeeklySales(),
        _fetchMonthlySales(),
        _fetchDailyProfits(),
        _fetchWeeklyProfits(),
        _fetchMonthlyProfits(),
        _fetchDailyQuantitySold(),
        _fetchWeeklyQuantitySold(),
        _fetchMonthlyQuantitySold(),
      ]);
      setState(() {
        _isLoading = false;
      });
      _controller.forward();
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> _fetchDailySales() async {
    _dailySales = await _isarService.getTotalProfitForToday();
  }

  Future<void> _fetchWeeklySales() async {
    _weeklySales =
        await _isarService.getTotalSalesForWeek(); // Corrected method name
  }

  Future<void> _fetchMonthlySales() async {
    final DateTime now = DateTime.now();
    final int year = now.year;
    final int month = now.month;

    _monthlySales = await _isarService.getTotalSalesForMonth(year, month);
  }

  Future<void> _fetchDailyProfits() async {
    _dailyProfits = await _isarService.getTotalProfitForToday();
  }

  Future<void> _fetchWeeklyProfits() async {
    _weeklyProfits =
        await _isarService.getTotalProfitForWeek(); // Corrected method name
  }

  Future<void> _fetchMonthlyProfits() async {
    _monthlyProfits =
        await _isarService.getTotalProfitForMonth(); // Corrected method name
  }

  Future<void> _fetchDailyQuantitySold() async {
    _dailyQuantitySold = await _isarService
        .getTotalQuantitySoldForToday(); // Corrected method name
  }

  Future<void> _fetchWeeklyQuantitySold() async {
    _weeklyQuantitySold = await _isarService
        .getTotalQuantitySoldForWeek(); // Corrected method name
  }

  Future<void> _fetchMonthlyQuantitySold() async {
    _monthlyQuantitySold = await _isarService
        .getTotalQuantitySoldForMonth(); // Corrected method name
  }

  Future<void> _fetchTotalSales() async {
    _totalSales = await _isarService.getTotalSales();
  }

  Future<void> _fetchTotalProfits() async {}

  Future<void> _fetchTotalStock() async {
    _totalStock = await _isarService.getTotalStock();
  }

  Future<void> _fetchTotalQuantitySold() async {}

  Future<void> _fetchLastMonthStock() async {
    _lastMonthStock = await _isarService.getLastMonthStock();
  }

  Future<void> _fetchCurrentMonthStock() async {
    _currentMonthStock = await _isarService.getCurrentMonthStock();
  }

  Future<void> _fetchYearToDateStock() async {
    _yearToDateStock = await _isarService.getYearToDateStock();
  }

  Future<void> _fetchLowStockItems() async {
    _lowStockItems = await _isarService.getLowStockItems(5);

    if (_lowStockItems.isNotEmpty) {
      await _showLowStockNotification();
    }
  }

  Future<void> _showLowStockNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'low_stock_channel',
      'Low Stock Notifications',
      channelDescription: 'Notification channel for low stock items',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Low Stock Alert',
      'You have ${_lowStockItems.length} low stock items.',
      notificationDetails,
    );
  }

  Future<void> _onRefresh() async {
    await _fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _salesPageController.dispose();
    _stockPageController.dispose();
    _forecastPageController.dispose();
    super.dispose();
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 150.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.blue,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('VendorPal Dashboard'),
        background: Lottie.asset(
          'assets/animations/dashboard.json',
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FadeTransition(
          opacity: _controller,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoading
                      ? Center(
                          child: Lottie.asset(
                            'assets/animations/loading.json',
                            width: 150,
                            height: 150,
                          ),
                        )
                      : _totalSales == 0 && _totalStock == 0
                          ? FirstTimeUserPrompt()
                          // ignore: prefer_const_constructors
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SalesOverview(
                                  salesPageController: _salesPageController,
                                  dailySales:
                                      _dailySales, // Use the fetched daily sales value
                                  weeklySales:
                                      _weeklySales, // Use the fetched weekly sales value
                                  monthlySales:
                                      _monthlySales, // Use the fetched monthly sales value
                                  dailyProfits:
                                      _dailyProfits, // Use the fetched daily profits value
                                  weeklyProfits:
                                      _weeklyProfits, // Use the fetched weekly profits value
                                  monthlyProfits:
                                      _monthlyProfits, // Use the fetched monthly profits value
                                  dailyQuantitySold:
                                      _dailyQuantitySold, // Use the fetched daily quantity sold value
                                  weeklyQuantitySold:
                                      _weeklyQuantitySold, // Use the fetched weekly quantity sold value
                                  monthlyQuantitySold:
                                      _monthlyQuantitySold, // Use the fetched monthly quantity sold value
                                ),
                                const SizedBox(height: 32),
                                BarChartWidget(
                                  weeklySalesFuture:
                                      _isarService.getWeeklySales(),
                                ),
                                const SizedBox(height: 32),
                                StockOverview(
                                  stockPageController: _stockPageController,
                                  totalStock: _totalStock,
                                  lowStockItemsCount: _lowStockItems.length,
                                  lastMonthStock: _lastMonthStock,
                                  currentMonthStock: _currentMonthStock,
                                  yearToDateStock: _yearToDateStock,
                                ),
                                const SizedBox(height: 32),
                                PieChartWidget(
                                  salesDistributionFuture:
                                      _isarService.getSalesDistribution(),
                                ),
                                const SizedBox(height: 32),
                                SalesForecast(
                                  isarService: IsarService(),
                                ),
                                const SizedBox(height: 32),
                                LowStockItems(lowStockItems: _lowStockItems),
                              ],
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
