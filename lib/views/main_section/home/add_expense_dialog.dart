import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/expense_provider.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({Key? key}) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'utilities';
  String _selectedSubCategory = 'utils';

  final Map<String, List<String>> _categorySubCategories = {
    'utilities': ['utils', 'electricity', 'water', 'gas', 'internet', 'other'],
    'food': ['groceries', 'vegetables', 'fruits', 'meat', 'dairy', 'other'],
    'maintenance': ['cleaning', 'repairs', 'equipment', 'other'],
    'staff': ['salary', 'bonus', 'benefits', 'other'],
    'other': ['miscellaneous']
  };

  @override
  void initState() {
    super.initState();
    _selectedSubCategory = _categorySubCategories[_selectedCategory]![0];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categorySubCategories.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category.toUpperCase()),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                      _selectedSubCategory = _categorySubCategories[value]![0];
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSubCategory,
                decoration: const InputDecoration(
                  labelText: 'Sub Category',
                  prefixIcon: Icon(Icons.subdirectory_arrow_right),
                  border: OutlineInputBorder(),
                ),
                items: _categorySubCategories[_selectedCategory]!
                    .map((String subCategory) {
                  return DropdownMenuItem<String>(
                    value: subCategory,
                    child: Text(subCategory.toUpperCase()),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedSubCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter expense description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, child) {
            return ElevatedButton(
              onPressed: expenseProvider.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await expenseProvider.addExpense(
                          category: _selectedCategory,
                          description: _descriptionController.text,
                          amount: double.parse(_amountController.text),
                          subCategory: _selectedSubCategory,
                        );

                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Expense added successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                expenseProvider.error ??
                                    'Failed to add expense',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: expenseProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Add Expense'),
            );
          },
        ),
      ],
    );
  }
}
