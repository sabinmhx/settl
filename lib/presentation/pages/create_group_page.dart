import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../blocs/create_group/create_group_cubit.dart';
import '../widgets/app_navigation.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _memberCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _memberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateGroupCubit>();
    return Scaffold(
      appBar: AppBar(
        leading: const BackToGroupsButton(),
        title: const Text('Create Group'),
        elevation: 0,
      ),
      body: BlocListener<CreateGroupCubit, CreateGroupState>(
        listener: (context, state) async {
          if (state.status == CreateGroupStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed')),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            _FormSection(
              title: 'Group Details',
              child: Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    onChanged: cubit.updateName,
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      hintText: 'e.g., Weekend trip',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descCtrl,
                    onChanged: cubit.updateDescription,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'What is this group for?',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _FormSection(
              title: 'Add Members',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _memberCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Member name',
                            hintText: 'Enter name',
                          ),
                          onSubmitted: (_) => _addMember(cubit),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.accent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton.filled(
                          onPressed: () => _addMember(cubit),
                          icon: const Icon(Icons.person_add),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<CreateGroupCubit, CreateGroupState>(
                    buildWhen: (a, b) => a.memberNames != b.memberNames,
                    builder: (context, state) => state.memberNames.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No members added yet',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: state.memberNames
                                .map(
                                  (m) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary.withValues(alpha: 0.12),
                                          AppColors.accent.withValues(alpha: 0.08),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Chip(
                                      label: Text(
                                        m,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      deleteIcon: const Icon(Icons.close, size: 18),
                                      onDeleted: () => cubit.removeMemberName(m),
                                      backgroundColor: Colors.transparent,
                                      side: BorderSide.none,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: () async {
                final group = await cubit.submit();
                if (group != null && context.mounted) {
                  context.pop(true);
                }
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Create Group',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMember(CreateGroupCubit cubit) {
    if (_memberCtrl.text.trim().isNotEmpty) {
      cubit.addMemberName(_memberCtrl.text.trim());
      _memberCtrl.clear();
    }
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FormSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}
