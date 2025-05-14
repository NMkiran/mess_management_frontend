import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../provider/member_provider.dart';
import '../../../provider/attendance_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../models/member_model.dart';

class MemberProfileScreen extends StatelessWidget {
  final MemberModel member;

  const MemberProfileScreen({
    Key? key,
    required this.member,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        actions: [
          IconButton(
            icon: Icon(
              member.isActive ? Icons.toggle_on : Icons.toggle_off,
              color: member.isActive ? AppColors.success : Colors.grey,
            ),
            onPressed: () {
              context.read<MemberProvider>().toggleMemberStatus(member.id);
            },
          ),
        ],
      ),
      body: Consumer2<MemberProvider, AttendanceProvider>(
        builder: (context, memberProvider, attendanceProvider, _) {
          final updatedMember = memberProvider.members
              .firstWhere((m) => m.id == member.id, orElse: () => member);

          // Calculate attendance statistics
          final attendanceRecords = attendanceProvider.attendanceRecords
              .where((record) => record.memberId == member.id)
              .toList();

          int totalDays = attendanceRecords.length;
          int presentDays = attendanceRecords.where((record) {
            final now = DateTime.now();
            final recordDate = DateTime(
              record.date.year,
              record.date.month,
              record.date.day,
            );
            return recordDate.isBefore(now) &&
                (record.breakfast || record.lunch || record.dinner);
          }).length;

          int absentDays = totalDays - presentDays;

          // Calculate days left in current month
          final now = DateTime.now();
          final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
          final daysLeft = lastDayOfMonth.day - now.day;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, updatedMember),
                const SizedBox(height: 24),
                _buildAttendanceStats(
                    context, presentDays, absentDays, daysLeft),
                const SizedBox(height: 24),
                _buildContactInfo(context, updatedMember),
                const SizedBox(height: 24),
                _buildAttendanceHistory(context, attendanceRecords),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, MemberModel member) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: member.isActive ? AppColors.primary : Colors.grey,
          radius: 40,
          child: Text(
            member.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Room: ${member.roomNumber}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Joined: ${DateFormat('MMMM d, yyyy').format(member.joiningDate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceStats(
      BuildContext context, int presentDays, int absentDays, int daysLeft) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Present',
                  presentDays.toString(),
                  AppColors.success,
                ),
                _buildStatItem(
                  context,
                  'Absent',
                  absentDays.toString(),
                  AppColors.error,
                ),
                _buildStatItem(
                  context,
                  'Days Left',
                  daysLeft.toString(),
                  AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context, MemberModel member) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.phone, member.phoneNumber),
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.email, member.email),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildAttendanceHistory(
      BuildContext context, List<dynamic> attendanceRecords) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Attendance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (attendanceRecords.isEmpty)
              Center(
                child: Text(
                  'No attendance records found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    attendanceRecords.length > 7 ? 7 : attendanceRecords.length,
                itemBuilder: (context, index) {
                  final record = attendanceRecords[index];
                  return _buildAttendanceItem(context, record);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceItem(BuildContext context, dynamic record) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            DateFormat('MMM d').format(record.date),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          _buildMealIcon('B', record.breakfast),
          const SizedBox(width: 8),
          _buildMealIcon('L', record.lunch),
          const SizedBox(width: 8),
          _buildMealIcon('D', record.dinner),
        ],
      ),
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
}
