import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member.dart';
import '../blocs/expense_form/expense_form_cubit.dart';

class ExpenseFormPage extends StatelessWidget {
  const ExpenseFormPage({
    super.key,
    required this.groupId,
    this.expenseToEdit,
  });

  final String groupId;
  final Expense? expenseToEdit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseFormCubit, ExpenseFormState>(
      builder: (context, state) {
        if (state.status == ExpenseFormStatus.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        final group = state.group;
        if (group == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Group not found')),
          );
        }
        return _ExpenseFormBody(
          group: group,
          state: state,
          expenseToEdit: expenseToEdit,
        );
      },
    );
  }
}

class _ExpenseFormBody extends StatefulWidget {
  const _ExpenseFormBody({
    required this.group,
    required this.state,
    this.expenseToEdit,
  });

  final Group group;
  final ExpenseFormState state;
  final Expense? expenseToEdit;

  @override
  State<_ExpenseFormBody> createState() => _ExpenseFormBodyState();
}

class _ExpenseFormBodyState extends State<_ExpenseFormBody> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.state.title);
    _amountCtrl = TextEditingController(text: widget.state.amountText);
    _noteCtrl = TextEditingController(text: widget.state.note);
  }

  @override
  void didUpdateWidget(_ExpenseFormBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.title != _titleCtrl.text) _titleCtrl.text = widget.state.title;
    if (widget.state.amountText != _amountCtrl.text) {
      _amountCtrl.text = widget.state.amountText;
    }
    if (widget.state.note != _noteCtrl.text) _noteCtrl.text = widget.state.note;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<ExpenseFormCubit>();
    final ok = await cubit.submit();
    if (ok && context.mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExpenseFormCubit>();
    final state = widget.state;
    final group = widget.group;
    final isSubmitting = state.status == ExpenseFormStatus.submitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isEditing ? 'Edit Expense' : 'New Expense'),
        actions: [
          if (state.isEditing && widget.expenseToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete expense?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (ok == true && context.mounted) {
                        await cubit.delete(widget.expenseToEdit!);
                        if (context.mounted) context.pop(true);
                      }
                    },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          if (state.validationMessage != null) ...[
            _Banner(message: state.validationMessage!, isError: true),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _titleCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'What was this for?',
              hintText: 'Dinner, groceries, rent…',
            ),
            onChanged: cubit.setTitle,
          ),
          const SizedBox(height: 24),
          const Text(
            'Total price',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: '0.00',
              filled: true,
              fillColor: AppColors.primary.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: cubit.setAmount,
          ),
          if (state.totalAmount > 0 && state.splitMemberIds.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Who shared this?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'Only include people who actually participated.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: group.members.map((m) {
                final selected = state.splitMemberIds.contains(m.id);
                return FilterChip(
                  label: Text(m.name),
                  selected: selected,
                  avatar: CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(m.colorHex),
                    child: Text(
                      m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  onSelected: (v) => cubit.toggleSplitMember(m.id, v),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SegmentedButton<SplitMode>(
              segments: const [
                ButtonSegment(
                  value: SplitMode.equal,
                  label: Text('Split equally'),
                  icon: Icon(Icons.pie_chart_outline, size: 18),
                ),
                ButtonSegment(
                  value: SplitMode.custom,
                  label: Text('Custom amounts'),
                  icon: Icon(Icons.tune, size: 18),
                ),
              ],
              selected: {state.splitMode},
              onSelectionChanged: (s) => cubit.setSplitMode(s.first),
            ),
            const SizedBox(height: 12),
            if (state.splitMode == SplitMode.equal)
              _Banner(
                message:
                    '${formatMoney(state.equalSharePerPerson)} each for '
                    '${state.splitMemberIds.length} '
                    '${state.splitMemberIds.length == 1 ? 'person' : 'people'}',
                isError: false,
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'What each person owes',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: cubit.splitSharesEvenly,
                    child: const Text('Reset equal'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...group.members
                  .where((m) => state.splitMemberIds.contains(m.id))
                  .map(
                    (m) => _SplitRow(
                      member: m,
                      amountText: state.splitAmountTexts[m.id] ?? '',
                      onChanged: (v) => cubit.setSplitAmount(m.id, v),
                    ),
                  ),
              if (state.splitAssignedTotal > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Assigned ${formatMoney(state.splitAssignedTotal)} of '
                  '${formatMoney(state.totalAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: (state.splitAssignedTotal - state.totalAmount).abs() > 0.02
                        ? AppColors.warning
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Who paid?',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              TextButton(
                onPressed:
                    state.totalAmount > 0 ? cubit.splitContributionsEvenly : null,
                child: const Text('Split evenly'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter each person\'s contribution below (must equal total).',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ...group.members.map(
            (m) => _PayerRow(
              member: m,
              amountText: state.payerAmountTexts[m.id] ?? '',
              onChanged: (v) => cubit.setPayerAmount(m.id, v),
              onPaidAll: () => cubit.assignFullTotalToPayer(m.id),
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<ExpenseCategory>(
            initialValue: state.category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: ExpenseCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (v) => cubit.setCategory(v ?? ExpenseCategory.other),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(labelText: 'Note (optional)'),
            maxLines: 2,
            onChanged: cubit.setNote,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(
            onPressed: isSubmitting || !state.canSubmit
                ? null
                : () => _save(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(state.isEditing ? 'Save changes' : 'Add expense'),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.danger : AppColors.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: TextStyle(color: color, fontSize: 13),
      ),
    );
  }
}

class _SplitRow extends StatefulWidget {
  const _SplitRow({
    required this.member,
    required this.amountText,
    required this.onChanged,
  });

  final Member member;
  final String amountText;
  final ValueChanged<String> onChanged;

  @override
  State<_SplitRow> createState() => _SplitRowState();
}

class _SplitRowState extends State<_SplitRow> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.amountText);
  }

  @override
  void didUpdateWidget(_SplitRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amountText != _ctrl.text) _ctrl.text = widget.amountText;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(widget.member.colorHex),
            child: Text(
              widget.member.name.isNotEmpty
                  ? widget.member.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text('${widget.member.name} owes')),
          SizedBox(
            width: 96,
            child: TextField(
              controller: _ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                isDense: true,
                prefixText: '\$ ',
                hintText: '0',
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayerRow extends StatefulWidget {
  const _PayerRow({
    required this.member,
    required this.amountText,
    required this.onChanged,
    required this.onPaidAll,
  });

  final Member member;
  final String amountText;
  final ValueChanged<String> onChanged;
  final VoidCallback onPaidAll;

  @override
  State<_PayerRow> createState() => _PayerRowState();
}

class _PayerRowState extends State<_PayerRow> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.amountText);
  }

  @override
  void didUpdateWidget(_PayerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amountText != _ctrl.text) _ctrl.text = widget.amountText;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active =
        (double.tryParse(widget.amountText.replaceAll(',', '')) ?? 0) > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(widget.member.colorHex),
            child: Text(
              widget.member.name.isNotEmpty
                  ? widget.member.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(widget.member.name)),
          SizedBox(
            width: 96,
            child: TextField(
              controller: _ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                isDense: true,
                prefixText: '\$ ',
                hintText: '0',
                filled: active,
                fillColor: active
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : null,
              ),
              onChanged: widget.onChanged,
            ),
          ),
          IconButton(
            tooltip: 'Paid full amount',
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.check_circle_outline,
              size: 20,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: widget.onPaidAll,
          ),
        ],
      ),
    );
  }
}
