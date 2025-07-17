import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:vendorpal/databases/database.dart';
import 'package:vendorpal/constants/business_type_store.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:vendorpal/widget/product_form_widget.dart';
import 'package:vendorpal/modals/packages.dart';
import 'package:vendorpal/main.dart';

// --- Dashboard Overlay System ---
// Extend DashboardOverlayData for priority and actions
class DashboardOverlayData {
  final String type; // 'tip', 'achievement', 'alert', 'help', 'info', 'critical', 'important'
  final String message;
  final IconData icon;
  final Color color;
  final int priority; // 0=info, 1=important, 2=critical
  final List<DashboardOverlayAction>? actions;
  DashboardOverlayData({
    required this.type,
    required this.message,
    required this.icon,
    required this.color,
    this.priority = 0,
    this.actions,
  });
}

class DashboardOverlayAction {
  final String label;
  final VoidCallback onPressed;
  DashboardOverlayAction({required this.label, required this.onPressed});
}

// Upgrade DashboardOverlay to support actions and snooze
class DashboardOverlay extends StatefulWidget {
  final DashboardOverlayData data;
  final VoidCallback onClose;
  final VoidCallback? onSnooze;
  const DashboardOverlay({required this.data, required this.onClose, this.onSnooze, Key? key}) : super(key: key);
  @override
  State<DashboardOverlay> createState() => _DashboardOverlayState();
}

class _DashboardOverlayState extends State<DashboardOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnim = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    // Auto-dismiss for info/achievement
    if (widget.data.type == 'alert' || widget.data.type == 'achievement' || widget.data.type == 'info') {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) widget.onClose();
      });
    }
  }
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: widget.data.color.withOpacity(0.97),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  if (widget.data.type == 'achievement')
                    Lottie.asset('assets/animations/empty_state.json', width: 48, height: 48, repeat: false)
                  else
                    Icon(widget.data.icon, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.message,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (widget.data.actions != null)
                          Row(
                            children: widget.data.actions!.map((action) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)),
                                onPressed: action.onPressed,
                                child: Text(action.label),
                              ),
                            )).toList(),
                          ),
                      ],
                    ),
                  ),
                  if (widget.onSnooze != null)
                    IconButton(
                      icon: const Icon(Icons.snooze, color: Colors.white),
                      tooltip: 'Snooze',
                      onPressed: widget.onSnooze,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// --- End Dashboard Overlay System ---

// --- Modern Card Style Helper ---
BoxDecoration modernCardDecoration({required Color color, double borderRadius = 22}) => BoxDecoration(
  gradient: LinearGradient(
    colors: [Colors.white.withOpacity(0.85), color.withOpacity(0.10)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.circular(borderRadius),
  boxShadow: [
    BoxShadow(
      color: color.withOpacity(0.10),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ],
  border: Border.all(color: color.withOpacity(0.13), width: 1.2),
);

// --- Update Primary Metric Card ---
class _PrimaryMetricCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final String? subLabel;
  final Color? subLabelColor;
  final double? progress;
  const _PrimaryMetricCard({required this.label, required this.value, required this.icon, required this.color, this.subLabel, this.subLabelColor, this.progress});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        decoration: modernCardDecoration(color: color, borderRadius: 22),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value.toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
            if (progress != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: LinearPercentIndicator(
                  lineHeight: 6,
                  percent: progress!.clamp(0.0, 1.0),
                  backgroundColor: color.withOpacity(0.15),
                  progressColor: color,
                  barRadius: const Radius.circular(8),
                ),
              ),
            if (subLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(subLabel!, style: TextStyle(fontSize: 11, color: subLabelColor ?? Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }
}
// --- Update Secondary Metric Card ---
class _SecondaryMetricCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final String? subLabel;
  const _SecondaryMetricCard({required this.label, required this.value, required this.icon, required this.color, this.subLabel});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: modernCardDecoration(color: color, borderRadius: 18),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                Text(value.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
                if (subLabel != null)
                  Text(subLabel!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class DashboardHeader extends StatelessWidget {
  final String businessName;
  final String businessTypeName;
  final Color brandingColor;
  final String greeting;
  final DateTime now;
  final int notificationCount;
  final VoidCallback onNotificationTap;
  const DashboardHeader({
    required this.businessName,
    required this.businessTypeName,
    required this.brandingColor,
    required this.greeting,
    required this.now,
    required this.notificationCount,
    required this.onNotificationTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d').format(now);
    final timeStr = DateFormat('h:mm a').format(now);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: brandingColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: brandingColor.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding and greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  businessTypeName,
                  style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(dateStr, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(width: 14),
                    Icon(Icons.access_time, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(timeStr, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          // Notification bell with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: onNotificationTap,
                tooltip: 'Notifications',
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
            tooltip: 'Settings',
          ),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: brandingColor),
            radius: 18,
          ),
        ],
      ),
    );
  }
}
// --- End Dashboard Overlay System ---

// --- HomeScreen Main Widget ---
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoading = true;
  int _totalStock = 0;
  int _lastMonthStock = 0;
  int _currentMonthStock = 0;
  int _yearToDateStock = 0;
  List<StockItem> _lowStockItems = [];

  late IsarService _isarService;

  bool _showOverlay = true;
  List<DashboardOverlayData> _notifications = [
    DashboardOverlayData(type: 'tip', message: 'Tip: Add your first sale!', icon: Icons.lightbulb, color: Colors.deepPurpleAccent),
    DashboardOverlayData(type: 'achievement', message: 'Congrats! 100 sales!', icon: Icons.emoji_events, color: Colors.amber),
    DashboardOverlayData(type: 'alert', message: 'Low stock: Premium Rice', icon: Icons.warning, color: Colors.redAccent),
    DashboardOverlayData(type: 'help', message: 'Need help? Tap the ? icon.', icon: Icons.help, color: Colors.blueAccent),
  ];

  @override
  void initState() {
    super.initState();
    _isarService = IsarService();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Future.wait([
        _fetchTotalStock(),
        _fetchLastMonthStock(),
        _fetchCurrentMonthStock(),
        _fetchYearToDateStock(),
        _fetchLowStockItems(),
      ]);
      setState(() {
        _isLoading = false;
      });
      _controller.forward();
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> _fetchTotalStock() async {
    _totalStock = await _isarService.getTotalStock();
  }
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
  void _showNotificationCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NotificationCenterSheet(
        notifications: _notifications,
        onDismiss: (index) => setState(() => _notifications.removeAt(index)),
        onSnooze: (index) {
          setState(() {
            final snoozed = _notifications.removeAt(index);
            _notifications.add(snoozed);
          });
        },
      ),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: Replace mock data with real data from your database/services
    // --- Performance Summary Section ---
    // Mock data for all metrics
    final todayRevenue = 120.50;
    final revenueChange = 0.12; // +12%
    final itemsSold = 34;
    final itemsSoldGoal = 50;
    final grossProfit = 45.20;
    final profitMargin = 0.38; // 38%
    final transactions = 18;
    final avgSale = todayRevenue / transactions;
    final bestSelling = 'Premium Rice';
    final bestSellingQty = 12;
    final paymentMethods = {'Cash': 0.6, 'Digital': 0.4};
    final hourlyPerformance = [4, 6, 8, 10, 6, 0, 0, 0]; // Mock hourly sales
    // --- End Performance Summary Section ---
    final todayStats = {
      'sales': 120.50, // TODO: Get real sales
      'profit': 45.20, // TODO: Get real profit
      'expenses': 30.00, // TODO: Get real expenses
    };
    final recentActivity = [
      {'type': 'sale', 'desc': 'Sold 2x Premium Rice', 'time': '09:30 AM'},
      {'type': 'stock', 'desc': 'Restocked 10x Blue Denim Jeans', 'time': '08:50 AM'},
      {'type': 'expense', 'desc': 'Paid rent', 'time': '08:00 AM'},
    ];
    // Mock business type and name for now
    final businessName = 'Praise Mart';
    final businessTypeName = 'Groceries & Kiosk';
    final brandingColor = Colors.deepPurpleAccent; // Use business type color in future
    final greeting = 'Good morning, $businessName';
    final now = DateTime.now();
    // --- Business-Type-Specific Widgets Section ---
    // This section renders widgets based on the selected business type.
    Widget _buildBusinessTypeWidgets() {
      // Use the global selectedBusinessType from business_type_store.dart
      final type = selectedBusinessType;
      if (type == null) {
        return const SizedBox.shrink();
      }
      switch (type.id) {
        case 'groceries':
          return _GroceriesWidgets();
        case 'clothing':
          return _ClothingWidgets();
        // Add more cases for other business types as needed
        default:
          return const SizedBox.shrink();
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_isLoading)
            // --- Loading State ---
            const Center(child: CircularProgressIndicator()),
          if (!_isLoading && _totalStock == 0)
            // --- Empty State ---
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.inbox, size: 64, color: Colors.deepPurpleAccent),
                  SizedBox(height: 18),
                  Text('No data yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Add your first product or sale to get started!', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          if (!_isLoading && _totalStock > 0)
            // --- Main Dashboard Content ---
            SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DashboardHeader(
                          businessName: businessName,
                          businessTypeName: businessTypeName,
                          brandingColor: brandingColor,
                          greeting: greeting,
                          now: now,
                          notificationCount: _notifications.length,
                          onNotificationTap: _showNotificationCenter,
                        ),
                        // --- Modern Dashboard Summary: Stock, Sales, Expenses ---
                        const SizedBox(height: 8),
                        _ModernSummaryRow(
                          stock: _totalStock,
                          sales: todayRevenue,
                          expenses: todayStats['expenses'] ?? 0.0,
                        ),
                        const SizedBox(height: 24),
                        // --- Primary Metrics ---
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 500;
                            return isNarrow
                                ? Column(
                                    children: [
                                      _PrimaryMetricCard(
                                        label: "Today's Revenue",
                                        value: todayRevenue,
                                        icon: Icons.attach_money,
                                        color: Colors.green,
                                        subLabel: revenueChange > 0 ? '+${(revenueChange * 100).toStringAsFixed(1)}%' : '${(revenueChange * 100).toStringAsFixed(1)}%',
                                        subLabelColor: revenueChange > 0 ? Colors.green : Colors.red,
                                      ),
                                      _PrimaryMetricCard(
                                        label: 'Items Sold',
                                        value: itemsSold.toDouble(),
                                        icon: Icons.shopping_bag,
                                        color: Colors.blue,
                                        progress: itemsSold / itemsSoldGoal,
                                        subLabel: '$itemsSoldGoal goal',
                                        subLabelColor: Colors.blue,
                                      ),
                                      _PrimaryMetricCard(
                                        label: 'Gross Profit',
                                        value: grossProfit,
                                        icon: Icons.trending_up,
                                        color: Colors.purple,
                                        subLabel: '${(profitMargin * 100).toStringAsFixed(0)}% margin',
                                        subLabelColor: Colors.purple,
                                      ),
                                      _PrimaryMetricCard(
                                        label: 'Transactions',
                                        value: transactions.toDouble(),
                                        icon: Icons.receipt_long,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: _PrimaryMetricCard(
                                        label: "Today's Revenue",
                                        value: todayRevenue,
                                        icon: Icons.attach_money,
                                        color: Colors.green,
                                        subLabel: revenueChange > 0 ? '+${(revenueChange * 100).toStringAsFixed(1)}%' : '${(revenueChange * 100).toStringAsFixed(1)}%',
                                        subLabelColor: revenueChange > 0 ? Colors.green : Colors.red,
                                      )),
                                      const SizedBox(width: 8),
                                      Expanded(child: _PrimaryMetricCard(
                                        label: 'Items Sold',
                                        value: itemsSold.toDouble(),
                                        icon: Icons.shopping_bag,
                                        color: Colors.blue,
                                        progress: itemsSold / itemsSoldGoal,
                                        subLabel: '$itemsSoldGoal goal',
                                        subLabelColor: Colors.blue,
                                      )),
                                      const SizedBox(width: 8),
                                      Expanded(child: _PrimaryMetricCard(
                                        label: 'Gross Profit',
                                        value: grossProfit,
                                        icon: Icons.trending_up,
                                        color: Colors.purple,
                                        subLabel: '${(profitMargin * 100).toStringAsFixed(0)}% margin',
                                        subLabelColor: Colors.purple,
                                      )),
                                      const SizedBox(width: 8),
                                      Expanded(child: _PrimaryMetricCard(
                                        label: 'Transactions',
                                        value: transactions.toDouble(),
                                        icon: Icons.receipt_long,
                                        color: Colors.orange,
                                      )),
                                    ],
                                  );
                          },
                        ),
                        const SizedBox(height: 18),
                        // --- Secondary Metrics ---
                        LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = constraints.maxWidth < 500 ? 1 : 2;
                            return GridView.count(
                              crossAxisCount: crossAxisCount,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 2.6,
                              children: [
                                _SecondaryMetricCard(
                                  label: 'Average Sale',
                                  value: avgSale,
                                  icon: Icons.calculate,
                                  color: Colors.teal,
                                ),
                                _SecondaryMetricCard(
                                  label: 'Best Selling',
                                  value: bestSellingQty.toDouble(),
                                  icon: Icons.star,
                                  color: Colors.amber,
                                  subLabel: bestSelling,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const SizedBox(height: 14),
                        const SizedBox(height: 24),
                        // --- Business-Type-Specific Widgets ---
                        _buildBusinessTypeWidgets(),
                        const SizedBox(height: 24),
                        // --- Smart Analytics Panel ---
                        _SmartAnalyticsPanel(),
                        const SizedBox(height: 24),
                        // Recent Activity
                        const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis, maxLines: 1),
                        const SizedBox(height: 10),
                        ...recentActivity.map((item) => Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Icon(
                              item['type'] == 'sale' ? Icons.sell : item['type'] == 'stock' ? Icons.inventory : Icons.money_off,
                              color: item['type'] == 'sale' ? Colors.deepPurpleAccent : item['type'] == 'stock' ? Colors.green : Colors.orange,
                            ),
                            title: Text(item['desc']!, overflow: TextOverflow.ellipsis, maxLines: 1),
                            subtitle: Text(item['time']!, overflow: TextOverflow.ellipsis, maxLines: 1),
                          ),
                        )),
                        // Add more sections as needed
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Contextual overlay (tip/alert/achievement/help)
          if (_notifications.isNotEmpty)
            DashboardOverlay(
              data: _notifications.first,
              onClose: () => setState(() => _notifications.removeAt(0)),
            ),
        ],
      ),
    );
  }
}

// --- Update Secondary Action Icon ---
class _SecondaryActionIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SecondaryActionIcon({required this.label, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: modernCardDecoration(color: color, borderRadius: 14),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderSheet extends StatelessWidget {
  final String title;
  const _PlaceholderSheet({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class NotificationCenterSheet extends StatelessWidget {
  final List<DashboardOverlayData> notifications;
  final void Function(int) onDismiss;
  final void Function(int) onSnooze;
  const NotificationCenterSheet({required this.notifications, required this.onDismiss, required this.onSnooze});
  @override
  Widget build(BuildContext context) {
    final sorted = [...notifications]..sort((a, b) => b.priority.compareTo(a.priority));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const Divider(height: 18),
                itemBuilder: (context, i) {
                  final n = sorted[i];
                  return Card(
                    color: n.color.withOpacity(0.13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Icon(n.icon, color: n.color, size: 28),
                      title: Text(n.message, style: TextStyle(fontWeight: FontWeight.bold, color: n.color)),
                      subtitle: n.type == 'critical'
                          ? const Text('Critical', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600))
                          : n.type == 'important'
                              ? const Text('Important', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600))
                              : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (n.actions != null)
                            ...n.actions!.map((action) => Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: n.color, side: BorderSide(color: n.color.withOpacity(0.3))),
                                    onPressed: action.onPressed,
                                    child: Text(action.label),
                                  ),
                                )),
                          IconButton(
                            icon: const Icon(Icons.snooze, color: Colors.grey),
                            tooltip: 'Snooze',
                            onPressed: () => onSnooze(i),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            tooltip: 'Dismiss',
                            onPressed: () => onDismiss(i),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Modular Widgets for Each Business Type ---
/// Example: Groceries & Kiosk Widgets
class _GroceriesWidgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          decoration: modernCardDecoration(color: Colors.deepPurpleAccent, borderRadius: 18),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.warning, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Low Stock Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 8),
              ...['Premium Rice', 'Cooking Oil', 'Sugar'].map((item) => ListTile(
                    leading: const Icon(Icons.local_grocery_store, color: Colors.deepPurpleAccent),
                    title: Text(item),
                    subtitle: const Text('Only 3 left!'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example: Boutique & Clothing Widgets
class _ClothingWidgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          decoration: modernCardDecoration(color: Colors.pinkAccent, borderRadius: 18),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.checkroom, color: Colors.pinkAccent),
                  SizedBox(width: 8),
                  Text('Top Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 8),
              ...['Tops', 'Dresses', 'Shoes'].map((cat) => ListTile(
                    leading: const Icon(Icons.category, color: Colors.deepPurpleAccent),
                    title: Text(cat),
                    subtitle: const Text('Best sellers this week'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Modern Summary Row Widget ---
class _ModernSummaryRow extends StatelessWidget {
  final int stock;
  final double sales;
  final double expenses;
  const _ModernSummaryRow({required this.stock, required this.sales, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final cardGradient = LinearGradient(
      colors: [Colors.white.withOpacity(0.7), Colors.deepPurpleAccent.withOpacity(0.13)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedSlide(
          offset: const Offset(-0.2, 0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 600),
            child: _SummaryCard(
              label: 'Stock',
              value: stock.toString(),
              icon: Icons.inventory_2,
              color: Colors.blueAccent,
              gradient: cardGradient,
              secondary: 'In store',
              semanticLabel: 'Stock in store: $stock',
            ),
          ),
        ),
        AnimatedSlide(
          offset: const Offset(0, 0.2),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 700),
            child: _SummaryCard(
              label: 'Sales',
              value: sales.toStringAsFixed(2),
              icon: Icons.attach_money,
              color: Colors.green,
              gradient: cardGradient,
              secondary: 'Today',
              semanticLabel: 'Sales today: $sales',
            ),
          ),
        ),
        AnimatedSlide(
          offset: const Offset(0.2, 0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 800),
            child: _SummaryCard(
              label: 'Expenses',
              value: expenses.toStringAsFixed(2),
              icon: Icons.money_off,
              color: Colors.redAccent,
              gradient: cardGradient,
              secondary: 'Today',
              semanticLabel: 'Expenses today: $expenses',
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final String secondary;
  final String? semanticLabel;
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color, required this.gradient, required this.secondary, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? label,
      child: Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.13), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: color)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(secondary, style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Animate Analytics Panel ---
class _SmartAnalyticsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mock sales trend data
    final List<double> salesTrend = [120, 140, 110, 180, 160, 200, 170];
    final String bestSelling = 'Premium Rice';
    final String topCategory = 'Staples';
    final String insight = 'Sales peak on Fridays. Consider special offers!';
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 900),
      child: Semantics(
        label: 'Smart Analytics Panel. Best seller: $bestSelling. Top category: $topCategory.',
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Container(
            decoration: modernCardDecoration(color: Colors.deepPurple, borderRadius: 22),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.analytics, color: Colors.deepPurpleAccent, size: 28),
                    SizedBox(width: 10),
                    Text('Smart Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                // --- Sales Trend Chart (mock, simple bar chart) ---
                SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: salesTrend.map((v) {
                      final max = salesTrend.reduce((a, b) => a > b ? a : b);
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 60 * (v / (max + 0.01)),
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AnalyticsStat(
                      icon: Icons.star,
                      label: 'Best Seller',
                      value: bestSelling,
                      color: Colors.amber,
                    ),
                    _AnalyticsStat(
                      icon: Icons.category,
                      label: 'Top Category',
                      value: topCategory,
                      color: Colors.blueAccent,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb, color: Colors.green, size: 20),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                insight,
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _AnalyticsStat({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
