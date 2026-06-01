import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../blocs/groups_list/groups_list_bloc.dart';
import '../blocs/groups_list/groups_list_event.dart';
import '../blocs/groups_list/groups_list_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _openCreateGroup(BuildContext context) async {
    await context.push(AppRoutes.createGroup);
    if (context.mounted) {
      context.read<GroupsListBloc>().add(GroupsListRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.hub, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('LedgerX'),
          ],
        ),
      ),
      body: BlocConsumer<GroupsListBloc, GroupsListState>(
        listener: (context, state) {
          if (state.seededGroupId != null) {
            context.push('/groups/${state.seededGroupId}');
          }
        },
        builder: (context, state) {
          if (state.status == GroupsListStatus.loading && state.groups.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.groups.isEmpty) {
            return _EmptyState(
              onCreate: () => _openCreateGroup(context),
              onDemo: () =>
                  context.read<GroupsListBloc>().add(GroupsListSeedDemoRequested()),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.groups.length,
            itemBuilder: (context, index) {
              final group = state.groups[index];
              final total = state.spendingByGroupId[group.id] ?? 0;
              final expenseCount = state.expenseCountByGroupId[group.id] ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/groups/${group.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.surfaceElevated,
                          child: Text(
                            group.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(group.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                '${group.members.length} members · $expenseCount expenses',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatMoney(total),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateGroup(context),
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate, required this.onDemo});
  final VoidCallback onCreate;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_tree, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text('Financial relationship intelligence',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.group_add),
                label: const Text('Create your first group')),
            const SizedBox(height: 12),
            OutlinedButton.icon(
                onPressed: onDemo,
                icon: const Icon(Icons.science_outlined),
                label: const Text('Load demo group')),
          ],
        ),
      ),
    );
  }
}
