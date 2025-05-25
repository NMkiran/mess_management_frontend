import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/provider/expenses_provider.dart';
import 'package:mess_management/providers/expense_provider.dart';
import 'package:provider/provider.dart';

import '../../../provider/attendance_provider.dart';

import '../../../provider/expense_provider.dart';

import '../../../provider/member_provider.dart';
import '../../../provider/payment_provider.dart';
import '../../../theme/app_colors.dart';
import 'add_expense_dialog.dart';
import 'add_member_dialog.dart';
import 'add_payment_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  late String _timeString;

  @override
  void initState() {
    super.initState();
    _timeString = _getTimeString();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _getTime() {
    setState(() {
      _timeString = _getTimeString();
    });
  }

  String _getTimeString() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM d, yyyy  HH:mm:ss');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Home'),
            const Spacer(),
            Text(
              _timeString,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                  ),
            ),
          ],
        ),
      ),
      body: Consumer3<AttendanceProvider, MemberProvider, ExpensesProvider>(
        builder: (context, attendance, member, expense, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(
                  context,
                  totalMembers: member.totalMembers,
                  activeMembers: member.activeCount,
                  // totalExpenses: expense.totalExpenses,
                ),
                const SizedBox(height: 24),
                Text(
                  'Today\'s Meal Attendance',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMealCard(
                        context,
                        icon: Icons.free_breakfast,
                        meal: 'Breakfast',
                        count: attendance.breakfastCount,
                        total: member.activeCount,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMealCard(
                        context,
                        icon: Icons.lunch_dining,
                        meal: 'Lunch',
                        count: attendance.lunchCount,
                        total: member.activeCount,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMealCard(
                        context,
                        icon: Icons.dinner_dining,
                        meal: 'Dinner',
                        count: attendance.dinnerCount,
                        total: member.activeCount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddMemberDialog(context),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Member'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddExpenseDialog(context),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Add Expense'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddPaymentDialog(context),
                  icon: const Icon(Icons.payment),
                  label: const Text('Add Payment'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required int totalMembers,
    required int activeMembers,
    // required double totalExpenses,
  }) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹');
    final attendance = context.watch<AttendanceProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  icon: Icons.people,
                  label: 'Total\nMembers',
                  value: totalMembers.toString(),
                  color: AppColors.accent,
                ),
                _buildStatColumn(
                  context,
                  icon: Icons.person_outline,
                  label: 'Active\nMembers',
                  value: activeMembers.toString(),
                  color: AppColors.success,
                ),
                _buildStatColumn(
                  context,
                  icon: Icons.person_off,
                  label: 'Absent\nNow',
                  value: attendance.currentAbsentCount.toString(),
                  color: AppColors.error,
                ),
                _buildStatColumn(
                  context,
                  icon: Icons.currency_rupee,
                  label: 'Total\nExpenses',
                  // value: currencyFormatter.format(totalExpenses),
                  value: "",
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(
    BuildContext context, {
    required IconData icon,
    required String meal,
    required int count,
    required int total,
  }) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.accent,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              meal,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddMemberDialog(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddMemberDialog(),
    );
    print("result $result");
    if (result != null && context.mounted) {
      final provider = context.read<MemberProvider>();
      await provider.addMember(
        name: result['name']!,
        roomNumber: result['roomNumber']!,
        phoneNumber: result['phoneNumber']!,
        email: result['email']!,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _showAddExpenseDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );

    if (result != null && context.mounted) {
      final provider = context.read<ExpenseProvider>();
      await provider.addExpense(
        description: result['description'],
        amount: result['amount'],
        subCategory: result['subCategory'],
        category: result['category'],
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _showAddPaymentDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddPaymentDialog(),
    );
    print("result $result");

    if (result != null && context.mounted) {
      final provider = context.read<PaymentProvider>();
      print("result['name'] ${result['memberName']}");
      await provider.addPayment(
        name: result['memberName'] ?? '',
        type: result['type'] ?? '',
        amount: result['amount'] ?? 0,
        description: result['description'] ?? '',
        category: result['category'] ?? '',
        subCategory: result['subCategory'] ?? '',
        upiSubType: result['upiSubType'] ?? '',
        imageUrl: result['imageUrl'] ?? '',
        paymentMethod: result['paymentMethod'].toUpperCase(),
      );
      print("result['name'] ${result['memberName']}");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
