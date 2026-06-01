import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _nameCtrl,
              onChanged: cubit.updateName,
              decoration: const InputDecoration(labelText: 'Group name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              onChanged: cubit.updateDescription,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            const Text(
              'Members',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memberCtrl,
                    decoration: const InputDecoration(labelText: 'Member name'),
                    onSubmitted: (_) => _addMember(cubit),
                  ),
                ),
                IconButton.filled(
                  onPressed: () => _addMember(cubit),
                  icon: const Icon(Icons.person_add),
                ),
              ],
            ),
            BlocBuilder<CreateGroupCubit, CreateGroupState>(
              buildWhen: (a, b) => a.memberNames != b.memberNames,
              builder: (context, state) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.memberNames
                    .map(
                      (m) => Chip(
                        label: Text(m),
                        onDeleted: () => cubit.removeMemberName(m),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () async {
                final group = await cubit.submit();
                if (group != null && context.mounted) {
                  context.replace('/groups/${group.id}');
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Create Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMember(CreateGroupCubit cubit) {
    cubit.addMemberName(_memberCtrl.text);
    _memberCtrl.clear();
  }
}
