import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../provider/member_provider.dart';
import '../../../provider/payment_provider.dart';
import '../../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMemberId;
  String? _selectedMemberName;
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'Cash';
  String _selectedModeOfPayment = 'Offline';
  XFile? _selectedImage;
  final _descriptionController = TextEditingController();

  final List<String> _paymentMethods = ['Cash', 'UPI', 'Bank Transfer', 'Card'];
  final List<String> _modesOfPayment = ['Online', 'Offline'];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
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

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedMemberId != null) {
      context.read<PaymentProvider>().addPayment(
            name: _selectedMemberId!,
            type: _selectedMemberName!,
            category: 'Payment',
            subCategory: 'Payment',
            amount: double.parse(_amountController.text),
            description: _descriptionController.text,
            paymentMethod: _selectedPaymentMethod,
            upiSubType: _selectedModeOfPayment,
            imageUrl: _selectedImage?.path ?? '',
          );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<MemberProvider>().members;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Member',
                  border: OutlineInputBorder(),
                ),
                value: _selectedMemberId,
                items: members.map((member) {
                  return DropdownMenuItem(
                    value: member.id,
                    child: Text(member.name),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedMemberId = value;
                    _selectedMemberName =
                        members.firstWhere((member) => member.id == value).name;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a member';
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
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Payment Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                value: _selectedPaymentMethod,
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Mode of Payment',
                  border: OutlineInputBorder(),
                ),
                value: _selectedModeOfPayment,
                items: _modesOfPayment.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedModeOfPayment = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _pickImage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload),
                    const SizedBox(width: 8),
                    Text(_selectedImage != null
                        ? 'Change Payment Proof'
                        : 'Upload Payment Proof'),
                  ],
                ),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_selectedImage!.path),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Submit Payment',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
