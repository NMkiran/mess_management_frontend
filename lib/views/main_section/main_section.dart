import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'attendance/attendance_screen.dart';
import 'history/history_screen.dart';
// Tab screens
import 'home/home_screen.dart';
import 'members/members_screen.dart';
import 'profile/profile_screen.dart';

class MainSectionProvider extends ChangeNotifier {
  static const String _boxName = 'mainSection';
  static const String _currentIndexKey = 'currentIndex';

  Box? _box;
  int _currentIndex = 0;

  MainSectionProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      _box = await Hive.openBox(_boxName);
      _currentIndex = _box?.get(_currentIndexKey, defaultValue: 0) ?? 0;
      notifyListeners();
    } catch (e) {
      print('Error initializing Hive: $e');
      // Default to index 0 if there's an error
      _currentIndex = 0;
    }
  }

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    try {
      _box?.put(_currentIndexKey, index);
    } catch (e) {
      print('Error saving index to Hive: $e');
    }
    notifyListeners();
  }
}

class MainSection extends StatelessWidget {
  const MainSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainSectionView();
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
              // MemberProfileScreen(),

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
