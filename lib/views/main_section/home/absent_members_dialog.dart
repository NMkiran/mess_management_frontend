import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../provider/attendance_provider.dart';
import '../../../provider/member_provider.dart';
import '../../../models/member_model.dart';

class AbsentMembersDialog extends StatelessWidget {
  const AbsentMembersDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AttendanceProvider, MemberProvider>(
      builder: (context, attendance, memberProvider, _) {
        final currentMeal = attendance.getCurrentMealPeriod();
        final activeMembers = memberProvider.activeMembers;
        final currentAttendance = attendance.getCurrentMealAttendance();
        final absentMembers = activeMembers
            .take(activeMembers.length - currentAttendance)
            .toList();

        return AlertDialog(
          title: Text('Absent Members - ${currentMeal.toUpperCase()}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${absentMembers.length} members absent',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.warning,
                      ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: absentMembers.length,
                    itemBuilder: (context, index) {
                      final member = absentMembers[index];
                      return _buildMemberTile(context, member);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMemberTile(BuildContext context, MemberModel member) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.accent,
        child: Text(
          member.name[0].toUpperCase(),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
      title: Text(member.name),
      subtitle: Text('Room: ${member.roomNumber}'),
      trailing: IconButton(
        icon: const Icon(Icons.phone),
        onPressed: () {},
        color: AppColors.accent,
      ),
    );
  }
}
