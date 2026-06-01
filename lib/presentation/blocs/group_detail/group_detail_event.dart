import 'package:equatable/equatable.dart';

abstract class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();
  @override
  List<Object?> get props => [];
}

class GroupDetailStarted extends GroupDetailEvent {
  const GroupDetailStarted(this.groupId);
  final String groupId;
  @override
  List<Object?> get props => [groupId];
}

class GroupDetailRefreshed extends GroupDetailEvent {
  const GroupDetailRefreshed(this.groupId);
  final String groupId;
  @override
  List<Object?> get props => [groupId];
}

class GroupDetailAddMember extends GroupDetailEvent {
  const GroupDetailAddMember(this.name);
  final String name;
  @override
  List<Object?> get props => [name];
}

class GroupDetailRemoveMember extends GroupDetailEvent {
  const GroupDetailRemoveMember(this.memberId);
  final String memberId;
  @override
  List<Object?> get props => [memberId];
}

class GroupDetailDeleteGroup extends GroupDetailEvent {}
