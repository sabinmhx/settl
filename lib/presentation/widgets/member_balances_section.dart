import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/balance_breakdown.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/settlement_payment.dart';
import '../../domain/usecases/save_settlement_payment.dart';
import '../../domain/services/balance_breakdown_service.dart';
import 'record_settlement_payment_sheet.dart';

/// UI helpers for balance / debt display.
class BalanceDisplay {
  static String pairLine({
    required String fromName,
    required String toName,
    required MemberPairBalance balance,
  }) {
    if (balance.remaining > 0.01) {
      final parts = <String>[];
      if (balance.expensePaid > 0.01) {
        parts.add('${formatMoney(balance.expensePaid)} via expenses');
      }
      if (balance.settlementPaid > 0.01) {
        parts.add('${formatMoney(balance.settlementPaid)} settled');
      }
      final paidDetail = parts.isEmpty ? '' : ' (${parts.join(', ')})';
      return '$fromName owes $toName ${formatMoney(balance.remaining)}$paidDetail';
    }
    return '$fromName paid $toName ${formatMoney(balance.totalPaid)}';
  }

  static String expenseMemberLine({
    required String memberName,
    required ExpenseMemberBalance balance,
  }) {
    if (balance.remainingOwed <= 0.01) {
      if (balance.paidAmount > 0.01) {
        return '$memberName paid ${formatMoney(balance.paidAmount)} · settled';
      }
      return '$memberName · share ${formatMoney(balance.shareOwed)}';
    }
    return '$memberName owes ${formatMoney(balance.remainingOwed)} '
        '(share ${formatMoney(balance.shareOwed)}, paid ${formatMoney(balance.paidAmount)})';
  }
}

class MemberBalancesSection extends StatefulWidget {
  const MemberBalancesSection({
    super.key,
    required this.group,
    required this.expenses,
    this.payments = const [],
    this.onSavePayment,
  });

  final Group group;
  final List<Expense> expenses;
  final List<SettlementPayment> payments;
  final Future<void> Function(SaveSettlementPaymentParams params)? onSavePayment;

  @override
  State<MemberBalancesSection> createState() => _MemberBalancesSectionState();
}

class _MemberBalancesSectionState extends State<MemberBalancesSection> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    if (widget.group.members.isNotEmpty) {
      _selectedId = widget.group.members.first.id;
    }
  }

  Map<String, String> get _names =>
      {for (final m in widget.group.members) m.id: m.name};

  @override
  Widget build(BuildContext context) {
    if (widget.expenses.isEmpty || widget.group.members.isEmpty) {
      return const SizedBox.shrink();
    }

    final summaries = BalanceBreakdownService.memberSummaries(
      memberIds: widget.group.members.map((m) => m.id).toList(),
      expenses: widget.expenses,
      payments: widget.payments,
    );
    final selected = summaries.firstWhere(
      (s) => s.memberId == _selectedId,
      orElse: () => summaries.first,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 20, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Who owes whom',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Includes partial payments — remaining is what\'s still owed.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.group.members.map((m) {
                  final sel = _selectedId == m.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(m.name),
                      selected: sel,
                      onSelected: (_) => setState(() => _selectedId = m.id),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _NetBanner(name: _names[selected.memberId] ?? '', net: selected.netBalance),
            const SizedBox(height: 12),
            if (selected.owedBy.isNotEmpty) ...[
              _SectionLabel(title: '${_names[selected.memberId]} is owed'),
              ...selected.owedBy.map(
                (p) => _BalanceLine(
                  text: BalanceDisplay.pairLine(
                    fromName: _names[p.fromId] ?? p.fromId,
                    toName: _names[p.toId] ?? p.toId,
                    balance: p,
                  ),
                  amount: p.remaining,
                  positive: true,
                ),
              ),
            ],
            if (selected.owesTo.isNotEmpty) ...[
              _SectionLabel(title: '${_names[selected.memberId]} owes'),
              ...selected.owesTo.map(
                (p) => _DebtRow(
                  balance: p,
                  names: _names,
                  groupId: widget.group.id,
                  onSavePayment: widget.onSavePayment,
                ),
              ),
            ],
            if (selected.owedBy.isEmpty && selected.owesTo.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'All settled with everyone.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ExpenseBalanceDetails extends StatelessWidget {
  const ExpenseBalanceDetails({
    super.key,
    required this.expense,
    required this.members,
  });

  final Expense expense;
  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    final balances = BalanceBreakdownService.expenseMemberBalances(expense);
    if (balances.isEmpty) return const SizedBox.shrink();

    final names = {for (final m in members) m.id: m.name};
    final withRemaining = balances.where((b) => b.remainingOwed > 0.01).toList();

    if (withRemaining.isEmpty) {
      return Text(
        'Everyone settled on this expense',
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.9),
          fontSize: 11,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: withRemaining.map((b) {
        final name = names[b.memberId] ?? b.memberId;
        final payerLines = b.linesToPayers
            .where((l) => l.remaining > 0.01)
            .map((l) {
              final payer = names[l.payerId] ?? l.payerId;
              if (l.paidViaContribution > 0.01) {
                return '$payer ${formatMoney(l.remaining)} left '
                    '(paid ${formatMoney(l.paidViaContribution)})';
              }
              return '$payer ${formatMoney(l.remaining)}';
            })
            .join(' · ');

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '$name: ${formatMoney(b.remainingOwed)} left'
            '${payerLines.isNotEmpty ? ' → $payerLines' : ''}',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 11,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NetBanner extends StatelessWidget {
  const _NetBanner({required this.name, required this.net});
  final String name;
  final double net;

  @override
  Widget build(BuildContext context) {
    final isCreditor = net > 0.01;
    final isDebtor = net < -0.01;
    final color = isCreditor
        ? AppColors.primary
        : isDebtor
            ? AppColors.danger
            : AppColors.textSecondary;
    final label = isCreditor
        ? '$name is owed ${formatMoney(net)} overall'
        : isDebtor
            ? '$name owes ${formatMoney(net.abs())} overall'
            : '$name is all settled';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({
    required this.balance,
    required this.names,
    required this.groupId,
    this.onSavePayment,
  });

  final MemberPairBalance balance;
  final Map<String, String> names;
  final String groupId;
  final Future<void> Function(SaveSettlementPaymentParams params)? onSavePayment;

  @override
  Widget build(BuildContext context) {
    final from = names[balance.fromId] ?? balance.fromId;
    final to = names[balance.toId] ?? balance.toId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.north_east, size: 16, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              BalanceDisplay.pairLine(fromName: from, toName: to, balance: balance),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          if (onSavePayment != null && balance.remaining > 0.01)
            TextButton(
              onPressed: () async {
                final params = await showRecordSettlementPaymentSheet(
                  context: context,
                  groupId: groupId,
                  fromId: balance.fromId,
                  toId: balance.toId,
                  fromName: from,
                  toName: to,
                  maxAmount: balance.remaining,
                );
                if (params != null) await onSavePayment!(params);
              },
              child: const Text('Pay'),
            ),
        ],
      ),
    );
  }
}

class _BalanceLine extends StatelessWidget {
  const _BalanceLine({
    required this.text,
    required this.amount,
    required this.positive,
  });

  final String text;
  final double amount;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            positive ? Icons.south_west : Icons.north_east,
            size: 16,
            color: positive ? AppColors.primary : AppColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
