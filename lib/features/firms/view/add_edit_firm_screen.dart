import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/auth/widgets/custom_text_field.dart';
import 'package:my_sauda/features/firms/view_model/firms_view_model.dart';
import '../model/firm.dart';

class AddEditFirmScreen extends ConsumerStatefulWidget {
  final Firm? firm;

  const AddEditFirmScreen({super.key, this.firm});

  @override
  ConsumerState<AddEditFirmScreen> createState() => _AddEditFirmScreenState();
}

class _AddEditFirmScreenState extends ConsumerState<AddEditFirmScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firmNameController;
  late TextEditingController _proprietorNameController;
  late TextEditingController _phoneController;
  late TextEditingController _altPhoneController;
  late TextEditingController _gstinController;
  late TextEditingController _panController;
  late TextEditingController _addressController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankIfscController;
  late TextEditingController _bankAccountNumberController;
  late TextEditingController _bankAccountNameController;

  bool get isEdit => widget.firm != null;

  @override
  void initState() {
    super.initState();

    final f = widget.firm;

    _firmNameController = TextEditingController(text: f?.firmName ?? '');
    _proprietorNameController =
        TextEditingController(text: f?.proprietorName ?? '');
    _phoneController = TextEditingController(text: f?.phoneNumber ?? '');
    _altPhoneController =
        TextEditingController(text: f?.alternatePhoneNumber ?? '');
    _gstinController = TextEditingController(text: f?.gstin ?? '');
    _panController = TextEditingController(text: f?.pan ?? '');
    _addressController = TextEditingController(text: f?.address ?? '');
    _bankNameController = TextEditingController(text: f?.bankName ?? '');
    _bankIfscController = TextEditingController(text: f?.bankIfsc ?? '');
    _bankAccountNumberController =
        TextEditingController(text: f?.bankAccountNumber ?? '');
    _bankAccountNameController =
        TextEditingController(text: f?.bankAccountName ?? '');
  }

  @override
  void dispose() {
    _firmNameController.dispose();
    _proprietorNameController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _addressController.dispose();
    _bankNameController.dispose();
    _bankIfscController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountNameController.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final vm = ref.read(firmsViewModelProvider.notifier);

    bool success = false;

    if (isEdit) {
      success = await vm.updateFirm(
        id: widget.firm!.id,
        firmName: _firmNameController.text.trim(),
        proprietorName: _nullIfEmpty(_proprietorNameController.text),
        phoneNumber: _nullIfEmpty(_phoneController.text),
        alternatePhoneNumber: _nullIfEmpty(_altPhoneController.text),
        gstin: _nullIfEmpty(_gstinController.text),
        pan: _nullIfEmpty(_panController.text),
        address: _nullIfEmpty(_addressController.text),
        bankName: _nullIfEmpty(_bankNameController.text),
        bankIfsc: _nullIfEmpty(_bankIfscController.text),
        bankAccountNumber: _nullIfEmpty(_bankAccountNumberController.text),
        bankAccountName: _nullIfEmpty(_bankAccountNameController.text),
      );
    } else {
      success = await vm.createFirm(
        firmName: _firmNameController.text.trim(),
        proprietorName: _nullIfEmpty(_proprietorNameController.text),
        phoneNumber: _nullIfEmpty(_phoneController.text),
        alternatePhoneNumber: _nullIfEmpty(_altPhoneController.text),
        gstin: _nullIfEmpty(_gstinController.text),
        pan: _nullIfEmpty(_panController.text),
        address: _nullIfEmpty(_addressController.text),
        bankName: _nullIfEmpty(_bankNameController.text),
        bankIfsc: _nullIfEmpty(_bankIfscController.text),
        bankAccountNumber: _nullIfEmpty(_bankAccountNumberController.text),
        bankAccountName: _nullIfEmpty(_bankAccountNameController.text),
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Firm updated successfully' : 'Firm created successfully',
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop();
    } else {
      final error = ref.read(firmsViewModelProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(firmsViewModelProvider.notifier).clearMessages();
      }
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(firmsViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Firm' : 'Add Firm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Basic Info ──────────────────────────────────────
              _sectionHeader('Basic Info'),

              CustomTextField(
                label: 'Firm Name',
                hint: 'Enter firm name',
                controller: _firmNameController,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Firm name is required'
                    : null,
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Proprietor Name (optional)',
                hint: 'Enter proprietor name',
                controller: _proprietorNameController,
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Phone Number (optional)',
                hint: 'Enter phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Alternate Phone (optional)',
                hint: 'Enter alternate phone',
                controller: _altPhoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),

              // ── Tax Info ────────────────────────────────────────
              _sectionHeader('Tax Info'),

              CustomTextField(
                label: 'GSTIN (optional)',
                hint: 'Enter GSTIN',
                controller: _gstinController,
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'PAN (optional)',
                hint: 'Enter PAN',
                controller: _panController,
              ),
              const SizedBox(height: 28),

              // ── Address ─────────────────────────────────────────
              _sectionHeader('Address'),

              CustomTextField(
                label: 'Address (optional)',
                hint: 'Enter address',
                controller: _addressController,
              ),
              const SizedBox(height: 28),

              // ── Bank Details ────────────────────────────────────
              _sectionHeader('Bank Details'),

              CustomTextField(
                label: 'Bank Name (optional)',
                hint: 'Enter bank name',
                controller: _bankNameController,
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'IFSC Code (optional)',
                hint: 'Enter IFSC code',
                controller: _bankIfscController,
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Account Number (optional)',
                hint: 'Enter account number',
                controller: _bankAccountNumberController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Account Name (optional)',
                hint: 'Enter account holder name',
                controller: _bankAccountNameController,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(isEdit ? 'Update Firm' : 'Create Firm'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
