import 'package:equatable/equatable.dart';

abstract class GroupsListEvent extends Equatable {
  const GroupsListEvent();
  @override
  List<Object?> get props => [];
}

class GroupsListStarted extends GroupsListEvent {}

class GroupsListRefreshed extends GroupsListEvent {}

class GroupsListSeedDemoRequested extends GroupsListEvent {}

class GroupsListDeleteRequested extends GroupsListEvent {
  const GroupsListDeleteRequested(this.groupId);
  final String groupId;
  @override
  List<Object?> get props => [groupId];
}
