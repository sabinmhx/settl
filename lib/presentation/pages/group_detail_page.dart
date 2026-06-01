import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../widgets/app_navigation.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/group.dart';
import '../blocs/group_detail/group_detail_bloc.dart';
import '../blocs/group_detail/group_detail_event.dart';
import '../blocs/group_detail/group_detail_state.dart';
import '../utils/expense_display.dart';
import '../widgets/member_balances_section.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key, required this.groupId});
  final String groupId;

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final _memberCtrl = TextEditingController();

  @override
  void dispose() {
    _memberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupDetailBloc, GroupDetailState>(
      listener: (context, state) {
        if (state.deleted) context.go(AppRoutes.home);
      },
      builder: (context, state) {
        if (state.status == GroupDetailStatus.loading && state.group == null) {
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
            body: Center(child: Text(state.errorMessage ?? 'Group not found')),
          );
        }
        return _GroupDetailBody(
          group: group,
          state: state,
          memberCtrl: _memberCtrl,
          groupId: widget.groupId,
        );
      },
    );
  }
}

class _GroupDetailBody extends StatelessWidget {
  const _GroupDetailBody({
    required this.group,
    required this.state,
    required this.memberCtrl,
    required this.groupId,
  });

  final Group group;
  final GroupDetailState state;
  final TextEditingController memberCtrl;
  final String groupId;

  Future<void> _openExpenseForm(BuildContext context, {Expense? expense}) async {
    final bloc = context.read<GroupDetailBloc>();
    final path = expense == null
        ? '/groups/$groupId/expenses/add'
        : '/groups/$groupId/expenses/edit';
    final changed = await context.push<bool>(path, extra: expense);
    if (changed == true && context.mounted) {
      bloc.add(GroupDetailRefreshed(groupId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GroupDetailBloc>();
    final analytics = state.analytics;
    final settlement = state.settlement;

    return Scaffold(
      appBar: AppBar(
        leading: const BackToGroupsButton(),
        title: Text(group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete group?'),
                  content: const Text('This removes all expenses.'),
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
              if (ok == true) bloc.add(GroupDetailDeleteGroup());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => bloc.add(GroupDetailRefreshed(groupId)),
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _InsightsCard(
              onTap: () => context.push('/groups/$groupId/insights', extra: group),
              totalSpend: analytics?.totalSpending,
              fairness: analytics?.fairnessScore,
            ),
            const SizedBox(height: 12),
            MemberBalancesSection(
              group: group,
              expenses: state.expenses,
              payments: state.payments,
            ),
            const SizedBox(height: 12),
            if (settlement != null)
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.handshake_outlined,
                        color: AppColors.accent, size: 20),
                  ),
                  title: const Text('Settlement'),
                  subtitle: Text(settlement.summaryMessage),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await context.push('/groups/$groupId/settlement', extra: group);
                    if (context.mounted) {
                      bloc.add(GroupDetailRefreshed(groupId));
                    }
                  },
                ),
              ),
            const SizedBox(height: 20),
            const Text('Members',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            ...group.members.map(
              (m) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(m.colorHex),
                    child: Text(
                      m.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(m.name),
                  trailing: group.members.length > 1
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => bloc.add(GroupDetailRemoveMember(m.id)),
                        )
                      : null,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: memberCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Add member',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () {
                    bloc.add(GroupDetailAddMember(memberCtrl.text));
                    memberCtrl.clear();
                  },
                  child: const Icon(Icons.person_add_outlined),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Expenses (${state.expenses.length})',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  analytics != null ? formatMoney(analytics.totalSpending) : '',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.expenses.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 40, color: AppColors.textSecondary.withValues(alpha: 0.6)),
                      const SizedBox(height: 8),
                      const Text(
                        'No expenses yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...state.expenses.map(
                (e) => _ExpenseTile(
                  expense: e,
                  group: group,
                  onTap: () => _openExpenseForm(context, expense: e),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryMuted],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.background,
          onPressed: () => _openExpenseForm(context),
          icon: const Icon(Icons.add_rounded, size: 26),
          label: const Text(
            'Add expense',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({
    required this.onTap,
    this.totalSpend,
    this.fairness,
  });

  final VoidCallback onTap;
  final double? totalSpend;
  final double? fairness;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withValues(alpha: 0.15),
                AppColors.primary.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.insights, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Insights',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalSpend != null && fairness != null
                          ? '${formatMoney(totalSpend!)} spent · ${fairness!.toStringAsFixed(0)}% fair'
                          : 'Graph, analytics & trends',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.group,
    required this.onTap,
  });

  final Expense expense;
  final Group group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final payerText = ExpenseDisplay.payerSummary(expense, group.members);
    final splitText = ExpenseDisplay.splitSummary(expense, group.members);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(expense.category),
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      splitText.isNotEmpty
                          ? '${expense.category.label} · $splitText · $payerText paid'
                          : '${expense.category.label} · $payerText paid',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ExpenseBalanceDetails(
                      expense: expense,
                      members: group.members,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatMoney(expense.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Icon(Icons.edit_outlined, size: 14, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant_outlined;
      case ExpenseCategory.transport:
        return Icons.directions_car_outlined;
      case ExpenseCategory.accommodation:
        return Icons.hotel_outlined;
      case ExpenseCategory.entertainment:
        return Icons.movie_outlined;
      case ExpenseCategory.utilities:
        return Icons.bolt_outlined;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ExpenseCategory.other:
        return Icons.receipt_outlined;
    }
  }
}
