import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/core/utils/image_share_helper.dart';
import 'package:my_sauda/core/utils/widget_image.dart';
import 'package:my_sauda/core/widgets/suggestion_picker_dialog.dart';
import 'package:my_sauda/features/parties/model/party.dart';
import 'package:my_sauda/features/sauda/model/item.dart';
import 'package:my_sauda/features/sauda/model/new_sauda_preset.dart';
import 'package:my_sauda/features/sauda/model/sauda.dart';
import 'package:my_sauda/features/sauda/model/unit.dart';
import 'package:my_sauda/features/sauda/view_model/sauda_defaults_view_model.dart';
import 'package:my_sauda/features/sauda/view_model/saudas_view_model.dart';
import 'package:my_sauda/features/sauda/view_model/units_view_model.dart';
import 'package:my_sauda/features/sauda/widgets/item_picker_dialog.dart';
import 'package:my_sauda/features/sauda/widgets/party_picker_dialog.dart';
import 'package:my_sauda/features/sauda/widgets/sauda_share_card.dart';

class AddEditSaudaScreen extends ConsumerStatefulWidget {
  final Sauda? sauda;
  final NewSaudaPreset? preset;

  const AddEditSaudaScreen({super.key, this.sauda, this.preset});

  @override
  ConsumerState<AddEditSaudaScreen> createState() => _AddEditSaudaScreenState();
}

class _AddEditSaudaScreenState extends ConsumerState<AddEditSaudaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;

  // Contract details
  late DateTime _saudaDate;

  // Item & Quantity
  Item? _selectedItem;
  final _quantityController = TextEditingController();
  Unit? _selectedUnit;
  final _bagTypeController = TextEditingController();
  final _numberOfBagsController = TextEditingController();

  // Rate
  final _rateController = TextEditingController();

  // Buyer
  Party? _selectedBuyerParty;
  final _buyerBrokerageRateController = TextEditingController();
  final _buyerSideBrokerageController = TextEditingController();

  // Seller
  Party? _selectedSellerParty;
  final _sellerBrokerageRateController = TextEditingController();
  final _sellerSideBrokerageController = TextEditingController();

  // Remarks & Conditions
  final _quantityRemarksController = TextEditingController();
  final _specificationController = TextEditingController();
  final _loadingConditionController = TextEditingController();
  final _paymentConditionController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _additionalRemarksController = TextEditingController();

  // Optional details remembered for next time and shown on the shared image
  final _firmNameController = TextEditingController();
  final _termsController = TextEditingController();

  // Options
  bool _sendToParties = false;

  bool get _isEdit => widget.sauda != null;

  bool get _buyerLocked => widget.preset?.buyer != null;
  bool get _sellerLocked => widget.preset?.seller != null;

  @override
  void initState() {
    super.initState();
    _saudaDate = DateTime.now();
    Future.microtask(() async {
      await ref.read(unitsViewModelProvider.notifier).loadUnits();
      _initializeForEdit();
      _applyPreset();
    });
    Future.microtask(_loadDefaults);
  }

  Future<void> _loadDefaults() async {
    final defaults =
        await ref.read(saudaDefaultsViewModelProvider.notifier).loadDefaults();
    if (!mounted) return;
    if (_firmNameController.text.isEmpty) {
      _firmNameController.text = defaults.firmName;
    }
    if (_termsController.text.isEmpty) {
      _termsController.text = defaults.terms;
    }
  }

  void _applyPreset() {
    final preset = widget.preset;
    if (preset == null || !mounted) return;
    final buyer = preset.buyer;
    final seller = preset.seller;

    if (buyer != null) {
      _selectedBuyerParty = buyer;
      if (buyer.brokerageRate != null) {
        _buyerBrokerageRateController.text =
            buyer.brokerageRate!.toStringAsFixed(2);
      }
    }
    if (seller != null) {
      _selectedSellerParty = seller;
      if (seller.brokerageRate != null) {
        _sellerBrokerageRateController.text =
            seller.brokerageRate!.toStringAsFixed(2);
      }
    }
    _recalculateBrokerage();
  }

  void _initializeForEdit() {
    if (!_isEdit || _initialized) return;
    final s = widget.sauda!;

    _saudaDate = s.saudaDate;
    _quantityController.text = s.quantity.toString();
    _bagTypeController.text = s.bagType ?? '';
    _numberOfBagsController.text = s.numberOfBags?.toString() ?? '';
    _rateController.text = s.ratePerQuintal;
    _buyerBrokerageRateController.text = s.buyerBrokerageRate?.toString() ?? '';
    _buyerSideBrokerageController.text = s.buyerSideBrokerage.toString();
    _sellerBrokerageRateController.text =
        s.sellerBrokerageRate?.toString() ?? '';
    _sellerSideBrokerageController.text = s.sellerSideBrokerage.toString();
    _quantityRemarksController.text = s.quantityRemarks ?? '';
    _specificationController.text = s.specification ?? '';
    _loadingConditionController.text = s.loadingCondition ?? '';
    _paymentConditionController.text = s.paymentCondition ?? '';
    _deliveryAddressController.text = s.deliveryAddress ?? '';
    _additionalRemarksController.text = s.additionalRemarks ?? '';
    _sendToParties = s.sendToParties;

    // Restore item, unit, buyer, seller from joined data on sauda
    final units = ref.read(unitsViewModelProvider).units;
    if (units.isNotEmpty) {
      try {
        _selectedUnit = units.firstWhere((u) => u.id == s.unitId);
      } catch (_) {}
    }

    if (s.itemName != null) {
      _selectedItem = Item(
        id: s.itemId,
        userId: '',
        name: s.itemName!,
        createdAt: DateTime.now(),
      );
    }

    if (s.buyerPartyName != null) {
      _selectedBuyerParty = Party(
        id: s.buyerPartyId,
        userId: '',
        partyCode: s.buyerPartyCode ?? '',
        panGstin: s.buyerPartyGstin,
        deliveryAddress: s.buyerPartyAddress,
        partyName: s.buyerPartyName!,
        brokerageRate: s.buyerBrokerageRate,
        city: s.buyerPartyCity ?? '',
        state: s.buyerPartyState ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    if (s.sellerPartyName != null) {
      _selectedSellerParty = Party(
        id: s.sellerPartyId,
        userId: '',
        partyCode: s.sellerPartyCode ?? '',
        panGstin: s.sellerPartyGstin,
        deliveryAddress: s.sellerPartyAddress,
        partyName: s.sellerPartyName!,
        brokerageRate: s.sellerBrokerageRate,
        city: s.sellerPartyCity ?? '',
        state: s.sellerPartyState ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    _initialized = true;
    setState(() {});
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _bagTypeController.dispose();
    _numberOfBagsController.dispose();
    _rateController.dispose();
    _buyerBrokerageRateController.dispose();
    _buyerSideBrokerageController.dispose();
    _sellerBrokerageRateController.dispose();
    _sellerSideBrokerageController.dispose();
    _quantityRemarksController.dispose();
    _specificationController.dispose();
    _loadingConditionController.dispose();
    _paymentConditionController.dispose();
    _deliveryAddressController.dispose();
    _additionalRemarksController.dispose();
    _firmNameController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  // Converts 1 unit of [unitName] into kilograms (e.g. 1 ton = 1000 kg,
  // 1 quintal = 100 kg, 1 kg = 1 kg).
  double _kgPerUnit(String? unitName) {
    final name = unitName?.toLowerCase().trim() ?? '';
    if (name.contains('ton')) return 1000;
    if (name.contains('quintal')) return 100;
    return 1;
  }

  double _totalKg() {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    return qty * _kgPerUnit(_selectedUnit?.name);
  }

  void _recalculateBrokerage() {
    final qtyInQuintals = _totalKg() / 100;

    final buyerRate = double.tryParse(_buyerBrokerageRateController.text) ?? 0;
    final sellerRate =
        double.tryParse(_sellerBrokerageRateController.text) ?? 0;

    _buyerSideBrokerageController.text =
        (qtyInQuintals * buyerRate).toStringAsFixed(2);
    _sellerSideBrokerageController.text =
        (qtyInQuintals * sellerRate).toStringAsFixed(2);

    setState(() {});
  }

  // Extracts the bag weight in kg from the bag type text (e.g. "50 kg" -> 50).
  double? _bagWeightKg() {
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(_bagTypeController.text);
    if (match == null) return null;
    return double.tryParse(match.group(0)!);
  }

  void _recalculateBags() {
    final totalKg = _totalKg();
    final bagWeight = _bagWeightKg();

    if (totalKg > 0 && bagWeight != null && bagWeight > 0) {
      final bags = totalKg / bagWeight;
      _numberOfBagsController.text =
          bags % 1 == 0 ? bags.toStringAsFixed(0) : bags.toStringAsFixed(2);
    }

    setState(() {});
  }

  String? _nullIfEmpty(String value) {
    final v = value.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _saudaDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _saudaDate = picked);
    }
  }

  Future<void> _pickBuyerParty() async {
    final party = await showPartyPicker(
      context: context,
      ref: ref,
      title: 'Select Buyer',
      allowAdd: true,
    );
    if (party != null) {
      setState(() {
        _selectedBuyerParty = party;
        if (party.brokerageRate != null) {
          _buyerBrokerageRateController.text =
              party.brokerageRate!.toStringAsFixed(2);
        }
      });
      _recalculateBrokerage();
    }
  }

  Future<void> _pickSellerParty() async {
    final party = await showPartyPicker(
      context: context,
      ref: ref,
      title: 'Select Seller',
      allowAdd: true,
    );
    if (party != null) {
      setState(() {
        _selectedSellerParty = party;
        if (party.brokerageRate != null) {
          _sellerBrokerageRateController.text =
              party.brokerageRate!.toStringAsFixed(2);
        }
      });
      _recalculateBrokerage();
    }
  }

  Future<void> _pickItem() async {
    final item = await showItemPicker(context: context, ref: ref);
    if (item != null) {
      setState(() => _selectedItem = item);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItem == null) {
      _showError('Please select an item.');
      return;
    }
    if (_selectedUnit == null) {
      _showError('Please select a unit.');
      return;
    }
    if (_selectedBuyerParty == null) {
      _showError('Please select a buyer party.');
      return;
    }
    if (_selectedSellerParty == null) {
      _showError('Please select a seller party.');
      return;
    }

    final vm = ref.read(saudasViewModelProvider.notifier);

    final qty = double.parse(_quantityController.text.trim());
    final rate = _rateController.text.trim();
    final buyerBrokerage =
        double.tryParse(_buyerSideBrokerageController.text.trim()) ?? 0;
    final sellerBrokerage =
        double.tryParse(_sellerSideBrokerageController.text.trim()) ?? 0;
    final bags = double.tryParse(_numberOfBagsController.text.trim());

    final totalKg = _totalKg();

    Sauda? result;
    if (_isEdit) {
      result = await vm.updateSauda(
        saudaId: widget.sauda!.id,
        saudaDate: _saudaDate,
        itemId: _selectedItem!.id,
        quantity: qty,
        totalKg: totalKg,
        unitId: _selectedUnit!.id,
        bagType: _nullIfEmpty(_bagTypeController.text),
        numberOfBags: bags,
        ratePerQuintal: rate,
        buyerPartyId: _selectedBuyerParty!.id,
        buyerSideBrokerage: buyerBrokerage,
        sellerPartyId: _selectedSellerParty!.id,
        sellerSideBrokerage: sellerBrokerage,
        quantityRemarks: _nullIfEmpty(_quantityRemarksController.text),
        specification: _nullIfEmpty(_specificationController.text),
        loadingCondition: _nullIfEmpty(_loadingConditionController.text),
        paymentCondition: _nullIfEmpty(_paymentConditionController.text),
        deliveryAddress: _nullIfEmpty(_deliveryAddressController.text),
        additionalRemarks: _nullIfEmpty(_additionalRemarksController.text),
        sendToParties: _sendToParties,
      );
    } else {
      result = await vm.createSauda(
        saudaDate: _saudaDate,
        itemId: _selectedItem!.id,
        quantity: qty,
        totalKg: totalKg,
        unitId: _selectedUnit!.id,
        bagType: _nullIfEmpty(_bagTypeController.text),
        numberOfBags: bags,
        ratePerQuintal: rate,
        buyerPartyId: _selectedBuyerParty!.id,
        buyerSideBrokerage: buyerBrokerage,
        sellerPartyId: _selectedSellerParty!.id,
        sellerSideBrokerage: sellerBrokerage,
        quantityRemarks: _nullIfEmpty(_quantityRemarksController.text),
        specification: _nullIfEmpty(_specificationController.text),
        loadingCondition: _nullIfEmpty(_loadingConditionController.text),
        paymentCondition: _nullIfEmpty(_paymentConditionController.text),
        deliveryAddress: _nullIfEmpty(_deliveryAddressController.text),
        additionalRemarks: _nullIfEmpty(_additionalRemarksController.text),
        sendToParties: _sendToParties,
      );
    }

    if (!mounted) return;

    if (result != null) {
      await ref.read(saudaDefaultsViewModelProvider.notifier).saveDefaults(
            firmName: _firmNameController.text,
            terms: _termsController.text,
          );
      if (!mounted) return;
      if (widget.preset != null) {
        context.pop(_createdWithEnteredRates(result));
        return;
      }
      if (_sendToParties) {
        await _shareImage(result);
        if (!mounted) return;
      }
      context.pop();
    } else {
      final error = ref.read(saudasViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error ?? 'Something went wrong. Please try again.'),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ));
      ref.read(saudasViewModelProvider.notifier).clearMessages();
    }
  }

  // A sauda only stores the brokerage amount, so the rates typed in this form
  // are re-attached for the caller instead of the parties' default rates.
  Sauda _createdWithEnteredRates(Sauda created) {
    final joined = ref
        .read(saudasViewModelProvider)
        .allSaudas
        .where((s) => s.id == created.id)
        .firstOrNull;
    return (joined ?? created).copyWith(
      buyerBrokerageRate:
          double.tryParse(_buyerBrokerageRateController.text.trim()) ?? 0,
      sellerBrokerageRate:
          double.tryParse(_sellerBrokerageRateController.text.trim()) ?? 0,
    );
  }

  // GSTIN, then "delivery address, city, state" with any missing part skipped.
  List<String> _partyDetails(Party? party) {
    if (party == null) return const [];
    final gstin = party.panGstin?.trim() ?? '';
    final address = [party.deliveryAddress, party.city, party.state]
        .map((part) => part?.trim() ?? '')
        .where((part) => part.isNotEmpty)
        .join(', ');
    return [
      if (gstin.isNotEmpty) 'GSTIN: $gstin',
      if (address.isNotEmpty) address,
    ];
  }

  // One image goes to both parties, so it carries no brokerage.
  List<ShareRow> _shareRows() {
    final rows = <ShareRow>[
      ShareRow(label: 'Item', value: _selectedItem?.name ?? '-'),
      ShareRow(
        label: 'Quantity',
        value: '${_quantityController.text.trim()} ${_selectedUnit?.name ?? ''}'
            .trim(),
      ),
      if (_bagTypeController.text.trim().isNotEmpty)
        ShareRow(
          label: 'Bags',
          value:
              '${_numberOfBagsController.text.trim()} x ${_bagTypeController.text.trim()}',
        ),
      ShareRow(
        label: 'Rate',
        value: parseNumericRate(_rateController.text) == null
            ? _rateController.text.trim()
            : '₹${_rateController.text.trim()} / quintal',
      ),
      ShareRow(
        label: 'Buyer',
        value: _selectedBuyerParty?.partyName ?? '-',
        details: _partyDetails(_selectedBuyerParty),
      ),
      ShareRow(
        label: 'Seller',
        value: _selectedSellerParty?.partyName ?? '-',
        details: _partyDetails(_selectedSellerParty),
      ),
    ];

    void addIfFilled(String label, TextEditingController controller) {
      final value = controller.text.trim();
      if (value.isNotEmpty) rows.add(ShareRow(label: label, value: value));
    }

    addIfFilled('Quantity Remarks', _quantityRemarksController);
    addIfFilled('Specification', _specificationController);
    addIfFilled('Loading', _loadingConditionController);
    addIfFilled('Payment', _paymentConditionController);
    addIfFilled('Delivery Address', _deliveryAddressController);
    addIfFilled('Remarks', _additionalRemarksController);
    return rows;
  }

  Future<void> _shareImage(Sauda sauda) async {
    final card = SaudaShareCard(
      title:
          'Sauda Confirmation${sauda.saudaNumber.isNotEmpty ? ' - #${sauda.saudaNumber}' : ''}',
      date: _formatDate(_saudaDate),
      rows: _shareRows(),
      firmName: _nullIfEmpty(_firmNameController.text),
      terms: _nullIfEmpty(_termsController.text),
    );

    try {
      final png = await renderWidgetToPng(context, card);
      if (!mounted) return;
      await ImageShareHelper.shareImage(
        context: context,
        bytes: png,
        fileName:
            'sauda_${sauda.saudaNumber.isEmpty ? sauda.id : sauda.saudaNumber}.png',
      );
    } catch (e) {
      debugPrint('[AddEditSaudaScreen] share image error: $e');
      if (!mounted) return;
      _showError('Could not create the image. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.errorColor,
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryColor,
            ),
      ),
    );
  }

  Widget _pickerField({
    required String label,
    required String? value,
    required VoidCallback? onTap,
    bool required = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon:
                onTap == null ? null : const Icon(Icons.arrow_drop_down),
          ),
          controller: TextEditingController(text: value ?? ''),
          validator: required
              ? (v) => (v == null || v.isEmpty) ? 'Required' : null
              : null,
        ),
      ),
    );
  }

  Widget _suggestionField({
    required TextEditingController controller,
    required String label,
    required String type,
    bool isRequired = false,
    VoidCallback? onPicked,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showSuggestionPicker(
          context: context,
          ref: ref,
          type: type,
          title: label,
        );
        if (picked != null) {
          controller.text = picked;
          setState(() {});
          onPicked?.call();
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          validator: isRequired
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saudasViewModelProvider);
    final unitsState = ref.watch(unitsViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Sauda' : 'New Sauda'),
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              if (_isEdit && widget.sauda!.saudaNumber.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long,
                          color: AppTheme.primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Sauda #${widget.sauda!.saudaNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Contract Details ──────────────────────────
              _sectionHeader('Contract Details'),

              TextFormField(
                controller: _firmNameController,
                decoration: const InputDecoration(
                  labelText: 'Firm Name (optional)',
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Sauda Date *',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller:
                        TextEditingController(text: _formatDate(_saudaDate)),
                    validator: (_) => null,
                  ),
                ),
              ),

              // ── Item & Quantity ───────────────────────────
              _sectionHeader('Item & Quantity'),

              _pickerField(
                label: 'Item *',
                value: _selectedItem?.name,
                onTap: _pickItem,
                required: true,
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration:
                          const InputDecoration(labelText: 'Quantity *'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                      onChanged: (_) {
                        _recalculateBrokerage();
                        _recalculateBags();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: unitsState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Unit *',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Unit>(
                                value: _selectedUnit,
                                isExpanded: true,
                                isDense: true,
                                hint: const Text('Select'),
                                items: unitsState.units
                                    .map((u) => DropdownMenuItem(
                                          value: u,
                                          child: Text(u.name),
                                        ))
                                    .toList(),
                                onChanged: (u) {
                                  setState(() => _selectedUnit = u);
                                  _recalculateBrokerage();
                                  _recalculateBags();
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _suggestionField(
                      controller: _bagTypeController,
                      label: 'Bag Type',
                      type: 'bag_type',
                      onPicked: _recalculateBags,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _numberOfBagsController,
                      decoration:
                          const InputDecoration(labelText: 'No. of Bags'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v != null &&
                            v.trim().isNotEmpty &&
                            double.tryParse(v.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // ── Rate ─────────────────────────────────────
              _sectionHeader('Rate'),

              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Rate per Quintal (₹) *',
                  hintText: 'e.g. 4525',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),

              // ── Buyer ─────────────────────────────────────
              _sectionHeader('Buyer'),

              _pickerField(
                label: 'Buyer Party *',
                value: _selectedBuyerParty?.partyName,
                onTap: _buyerLocked ? null : _pickBuyerParty,
                required: true,
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _buyerBrokerageRateController,
                      decoration: const InputDecoration(
                          labelText: 'Buyer Brokerage Rate (₹/qtl)'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _recalculateBrokerage(),
                      validator: (v) {
                        if (v != null &&
                            v.trim().isNotEmpty &&
                            double.tryParse(v.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _buyerSideBrokerageController,
                      decoration: InputDecoration(
                        labelText: 'Buyer Brokerage (₹)',
                        filled: true,
                        fillColor:
                            AppTheme.primaryColor.withValues(alpha: 0.05),
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),

              // ── Seller ────────────────────────────────────
              _sectionHeader('Seller'),

              _pickerField(
                label: 'Seller Party *',
                value: _selectedSellerParty?.partyName,
                onTap: _sellerLocked ? null : _pickSellerParty,
                required: true,
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sellerBrokerageRateController,
                      decoration: const InputDecoration(
                          labelText: 'Seller Brokerage Rate (₹/qtl)'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _recalculateBrokerage(),
                      validator: (v) {
                        if (v != null &&
                            v.trim().isNotEmpty &&
                            double.tryParse(v.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sellerSideBrokerageController,
                      decoration: InputDecoration(
                        labelText: 'Seller Brokerage (₹)',
                        filled: true,
                        fillColor:
                            AppTheme.primaryColor.withValues(alpha: 0.05),
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),

              // ── Remarks & Conditions ──────────────────────
              _sectionHeader('Remarks & Conditions'),

              _suggestionField(
                controller: _quantityRemarksController,
                label: 'Quantity Remarks',
                type: 'quantity_remarks',
              ),

              const SizedBox(height: 14),

              _suggestionField(
                controller: _specificationController,
                label: 'Specification',
                type: 'specification',
              ),

              const SizedBox(height: 14),

              _suggestionField(
                controller: _loadingConditionController,
                label: 'Loading Condition',
                type: 'loading_condition',
              ),

              const SizedBox(height: 14),

              _suggestionField(
                controller: _paymentConditionController,
                label: 'Payment Condition',
                type: 'payment_condition',
              ),

              const SizedBox(height: 14),

              _suggestionField(
                controller: _deliveryAddressController,
                label: 'Delivery Address',
                type: 'delivery_address',
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _additionalRemarksController,
                decoration:
                    const InputDecoration(labelText: 'Additional Remarks'),
                maxLines: 3,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _termsController,
                decoration: const InputDecoration(
                  labelText: 'Terms & Conditions (optional)',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),

              // ── Options ───────────────────────────────────
              if (widget.preset == null) ...[
                _sectionHeader('Options'),
                SwitchListTile(
                  value: _sendToParties,
                  onChanged: (v) => setState(() => _sendToParties = v),
                  title: const Text('Send to Parties'),
                  subtitle:
                      const Text('Share this sauda with buyer and seller'),
                  activeThumbColor: AppTheme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: state.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _isEdit ? 'Update Sauda' : 'Create Sauda',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }
}
