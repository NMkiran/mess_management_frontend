import '../models/attendance_record_model.dart';
import '../models/expense_model.dart';

class DummyData {
  // static List<MemberModel> getSampleMembers() {
  //   return [
  //     MemberModel(
  //       id: 'mem1',
  //       name: 'John Doe',
  //       roomNumber: 'A101',
  //       phoneNumber: '+91 9876543210',
  //       email: 'john.doe@example.com',
  //       joiningDate: DateTime.now().subtract(const Duration(days: 60)),
  //     ),
  //     MemberModel(
  //       id: 'mem2',
  //       name: 'Jane Smith',
  //       roomNumber: 'A102',
  //       phoneNumber: '+91 9876543211',
  //       email: 'jane.smith@example.com',
  //       joiningDate: DateTime.now().subtract(const Duration(days: 55)),
  //     ),
  //     MemberModel(
  //       id: 'mem3',
  //       name: 'Mike Johnson',
  //       roomNumber: 'B201',
  //       phoneNumber: '+91 9876543212',
  //       email: 'mike.johnson@example.com',
  //       joiningDate: DateTime.now().subtract(const Duration(days: 45)),
  //     ),
  //     MemberModel(
  //       id: 'mem4',
  //       name: 'Sarah Williams',
  //       roomNumber: 'B202',
  //       phoneNumber: '+91 9876543213',
  //       email: 'sarah.williams@example.com',
  //       joiningDate: DateTime.now().subtract(const Duration(days: 40)),
  //     ),
  //     MemberModel(
  //       id: 'mem5',
  //       name: 'David Brown',
  //       roomNumber: 'C301',
  //       phoneNumber: '+91 9876543214',
  //       email: 'david.brown@example.com',
  //       joiningDate: DateTime.now().subtract(const Duration(days: 30)),
  //     ),
  //   ];
  // }

  static List<AttendanceRecordModel> getSampleAttendanceRecords() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    return [
      // Today's records
      AttendanceRecordModel(
        id: '1',
        memberId: 'mem1',
        memberName: 'John Doe',
        date: today,
        breakfast: true,
        lunch: true,
        dinner: false,
      ),
      AttendanceRecordModel(
        id: '2',
        memberId: 'mem2',
        memberName: 'Jane Smith',
        date: today,
        breakfast: true,
        lunch: true,
        dinner: true,
      ),
      AttendanceRecordModel(
        id: '3',
        memberId: 'mem3',
        memberName: 'Mike Johnson',
        date: today,
        breakfast: false,
        lunch: true,
        dinner: true,
      ),
      // Yesterday's records
      AttendanceRecordModel(
        id: '4',
        memberId: 'mem1',
        memberName: 'John Doe',
        date: yesterday,
        breakfast: true,
        lunch: true,
        dinner: true,
      ),
      AttendanceRecordModel(
        id: '5',
        memberId: 'mem2',
        memberName: 'Jane Smith',
        date: yesterday,
        breakfast: true,
        lunch: false,
        dinner: true,
      ),
    ];
  }

  static List<ExpenseModel> getSampleExpenses() {
    return [
      ExpenseModel(
        id: '1',
        subCategory: 'Groceries',
        description: 'Rice and Groceries',
        amount: 12500.00,
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Groceries',
      ),
      ExpenseModel(
        id: '2',
        description: 'Vegetables',
        subCategory: 'Groceries',
        amount: 3200.00,
        date: DateTime.now().subtract(const Duration(days: 4)),
        category: 'Vegetables',
      ),
      ExpenseModel(
        id: '3',
        subCategory: 'Groceries',
        description: 'Gas Cylinder',
        amount: 1800.00,
        date: DateTime.now().subtract(const Duration(days: 3)),
        category: 'Utilities',
      ),
      ExpenseModel(
        id: '4',
        subCategory: 'Groceries',
        description: 'Cook Salary',
        amount: 15000.00,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Salary',
      ),
      ExpenseModel(
        id: '5',
        subCategory: 'Groceries',
        description: 'Kitchen Equipment',
        amount: 5000.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Equipment',
      ),
    ];
  }

  // static List<PaymentModel> getSamplePayments() {
  //   return [
  //     PaymentModel(
  //       id: '1',
  //       amount: 3500.00,
  //       date: DateTime.now().subtract(const Duration(days: 6)),

  //       description: 'Monthly Mess Fee',
  //     ),
  //     PaymentModel(
  //       id: '2',
  //       memberId: 'mem2',
  //       memberName: 'Jane Smith',
  //       amount: 3500.00,
  //       date: DateTime.now().subtract(const Duration(days: 5)),
  //       month: 'May',
  //       description: 'Monthly Mess Fee',
  //     ),
  //     PaymentModel(
  //       id: '3',
  //       memberId: 'mem3',
  //       memberName: 'Mike Johnson',
  //       amount: 3500.00,
  //       date: DateTime.now().subtract(const Duration(days: 4)),
  //       month: 'May',
  //       description: 'Monthly Mess Fee',
  //     ),
  //     PaymentModel(
  //       id: '4',
  //       memberId: 'mem4',
  //       memberName: 'Sarah Williams',
  //       amount: 3500.00,
  //       date: DateTime.now().subtract(const Duration(days: 3)),
  //       month: 'May',
  //       description: 'Monthly Mess Fee',
  //     ),
  //     PaymentModel(
  //       id: '5',
  //       memberId: 'mem5',
  //       memberName: 'David Brown',
  //       amount: 3500.00,
  //       date: DateTime.now().subtract(const Duration(days: 2)),
  //       month: 'May',
  //       description: 'Monthly Mess Fee',
  //     ),
  //   ];
  // }
}
