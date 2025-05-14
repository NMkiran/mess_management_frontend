import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/payment_provider.dart';

class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({super.key});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedType = 'PAYMENT';
  String _selectedPaymentMethod = 'UPI';
  String _selectedUpiSubType = 'GOOGLE_PAY';

  final List<String> _paymentTypes = ['PAYMENT', 'RECEIPT'];
  final List<String> _paymentMethods = ['UPI', 'CASH', 'BANK_TRANSFER'];
  final List<String> _upiSubTypes = [
    'GOOGLE_PAY',
    'PHONE_PE',
    'PAYTM',
    'OTHER'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _subCategoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final paymentProvider =
          Provider.of<PaymentProvider>(context, listen: false);

      final success = await paymentProvider.addPayment(
        name: _nameController.text,
        type: _selectedType,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        category: _categoryController.text,
        subCategory: _subCategoryController.text,
        paymentMethod: _selectedPaymentMethod,
        upiSubType: _selectedUpiSubType,
        imageUrl: _imageUrlController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment added successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(paymentProvider.error ?? 'Failed to add payment')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Payment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Payment Type',
                  border: OutlineInputBorder(),
                ),
                items: _paymentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subCategoryController,
                decoration: const InputDecoration(
                  labelText: 'Sub Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a sub category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentMethod = value;
                      if (value != 'UPI') {
                        _selectedUpiSubType = 'OTHER';
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedPaymentMethod == 'UPI')
                DropdownButtonFormField<String>(
                  value: _selectedUpiSubType,
                  decoration: const InputDecoration(
                    labelText: 'UPI Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _upiSubTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedUpiSubType = value;
                      });
                    }
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text('Add Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
