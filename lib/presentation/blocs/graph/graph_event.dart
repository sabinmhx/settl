part of 'graph_bloc.dart';

abstract class GraphEvent extends Equatable {
  const GraphEvent();
  @override
  List<Object?> get props => [];
}

class GraphStarted extends GraphEvent {
  const GraphStarted(this.groupId);
  final String groupId;
  @override
  List<Object?> get props => [groupId];
}

class GraphMemberSelected extends GraphEvent {
  const GraphMemberSelected(this.memberId);
  final String? memberId;
  @override
  List<Object?> get props => [memberId];
}
