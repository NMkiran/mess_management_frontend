import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Tab screens
import 'home/home_screen.dart';
import 'attendance/attendance_screen.dart';
import 'history/history_screen.dart';
import 'profile/profile_screen.dart';
import 'members/members_screen.dart';

// Providers
import '../../../provider/attendance_provider.dart';
import '../../../provider/member_provider.dart';
import '../../../provider/expense_provider.dart';
import '../../../provider/payment_provider.dart';
import '../../../provider/profile_provider.dart';

class MainSectionProvider extends ChangeNotifier {
  static const String _boxName = 'mainSection';
  static const String _currentIndexKey = 'currentIndex';

  late final Box _box;
  int _currentIndex = 0;

  MainSectionProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    _box = await Hive.openBox(_boxName);
    _currentIndex = _box.get(_currentIndexKey, defaultValue: 0);
    notifyListeners();
  }

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    _box.put(_currentIndexKey, index);
    notifyListeners();
  }
}

class MainSection extends StatelessWidget {
  const MainSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainSectionProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MainSectionView(),
    );
  }
}

class MainSectionView extends StatelessWidget {
  const MainSectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MainSectionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: IndexedStack(
            index: provider.currentIndex,
            children: const [
              HomeScreen(),
              AttendanceScreen(),
              MembersScreen(),
              HistoryScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: provider.currentIndex,
            onTap: provider.setIndex,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Members',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
