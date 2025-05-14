import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../provider/attendance_provider.dart';
import '../../../provider/member_provider.dart';
import '../../../theme/app_colors.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      floatingActionButton: _isToday(_selectedDate)
          ? FloatingActionButton.extended(
              onPressed: () => _markAttendance(context),
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark Attendance'),
              backgroundColor: AppColors.primary,
            )
          : null,
      body: Consumer2<AttendanceProvider, MemberProvider>(
        builder: (context, attendance, members, _) {
          final records = attendance.getAttendanceByDate(_selectedDate);
          final allMembers = members.activeMembers;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(
                  children: [
                    Text(
                      _isToday(_selectedDate)
                          ? 'Today\'s Attendance'
                          : DateFormat('MMMM d, yyyy').format(_selectedDate),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMealSummary(
                            'Breakfast', records, allMembers.length),
                        _buildMealSummary('Lunch', records, allMembers.length),
                        _buildMealSummary('Dinner', records, allMembers.length),
                      ],
                    ),
                    if (_isToday(_selectedDate)) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _markAttendance(context),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Add/Edit Attendance'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: records.isEmpty
                    ? Center(
                        child: Text(
                          'No attendance records for ${DateFormat('MMM d').format(_selectedDate)}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(record.memberName),
                              subtitle: Row(
                                children: [
                                  _buildMealIcon('B', record.breakfast),
                                  const SizedBox(width: 16),
                                  _buildMealIcon('L', record.lunch),
                                  const SizedBox(width: 16),
                                  _buildMealIcon('D', record.dinner),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildMealSummary(
      String meal, List<dynamic> records, int totalMembers) {
    int presentCount = 0;
    switch (meal.toLowerCase()) {
      case 'breakfast':
        presentCount = records.where((r) => r.breakfast).length;
        break;
      case 'lunch':
        presentCount = records.where((r) => r.lunch).length;
        break;
      case 'dinner':
        presentCount = records.where((r) => r.dinner).length;
        break;
    }

    return Column(
      children: [
        Text(
          meal,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          '$presentCount/$totalMembers',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildMealIcon(String label, bool present) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: present ? AppColors.success : AppColors.error,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _markAttendance(BuildContext context) async {
    final attendanceProvider = context.read<AttendanceProvider>();
    final memberProvider = context.read<MemberProvider>();
    final activeMembers = memberProvider.activeMembers;

    // Show a dialog to select member and meals
    final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? selectedMemberId;
        final Map<String, bool> selectedMeals = {
          'breakfast': true,
          'lunch': true,
          'dinner': true,
        };

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Mark Attendance'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Select Member'),
                          value: selectedMemberId,
                          items: activeMembers.map((member) {
                            return DropdownMenuItem(
                              value: member.id,
                              child:
                                  Text('${member.name} (${member.roomNumber})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMemberId = value;
                              if (value != null) {
                                // Update meal checkboxes based on already marked attendance
                                selectedMeals['breakfast'] = !attendanceProvider
                                    .isAttendanceMarked(value, 'breakfast');
                                selectedMeals['lunch'] = !attendanceProvider
                                    .isAttendanceMarked(value, 'lunch');
                                selectedMeals['dinner'] = !attendanceProvider
                                    .isAttendanceMarked(value, 'dinner');
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    if (selectedMemberId != null) ...[
                      const SizedBox(height: 16),
                      const Text('Select Meals:'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMealCheckbox(
                            'Breakfast\n(7:00-10:00)',
                            selectedMeals['breakfast']!,
                            (value) {
                              setState(() {
                                selectedMeals['breakfast'] = value!;
                              });
                            },
                            enabled: attendanceProvider
                                    .isMealTimeValid('breakfast') &&
                                !attendanceProvider.isAttendanceMarked(
                                    selectedMemberId!, 'breakfast'),
                            isMarked: attendanceProvider.isAttendanceMarked(
                                selectedMemberId!, 'breakfast'),
                            isMissed: !attendanceProvider
                                    .isMealTimeValid('breakfast') &&
                                !attendanceProvider.isAttendanceMarked(
                                    selectedMemberId!, 'breakfast'),
                          ),
                          _buildMealCheckbox(
                            'Lunch\n(12:00-15:00)',
                            selectedMeals['lunch']!,
                            (value) {
                              setState(() {
                                selectedMeals['lunch'] = value!;
                              });
                            },
                            enabled:
                                attendanceProvider.isMealTimeValid('lunch') &&
                                    !attendanceProvider.isAttendanceMarked(
                                        selectedMemberId!, 'lunch'),
                            isMarked: attendanceProvider.isAttendanceMarked(
                                selectedMemberId!, 'lunch'),
                            isMissed:
                                !attendanceProvider.isMealTimeValid('lunch') &&
                                    !attendanceProvider.isAttendanceMarked(
                                        selectedMemberId!, 'lunch'),
                          ),
                          _buildMealCheckbox(
                            'Dinner\n(19:00-23:00)',
                            selectedMeals['dinner']!,
                            (value) {
                              setState(() {
                                selectedMeals['dinner'] = value!;
                              });
                            },
                            enabled:
                                attendanceProvider.isMealTimeValid('dinner') &&
                                    !attendanceProvider.isAttendanceMarked(
                                        selectedMemberId!, 'dinner'),
                            isMarked: attendanceProvider.isAttendanceMarked(
                                selectedMemberId!, 'dinner'),
                            isMissed:
                                !attendanceProvider.isMealTimeValid('dinner') &&
                                    !attendanceProvider.isAttendanceMarked(
                                        selectedMemberId!, 'dinner'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!attendanceProvider.isMealTimeValid('breakfast') ||
                          !attendanceProvider.isMealTimeValid('lunch') ||
                          !attendanceProvider.isMealTimeValid('dinner'))
                        Text(
                          'Note: You can only mark attendance during meal times',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.error,
                                  ),
                        ),
                      if (attendanceProvider.isAttendanceMarked(
                              selectedMemberId, 'breakfast') ||
                          attendanceProvider.isAttendanceMarked(
                              selectedMemberId, 'lunch') ||
                          attendanceProvider.isAttendanceMarked(
                              selectedMemberId, 'dinner'))
                        Text(
                          'Note: Already marked meals cannot be changed',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.error,
                                  ),
                        ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedMemberId == null
                      ? null
                      : () {
                          Navigator.of(context).pop({
                            'memberId': selectedMemberId,
                            'meals': Map<String, bool>.from(selectedMeals),
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result['memberId'] != null) {
      try {
        // Find the selected member
        final selectedMember = activeMembers.firstWhere(
          (member) => member.id == result['memberId'],
        );

        // Mark attendance for the selected member and meals
        await attendanceProvider.markAttendance(
          memberId: selectedMember.id,
          memberName: selectedMember.name,
          date: _selectedDate,
          breakfast: result['meals']['breakfast']!,
          lunch: result['meals']['lunch']!,
          dinner: result['meals']['dinner']!,
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildMealCheckbox(
    String meal,
    bool value,
    Function(bool?) onChanged, {
    bool enabled = true,
    bool isMarked = false,
    bool isMissed = false,
  }) {
    return Column(
      children: [
        Text(
          meal,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: enabled ? null : Colors.grey,
          ),
        ),
        if (isMarked)
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 24,
          )
        else if (isMissed)
          const Icon(
            Icons.cancel,
            color: AppColors.error,
            size: 24,
          )
        else
          Checkbox(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.primary,
          ),
      ],
    );
  }
}
