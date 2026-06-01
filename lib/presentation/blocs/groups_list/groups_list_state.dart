import 'package:equatable/equatable.dart';

import '../../../domain/entities/group.dart';

enum GroupsListStatus { initial, loading, success, failure }

class GroupsListState extends Equatable {
  const GroupsListState({
    this.status = GroupsListStatus.initial,
    this.groups = const [],
    this.spendingByGroupId = const {},
    this.expenseCountByGroupId = const {},
    this.errorMessage,
    this.seededGroupId,
  });

  final GroupsListStatus status;
  final List<Group> groups;
  final Map<String, double> spendingByGroupId;
  final Map<String, int> expenseCountByGroupId;
  final String? errorMessage;
  final String? seededGroupId;

  GroupsListState copyWith({
    GroupsListStatus? status,
    List<Group>? groups,
    Map<String, double>? spendingByGroupId,
    Map<String, int>? expenseCountByGroupId,
    String? errorMessage,
    String? seededGroupId,
    bool clearSeeded = false,
  }) =>
      GroupsListState(
        status: status ?? this.status,
        groups: groups ?? this.groups,
        spendingByGroupId: spendingByGroupId ?? this.spendingByGroupId,
        expenseCountByGroupId:
            expenseCountByGroupId ?? this.expenseCountByGroupId,
        errorMessage: errorMessage,
        seededGroupId: clearSeeded ? null : (seededGroupId ?? this.seededGroupId),
      );

  @override
  List<Object?> get props => [
        status,
        groups,
        spendingByGroupId,
        expenseCountByGroupId,
        errorMessage,
        seededGroupId,
      ];
}
