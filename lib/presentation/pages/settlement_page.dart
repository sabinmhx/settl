import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/balance_breakdown.dart';
import '../../domain/entities/group.dart';
import '../../domain/services/balance_breakdown_service.dart';
import '../blocs/settlement/settlement_bloc.dart';
import '../widgets/member_balances_section.dart';
import '../widgets/record_settlement_payment_sheet.dart';

class SettlementPage extends StatelessWidget {
  const SettlementPage({super.key, required this.group});
  final Group group;

  @override
  Widget build(BuildContext context) {
    final memberName = {for (final m in group.members) m.id: m.name};
    final bloc = context.read<SettlementBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settle Up')),
      body: BlocBuilder<SettlementBloc, SettlementState>(
        builder: (context, state) {
          if (state.status == SettlementStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final opt = state.optimization;
          if (opt == null) {
            return const Center(child: Text('Unable to compute settlements'));
          }

          final expenses = state.expenses;
          final payments = state.payments;
          final pairs = BalanceBreakdownService.pairBalances(
            expenses,
            payments: payments,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (expenses.isNotEmpty)
                MemberBalancesSection(
                  group: group,
                  expenses: expenses,
                  payments: payments,
                  onSavePayment: (params) async {
                    bloc.add(SettlementPaymentSaved(params));
                  },
                ),
              if (expenses.isNotEmpty) const SizedBox(height: 16),
              Card(
                color: AppColors.primary.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(opt.summaryMessage, style: const TextStyle(fontSize: 15)),
                ),
              ),
              if (pairs.any((p) => p.remaining > 0.01)) ...[
                const SizedBox(height: 24),
                const Text(
                  'Outstanding debts',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...pairs.where((p) => p.remaining > 0.01).map(
                      (p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            '${memberName[p.fromId]} → ${memberName[p.toId]}',
                          ),
                          subtitle: Text(
                            '${formatMoney(p.remaining)} left · '
                            '${formatMoney(p.totalOwed)} total owed',
                          ),
                          trailing: FilledButton.tonal(
                            onPressed: () async {
                              final params = await showRecordSettlementPaymentSheet(
                                context: context,
                                groupId: group.id,
                                fromId: p.fromId,
                                toId: p.toId,
                                fromName: memberName[p.fromId] ?? p.fromId,
                                toName: memberName[p.toId] ?? p.toId,
                                maxAmount: p.remaining,
                              );
                              if (params != null) {
                                bloc.add(SettlementPaymentSaved(params));
                              }
                            },
                            child: const Text('Pay'),
                          ),
                        ),
                      ),
                    ),
              ],
              if (payments.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Recorded payments',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                ...payments.map(
                  (p) => Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      title: Text(
                        '${memberName[p.fromId]} paid ${memberName[p.toId]}',
                      ),
                      subtitle: Text(
                        '${formatMoney(p.amount)}'
                        '${p.note.isNotEmpty ? ' · ${p.note}' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () async {
                              MemberPairBalance? pair;
                              for (final x in pairs) {
                                if (x.fromId == p.fromId && x.toId == p.toId) {
                                  pair = x;
                                  break;
                                }
                              }
                              final max = (pair?.remaining ?? 0) + p.amount;
                              final params = await showRecordSettlementPaymentSheet(
                                context: context,
                                groupId: group.id,
                                fromId: p.fromId,
                                toId: p.toId,
                                fromName: memberName[p.fromId] ?? p.fromId,
                                toName: memberName[p.toId] ?? p.toId,
                                maxAmount: max > 0.01 ? max : p.amount,
                                existing: p,
                              );
                              if (params != null) {
                                bloc.add(SettlementPaymentSaved(params));
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: AppColors.danger),
                            onPressed: () =>
                                bloc.add(SettlementPaymentDeleted(p)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Suggested payments',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              if (opt.settlements.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('All settled — nothing left to pay.'),
                  ),
                )
              else
                ...opt.settlements.map(
                  (s) => Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        child: const Icon(Icons.arrow_forward, color: AppColors.primary),
                      ),
                      title: Text('${memberName[s.fromId]} pays ${memberName[s.toId]}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatMoney(s.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.payments_outlined),
                            tooltip: 'Record payment',
                            onPressed: () async {
                              final params = await showRecordSettlementPaymentSheet(
                                context: context,
                                groupId: group.id,
                                fromId: s.fromId,
                                toId: s.toId,
                                fromName: memberName[s.fromId] ?? s.fromId,
                                toName: memberName[s.toId] ?? s.toId,
                                maxAmount: s.amount,
                              );
                              if (params != null) {
                                bloc.add(SettlementPaymentSaved(params));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
