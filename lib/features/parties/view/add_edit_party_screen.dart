import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/core/widgets/suggestion_picker_dialog.dart';
import 'package:my_sauda/features/auth/widgets/custom_text_field.dart';
import 'package:my_sauda/features/parties/view_model/parties_view_model.dart';
import '../model/party.dart';

class AddEditPartyScreen extends ConsumerStatefulWidget {
  final Party? party;

  const AddEditPartyScreen({super.key, this.party});

  @override
  ConsumerState<AddEditPartyScreen> createState() => _AddEditPartyScreenState();
}

class _AddEditPartyScreenState extends ConsumerState<AddEditPartyScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _brokerageController;
  late TextEditingController _panController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _altPhoneController;

  String? selectedState;
  String? selectedCity;

  bool get isEdit => widget.party != null;

  /// ✅ LOCAL STATES (no DB)
  final List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  @override
  void initState() {
    super.initState();

    final p = widget.party;

    _nameController = TextEditingController(text: p?.partyName ?? '');
    _brokerageController =
        TextEditingController(text: p?.brokerageRate?.toString() ?? '');
    _panController = TextEditingController(text: p?.panGstin ?? '');
    _addressController = TextEditingController(text: p?.deliveryAddress ?? '');
    _phoneController = TextEditingController(text: p?.phoneNumber ?? '');
    _altPhoneController =
        TextEditingController(text: p?.alternatePhoneNumber ?? '');

    selectedState = p?.state;
    selectedCity = p?.city;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brokerageController.dispose();
    _panController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickState() async {
    final selected = await showSuggestionPicker(
      context: context,
      ref: ref,
      type: 'state',
      title: 'Select State',
      staticOptions: indianStates,
      // 👈 LOCAL
      allowAdd: false, // 👈 NO ADD
    );

    if (selected != null) {
      setState(() => selectedState = selected);
    }
  }

  Future<void> _pickCity() async {
    final selected = await showSuggestionPicker(
      context: context,
      ref: ref,
      type: 'city',
      title: 'Select City',
    );

    if (selected != null) {
      setState(() => selectedCity = selected);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final vm = ref.read(partiesViewModelProvider.notifier);

    final brokerage = _brokerageController.text.trim().isEmpty
        ? null
        : double.tryParse(_brokerageController.text.trim());

    bool success = false;

    if (isEdit) {
      success = await vm.updateParty(
        id: widget.party!.id,
        name: _nameController.text.trim(),
        city: selectedCity!,
        stateName: selectedState!,
        brokerageRate: brokerage,
        panGstin: _panController.text.trim().isEmpty
            ? null
            : _panController.text.trim(),
        deliveryAddress: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        alternatePhoneNumber: _altPhoneController.text.trim().isEmpty
            ? null
            : _altPhoneController.text.trim(),
      );
    } else {
      success = await vm.createParty(
        name: _nameController.text.trim(),
        city: selectedCity!,
        stateName: selectedState!,
        brokerageRate: brokerage,
        panGstin: _panController.text.trim().isEmpty
            ? null
            : _panController.text.trim(),
        deliveryAddress: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        alternatePhoneNumber: _altPhoneController.text.trim().isEmpty
            ? null
            : _altPhoneController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Party updated successfully'
                : 'Party created successfully',
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop();
    } else {
      final error = ref.read(partiesViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Something went wrong. Please try again.'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(partiesViewModelProvider.notifier).clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(partiesViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Party' : 'Add Party'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Party Name',
                hint: 'Enter party name',
                controller: _nameController,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Party name is required'
                    : null,
              ),
              const SizedBox(height: 18),

              /// STATE
              GestureDetector(
                onTap: _pickState,
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: 'State',
                    hint: 'Select state',
                    controller:
                        TextEditingController(text: selectedState ?? ''),
                    validator: (_) =>
                        selectedState == null ? 'State is required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              /// CITY
              GestureDetector(
                onTap: _pickCity,
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: 'City',
                    hint: 'Select city',
                    controller: TextEditingController(text: selectedCity ?? ''),
                    validator: (_) =>
                        selectedCity == null ? 'City is required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Brokerage Rate (optional)',
                hint: 'Enter rate',
                controller: _brokerageController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'PAN / GSTIN (optional)',
                hint: 'Enter PAN or GSTIN',
                controller: _panController,
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Phone Number (optional)',
                hint: 'Enter 10-digit phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (v.trim().length != 10) return 'Phone number must be 10 digits';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Alternate Phone (optional)',
                hint: 'Enter alternate phone number',
                controller: _altPhoneController,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (v.trim().length != 10) return 'Phone number must be 10 digits';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Delivery Address (optional)',
                hint: 'Enter address',
                controller: _addressController,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                child: SizedBox(
                    width: double.infinity,
                    child: Center(
                        child: Text(isEdit ? 'Update Party' : 'Create Party'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
