import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vendorpal/databases/database.dart';
import 'package:vendorpal/pages/main_page.dart';
import 'package:vendorpal/themes/theme.dart';
import 'package:vendorpal/constants/business_type_store.dart';
import 'package:vendorpal/modals/business_type.dart';
import 'package:vendorpal/widget/home/first_time_user.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Isar database
  final isarService = IsarService();
  await isarService.initializeDB();

  // Load business type selection before app starts
  await loadSelectedBusinessType(businessTypes);

  // Initialize notifications
  await initializeNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: VendorPalApp(isarService: isarService),
    ),
  );
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Use default launcher icon

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Handle the notification response
      final payload = response.payload;
      if (payload != null) {
        final file = File(payload);
        if (await file.exists()) {
          await OpenFile.open(payload);
        } else {
          // Handle file not found
          print('File not found: $payload');
        }
      }
    },
  );
}

class VendorPalApp extends StatefulWidget {
  final IsarService isarService;

  const VendorPalApp({Key? key, required this.isarService}) : super(key: key);

  @override
  State<VendorPalApp> createState() => _VendorPalAppState();
}

class _VendorPalAppState extends State<VendorPalApp> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return ChangeNotifierProvider.value(
      value: widget.isarService,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VendorPal',
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: FutureBuilder<bool>(
          future: isOnboardingComplete(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return snapshot.data == false
                ? FirstTimeUserPrompt()
                : MainScreen();
          },
        ),
      ),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  bool isDarkMode = false;
  bool isAutoTheme = false;

  void toggleTheme(bool isDark) {
    isDarkMode = isDark;
    notifyListeners();
  }

  void toggleAutoTheme(bool isAuto) {
    isAutoTheme = isAuto;
    if (isAuto) {
      // Automatically toggle dark mode based on the system's dark mode setting
      isDarkMode =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
    } else {
      // Set dark mode to the last manually selected value
      isDarkMode = false; // or true, depending on your default value
    }
    notifyListeners();
  }
}
