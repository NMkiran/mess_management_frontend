import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance_record_model.dart';
import '../utilities/dummy_data.dart';
import 'package:uuid/uuid.dart';

class AttendanceProvider extends ChangeNotifier {
  static const String _boxName = 'attendance';
  late final Box _box;

  int _totalMembers = 0;
  int _breakfastCount = 0;
  int _lunchCount = 0;
  int _dinnerCount = 0;
  List<AttendanceRecordModel> _attendanceRecords = [];

  AttendanceProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    _box = await Hive.openBox(_boxName);
    await _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month}-${now.day}';

    _totalMembers = _box.get('totalMembers', defaultValue: 5);
    _breakfastCount = _box.get('${dateKey}_breakfast', defaultValue: 0);
    _lunchCount = _box.get('${dateKey}_lunch', defaultValue: 0);
    _dinnerCount = _box.get('${dateKey}_dinner', defaultValue: 0);

    final List<dynamic> records =
        _box.get('attendance_records', defaultValue: []);
    if (records.isEmpty) {
      // Load dummy data if no data exists
      _attendanceRecords = DummyData.getSampleAttendanceRecords();
      await _box.put('attendance_records',
          _attendanceRecords.map((r) => r.toJson()).toList());

      // Update meal counts based on today's dummy records
      final todayRecords = getAttendanceByDate(DateTime.now());
      _breakfastCount = todayRecords.where((r) => r.breakfast).length;
      _lunchCount = todayRecords.where((r) => r.lunch).length;
      _dinnerCount = todayRecords.where((r) => r.dinner).length;

      await _box.put('${dateKey}_breakfast', _breakfastCount);
      await _box.put('${dateKey}_lunch', _lunchCount);
      await _box.put('${dateKey}_dinner', _dinnerCount);
    } else {
      _attendanceRecords = records
          .map((json) =>
              AttendanceRecordModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    notifyListeners();
  }

  // Getters
  int get totalMembers => _totalMembers;
  int get breakfastCount => _breakfastCount;
  int get lunchCount => _lunchCount;
  int get dinnerCount => _dinnerCount;
  int get absentMembers => _totalMembers - _getMaxAttendance();
  List<AttendanceRecordModel> get attendanceRecords => _attendanceRecords;

  List<AttendanceRecordModel> getAttendanceByDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return _attendanceRecords.where((record) {
      final recordDate = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      return recordDate.isAtSameMomentAs(day);
    }).toList();
  }

  int _getMaxAttendance() {
    return [_breakfastCount, _lunchCount, _dinnerCount]
        .reduce((max, count) => count > max ? count : max);
  }

  String getCurrentMealPeriod() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 11) {
      return 'breakfast';
    } else if (hour >= 11 && hour < 16) {
      return 'lunch';
    } else {
      return 'dinner';
    }
  }

  int getCurrentMealAttendance() {
    switch (getCurrentMealPeriod()) {
      case 'breakfast':
        return _breakfastCount;
      case 'lunch':
        return _lunchCount;
      case 'dinner':
        return _dinnerCount;
      default:
        return 0;
    }
  }

  int get currentAbsentCount => _totalMembers - getCurrentMealAttendance();

  // Update methods
  Future<void> updateTotalMembers(int count) async {
    _totalMembers = count;
    await _box.put('totalMembers', count);
    notifyListeners();
  }

  Future<void> updateMealAttendance(String meal, int count) async {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month}-${now.day}';

    switch (meal.toLowerCase()) {
      case 'breakfast':
        _breakfastCount = count;
        await _box.put('${dateKey}_breakfast', count);
        break;
      case 'lunch':
        _lunchCount = count;
        await _box.put('${dateKey}_lunch', count);
        break;
      case 'dinner':
        _dinnerCount = count;
        await _box.put('${dateKey}_dinner', count);
        break;
    }
    notifyListeners();
  }

  Future<void> recordMemberAttendance({
    required String memberId,
    required String memberName,
    required String meal,
    required bool isPresent,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find existing record for today
    final existingRecordIndex = _attendanceRecords.indexWhere((record) {
      final recordDate = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      return record.memberId == memberId && recordDate.isAtSameMomentAs(today);
    });

    if (existingRecordIndex != -1) {
      // Update existing record
      final existing = _attendanceRecords[existingRecordIndex];
      final updated = AttendanceRecordModel(
        id: existing.id,
        memberId: memberId,
        memberName: memberName,
        date: existing.date,
        breakfast: meal == 'breakfast' ? isPresent : existing.breakfast,
        lunch: meal == 'lunch' ? isPresent : existing.lunch,
        dinner: meal == 'dinner' ? isPresent : existing.dinner,
      );
      _attendanceRecords[existingRecordIndex] = updated;
    } else {
      // Create new record
      final record = AttendanceRecordModel(
        id: const Uuid().v4(),
        memberId: memberId,
        memberName: memberName,
        date: today,
        breakfast: meal == 'breakfast' ? isPresent : false,
        lunch: meal == 'lunch' ? isPresent : false,
        dinner: meal == 'dinner' ? isPresent : false,
      );
      _attendanceRecords.add(record);
    }

    await _box.put('attendance_records',
        _attendanceRecords.map((record) => record.toJson()).toList());
    notifyListeners();
  }

  Future<void> clearAttendanceRecords() async {
    _attendanceRecords.clear();
    await _box.put('attendance_records', []);
    notifyListeners();
  }

  bool isMealTimeValid(String meal) {
    final now = DateTime.now();
    final hour = now.hour;

    switch (meal.toLowerCase()) {
      case 'breakfast':
        return hour >= 7 && hour < 10;
      case 'lunch':
        return hour >= 12 && hour < 15;
      case 'dinner':
        return hour >= 19 && hour < 23;
      default:
        return false;
    }
  }

  bool isAttendanceMarked(String? memberId, String meal) {
    if (memberId == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final existingRecord = _attendanceRecords.firstWhere(
      (record) {
        final recordDate = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
        );
        return record.memberId == memberId &&
            recordDate.isAtSameMomentAs(today);
      },
      orElse: () => AttendanceRecordModel(
        id: '',
        memberId: '',
        memberName: '',
        date: now,
        breakfast: false,
        lunch: false,
        dinner: false,
      ),
    );

    switch (meal.toLowerCase()) {
      case 'breakfast':
        return existingRecord.breakfast;
      case 'lunch':
        return existingRecord.lunch;
      case 'dinner':
        return existingRecord.dinner;
      default:
        return false;
    }
  }

  Future<void> markAttendance({
    required String memberId,
    required String memberName,
    required DateTime date,
    required bool breakfast,
    required bool lunch,
    required bool dinner,
  }) async {
    final day = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();

    // Check if trying to mark attendance for future date
    if (day.isAfter(DateTime(now.year, now.month, now.day))) {
      throw Exception('Cannot mark attendance for future dates');
    }

    // Check if attendance is already marked for any meal
    if (isMealTimeValid('breakfast') &&
        isAttendanceMarked(memberId, 'breakfast')) {
      throw Exception('Breakfast attendance already marked');
    }
    if (isMealTimeValid('lunch') && isAttendanceMarked(memberId, 'lunch')) {
      throw Exception('Lunch attendance already marked');
    }
    if (isMealTimeValid('dinner') && isAttendanceMarked(memberId, 'dinner')) {
      throw Exception('Dinner attendance already marked');
    }

    // Find existing record for the day
    final existingRecordIndex = _attendanceRecords.indexWhere((record) {
      final recordDate = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      return record.memberId == memberId && recordDate.isAtSameMomentAs(day);
    });

    if (existingRecordIndex != -1) {
      // Update existing record
      final existing = _attendanceRecords[existingRecordIndex];

      // Only update meals that are within their valid time periods and not already marked
      final updated = AttendanceRecordModel(
        id: existing.id,
        memberId: memberId,
        memberName: memberName,
        date: existing.date,
        breakfast: isMealTimeValid('breakfast') &&
                !isAttendanceMarked(memberId, 'breakfast')
            ? breakfast
            : existing.breakfast,
        lunch:
            isMealTimeValid('lunch') && !isAttendanceMarked(memberId, 'lunch')
                ? lunch
                : existing.lunch,
        dinner:
            isMealTimeValid('dinner') && !isAttendanceMarked(memberId, 'dinner')
                ? dinner
                : existing.dinner,
      );
      _attendanceRecords[existingRecordIndex] = updated;
    } else {
      // Create new record
      final record = AttendanceRecordModel(
        id: const Uuid().v4(),
        memberId: memberId,
        memberName: memberName,
        date: day,
        breakfast: isMealTimeValid('breakfast') ? breakfast : false,
        lunch: isMealTimeValid('lunch') ? lunch : false,
        dinner: isMealTimeValid('dinner') ? dinner : false,
      );
      _attendanceRecords.add(record);
    }

    // Update meal counts
    final dateKey = '${date.year}-${date.month}-${date.day}';
    if (breakfast && isMealTimeValid('breakfast')) {
      _breakfastCount = _attendanceRecords
          .where((r) => r.breakfast && r.date.isAtSameMomentAs(day))
          .length;
      await _box.put('${dateKey}_breakfast', _breakfastCount);
    }
    if (lunch && isMealTimeValid('lunch')) {
      _lunchCount = _attendanceRecords
          .where((r) => r.lunch && r.date.isAtSameMomentAs(day))
          .length;
      await _box.put('${dateKey}_lunch', _lunchCount);
    }
    if (dinner && isMealTimeValid('dinner')) {
      _dinnerCount = _attendanceRecords
          .where((r) => r.dinner && r.date.isAtSameMomentAs(day))
          .length;
      await _box.put('${dateKey}_dinner', _dinnerCount);
    }

    await _box.put('attendance_records',
        _attendanceRecords.map((record) => record.toJson()).toList());
    notifyListeners();
  }
}
