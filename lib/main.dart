import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mess_management/provider/attendance_provider.dart';
import 'package:mess_management/provider/profile_provider.dart';
import 'package:mess_management/views/main_section/main_section.dart';
import 'package:mess_management/provider/attendance_provider.dart';
import 'package:mess_management/provider/profile_provider.dart';
import 'package:mess_management/views/main_section/main_section.dart';
import 'package:provider/provider.dart';

import 'provider/auth_provider.dart';
import 'provider/expense_provider.dart';
import 'provider/member_provider.dart';
import 'provider/payment_provider.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_page.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
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
      ],
      child: MaterialApp(
        title: 'Mess Management',
        theme: AppTheme.darkTheme,
        home: const LoginPage(),
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
