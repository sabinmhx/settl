import 'package:uuid/uuid.dart';

import '../entities/group.dart';
import '../entities/member.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class AddMemberParams {
  AddMemberParams({required this.group, required this.memberName});
  final Group group;
  final String memberName;
}

class AddMember extends UseCase<void, AddMemberParams> {
  AddMember(this._repository);
  final LedgerRepository _repository;
  final _uuid = const Uuid();

  @override
  Future<void> call(AddMemberParams params) async {
    if (params.memberName.trim().isEmpty) return;
    final updated = params.group.copyWith(
      members: [
        ...params.group.members,
        Member(id: _uuid.v4(), name: params.memberName.trim()),
      ],
    );
    await _repository.saveGroup(updated);
  }
}

class RemoveMemberParams {
  RemoveMemberParams({required this.group, required this.memberId});
  final Group group;
  final String memberId;
}

class RemoveMember extends UseCase<void, RemoveMemberParams> {
  RemoveMember(this._repository);
  final LedgerRepository _repository;

  @override
  Future<void> call(RemoveMemberParams params) async {
    if (params.group.members.length <= 1) return;
    final updated = params.group.copyWith(
      members: params.group.members.where((m) => m.id != params.memberId).toList(),
    );
    await _repository.saveGroup(updated);
  }
}
