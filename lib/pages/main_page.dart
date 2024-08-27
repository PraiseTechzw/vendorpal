import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:vendorpal/main.dart';
import 'package:vendorpal/pages/home_screen.dart';
import 'package:vendorpal/pages/report/reports.dart';
import 'package:vendorpal/pages/sales_screen.dart';
import 'package:vendorpal/pages/stocks/stock_screen.dart';
import 'package:vendorpal/themes/theme.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    const StockScreen(),
    const SalesScreen(),
    const ReportScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: Container(
          color: themeNotifier.isDarkMode
              ? AppColors.darkPrimaryColor
              : Colors.deepPurpleAccent,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: themeNotifier.isDarkMode
                  ? AppColors.darkAccentColor
                  : AppColors.lightAccentColor,
              iconSize: 28,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: themeNotifier.isDarkMode
                  ? AppColors.darkSecondaryColor.withOpacity(0.1)
                  : AppColors.lightSecondaryColor.withOpacity(0.1),
              color: Colors.grey[600],
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                  iconColor: Colors.blue,
                  textStyle: TextStyle(color: Colors.blue),
                ),
                GButton(
                  icon: Icons.inventory,
                  text: 'Stock',
                  iconColor: Colors.green,
                  textStyle: TextStyle(color: Colors.green),
                ),
                GButton(
                  icon: Icons.sell,
                  text: 'Sales',
                  iconColor: Colors.red,
                  textStyle: TextStyle(color: Colors.red),
                ),
                GButton(
                  icon: Icons.bar_chart,
                  text: 'Reports',
                  iconColor: Colors.purple,
                  textStyle: TextStyle(color: Colors.purple),
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
