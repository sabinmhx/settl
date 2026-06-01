import 'package:uuid/uuid.dart';

import '../entities/group.dart';
import '../entities/member.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class CreateGroupParams {
  CreateGroupParams({
    required this.name,
    required this.description,
    required this.memberNames,
  });

  final String name;
  final String description;
  final List<String> memberNames;
}

class CreateGroup extends UseCase<Group?, CreateGroupParams> {
  CreateGroup(this._repository);
  final LedgerRepository _repository;
  final _uuid = const Uuid();

  static const _palette = [
    0xFF3D5AFE,
    0xFF00D4AA,
    0xFF6C5CE7,
    0xFFFFB347,
    0xFFFF6B6B,
    0xFF26C6DA,
  ];

  @override
  Future<Group?> call(CreateGroupParams params) async {
    if (params.name.trim().isEmpty) return null;

    final members = params.memberNames
        .where((n) => n.trim().isNotEmpty)
        .map(
          (n) => Member(
            id: _uuid.v4(),
            name: n.trim(),
            colorHex: _palette[n.hashCode.abs() % _palette.length],
          ),
        )
        .toList();

    if (members.isEmpty) return null;

    final group = Group(
      id: _uuid.v4(),
      name: params.name.trim(),
      description: params.description.trim(),
      members: members,
      createdAt: DateTime.now(),
    );

    await _repository.saveGroup(group);
    return group;
  }
}
