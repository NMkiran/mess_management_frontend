import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mess_management/core/constants/app_constants.dart';
import 'package:mess_management/core/services/navigation_service.dart';
import 'package:mess_management/core/services/notification_service.dart';
import 'package:mess_management/provider/attendance_provider.dart';
import 'package:mess_management/provider/expense_provider.dart';
import 'package:mess_management/provider/expenses_provider.dart';
import 'package:mess_management/provider/history_provider.dart';
import 'package:mess_management/provider/profile_provider.dart';
import 'package:mess_management/views/main_section/main_section.dart';
import 'package:provider/provider.dart';

import 'provider/auth_provider.dart';
import 'provider/member_provider.dart';
import 'provider/payment_provider.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_page.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive
    await Hive.initFlutter();

    // Initialize Notification Service
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Schedule 10 AM mess alarm
    await notificationService.scheduleMessAlarm(
      hour: 14,
      minute: 24,
      title: 'Mess Time',
      body: 'It\'s 10:00 AM! Time for mess.',
    );

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Failed to initialize app: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => MainSectionProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ExpensesProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        navigatorKey: NavigationService.navigatorKey,
        theme: AppTheme.darkTheme,
        initialRoute: AppConstants.loginRoute,
        routes: {
          AppConstants.loginRoute: (context) => const LoginPage(),
          AppConstants.homeRoute: (context) => const MainSection(),
          // TODO: Add other routes here
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
