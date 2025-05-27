import 'package:flutter/material.dart';
import 'package:mess_management/provider/expenses_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../provider/payment_provider.dart';
import '../../../provider/history_provider.dart';
import '../../../models/payment_model.dart';
import '../../../theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedTimeRange = 'All';
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  final List<String> _filters = ['All', 'Payments', 'Expenses'];
  final List<String> _timeRanges = ['All', 'Today', 'This Month', 'Last Month'];

  @override
  void initState() {
    super.initState();
    // Fetch history summary when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final historyProvider = context.read<HistoryProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final expensesProvider = context.read<ExpensesProvider>();

    // Fetch all data in parallel
    await Future.wait([
      historyProvider.fetchHistorySummary(),
      paymentProvider.fetchPayments(),
      expensesProvider.fetchExpenses(),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCompare = DateTime(date.year, date.month, date.day);

    if (dateToCompare == today) {
      return 'Today';
    } else if (dateToCompare == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  bool _matchesSearch(String text) {
    if (_searchController.text.isEmpty) return true;
    return text.toLowerCase().contains(_searchController.text.toLowerCase());
  }

  bool _matchesTimeRange(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedTimeRange) {
      case 'Today':
        return date.isAfter(today.subtract(const Duration(days: 1))) &&
            date.isBefore(today.add(const Duration(days: 1)));
      case 'This Month':
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        return date
                .isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
            date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
      case 'Last Month':
        final firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
        return date.isAfter(
                firstDayOfLastMonth.subtract(const Duration(days: 1))) &&
            date.isBefore(lastDayOfLastMonth.add(const Duration(days: 1)));
      default:
        return true;
    }
  }

  List<dynamic> _getFilteredItems(BuildContext context) {
    final payments = context.watch<PaymentProvider>().payments;
    final expenses = context.watch<ExpensesProvider>().expenses;

    List<dynamic> items = [];

    if (_selectedFilter == 'All' || _selectedFilter == 'Payments') {
      items.addAll(payments.where((payment) =>
          (_matchesSearch(payment.name) ||
              _matchesSearch(payment.description)) &&
          _matchesTimeRange(payment.date)));
    }

    if (_selectedFilter == 'All' || _selectedFilter == 'Expenses') {
      items.addAll(expenses.where((expense) =>
          (_matchesSearch(expense.description) ||
              _matchesSearch(expense.category)) &&
          _matchesTimeRange(expense.date)));
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshData,
        child: Column(
          children: [
            _buildSummaryCard(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by name, description or category...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFilter,
                          decoration: const InputDecoration(
                            labelText: 'Filter',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                          ),
                          items: _filters.map((filter) {
                            return DropdownMenuItem(
                              value: filter,
                              child: Text(filter),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedFilter = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTimeRange,
                          decoration: const InputDecoration(
                            labelText: 'Time Range',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                          ),
                          items: _timeRanges.map((range) {
                            return DropdownMenuItem(
                              value: range,
                              child: Text(range),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedTimeRange = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  Consumer3<PaymentProvider, ExpensesProvider, HistoryProvider>(
                builder: (context, payments, expenses, history, _) {
                  final items = _getFilteredItems(context);

                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No records found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final bool isPayment = item is PaymentModel;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isPayment ? AppColors.success : AppColors.error,
                            child: Icon(
                              isPayment ? Icons.payments : Icons.receipt_long,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            isPayment
                                ? item.name
                                : '${item.category}${item.subCategory.isNotEmpty ? ' - ${item.subCategory}' : ''}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPayment
                                    ? item.description.isEmpty
                                        ? 'No description'
                                        : item.description
                                    : item.description.isEmpty
                                        ? 'No description'
                                        : item.description,
                              ),
                              Text(
                                _getRelativeDate(item.date),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: Text(
                            NumberFormat.currency(symbol: '₹')
                                .format(item.amount),
                            style: TextStyle(
                              color: isPayment
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, _) {
        if (historyProvider.isLoading) {
          return const Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (historyProvider.error != null) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Error: ${historyProvider.error}',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final summary = historyProvider.summary;
        if (summary == null) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('No summary data available'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _refreshData(),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        label: 'Today',
                        income: summary.todayIncome,
                        expense: summary.todayExpenses,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 100,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        label: 'This Month',
                        income: summary.thisMonthIncome,
                        expense: summary.thisMonthExpenses,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 100,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        label: 'All Time',
                        income: summary.allTimeIncome,
                        expense: summary.allTimeExpenses,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required double income,
    required double expense,
  }) {
    final balance = income - expense;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Income: ${NumberFormat.currency(symbol: '₹').format(income)}',
          style: const TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Expense: ${NumberFormat.currency(symbol: '₹').format(expense)}',
          style: const TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const Divider(),
        Text(
          'Balance: ${NumberFormat.currency(symbol: '₹').format(balance)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: balance >= 0 ? AppColors.success : AppColors.error,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
