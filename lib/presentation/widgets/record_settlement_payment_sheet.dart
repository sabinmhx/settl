import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/settlement_payment.dart';
import '../../domain/usecases/save_settlement_payment.dart';

/// Bottom sheet to record or edit a partial/full settlement payment.
Future<SaveSettlementPaymentParams?> showRecordSettlementPaymentSheet({
  required BuildContext context,
  required String groupId,
  required String fromId,
  required String toId,
  required String fromName,
  required String toName,
  required double maxAmount,
  SettlementPayment? existing,
}) {
  return showModalBottomSheet<SaveSettlementPaymentParams>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _RecordPaymentSheet(
      groupId: groupId,
      fromId: fromId,
      toId: toId,
      fromName: fromName,
      toName: toName,
      maxAmount: maxAmount,
      existing: existing,
    ),
  );
}

class _RecordPaymentSheet extends StatefulWidget {
  const _RecordPaymentSheet({
    required this.groupId,
    required this.fromId,
    required this.toId,
    required this.fromName,
    required this.toName,
    required this.maxAmount,
    this.existing,
  });

  final String groupId;
  final String fromId;
  final String toId;
  final String fromName;
  final String toName;
  final double maxAmount;
  final SettlementPayment? existing;

  @override
  State<_RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends State<_RecordPaymentSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  double _amount = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.existing?.amount ??
        (widget.maxAmount > 0.01 ? widget.maxAmount : 10.0);
    _amount = double.parse(initial.toStringAsFixed(2));
    _amountCtrl = TextEditingController(text: _amount.toStringAsFixed(2));
    _noteCtrl = TextEditingController(text: widget.existing?.note ?? '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _setAmount(double value) {
    final v = value < 0.01 ? 0.01 : value;
    setState(() {
      _amount = double.parse(v.toStringAsFixed(2));
      _amountCtrl.text = _amount.toStringAsFixed(2);
    });
  }

  SaveSettlementPaymentParams _buildParams() => SaveSettlementPaymentParams(
        groupId: widget.groupId,
        fromId: widget.fromId,
        toId: widget.toId,
        amount: _amount,
        note: _noteCtrl.text,
        existingId: widget.existing?.id,
        createdAt: widget.existing?.createdAt,
      );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isEdit ? 'Edit payment' : 'Record payment',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.fromName} pays ${widget.toName}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (widget.maxAmount > 0.01 && !isEdit) ...[
            const SizedBox(height: 4),
            Text(
              'Up to ${formatMoney(widget.maxAmount)} owed',
              style: const TextStyle(color: AppColors.warning, fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => _setAmount(_amount - 5),
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    border: InputBorder.none,
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v.replaceAll(',', ''));
                    if (parsed != null && parsed > 0) {
                      setState(() => _amount = parsed);
                    }
                  },
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => _setAmount(_amount + 5),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.maxAmount > 0.01 && !isEdit)
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('25%'),
                  onPressed: () => _setAmount(widget.maxAmount * 0.25),
                ),
                ActionChip(
                  label: const Text('50%'),
                  onPressed: () => _setAmount(widget.maxAmount * 0.50),
                ),
                ActionChip(
                  label: const Text('Pay full'),
                  onPressed: () => _setAmount(widget.maxAmount),
                ),
              ],
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'Cash, Venmo, etc.',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _amount <= 0
                ? null
                : () => Navigator.pop(context, _buildParams()),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(isEdit ? 'Update payment' : 'Record ${formatMoney(_amount)}'),
          ),
        ],
      ),
    );
  }
}
