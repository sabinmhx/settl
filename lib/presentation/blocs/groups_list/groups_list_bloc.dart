import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/delete_group.dart';
import '../../../domain/usecases/get_expenses.dart';
import '../../../domain/usecases/get_groups.dart';
import '../../../domain/usecases/usecase.dart';
import 'groups_list_event.dart';
import 'groups_list_state.dart';

class GroupsListBloc extends Bloc<GroupsListEvent, GroupsListState> {
  GroupsListBloc(
    this._getGroups,
    this._getExpenses,
    this._deleteGroup,
  ) : super(const GroupsListState()) {
    on<GroupsListStarted>(_onLoad);
    on<GroupsListRefreshed>(_onLoad);
    on<GroupsListDeleteRequested>(_onDelete);
  }

  final GetGroups _getGroups;
  final GetExpenses _getExpenses;
  final DeleteGroup _deleteGroup;

  Future<void> _onLoad(
    GroupsListEvent event,
    Emitter<GroupsListState> emit,
  ) async {
    emit(state.copyWith(status: GroupsListStatus.loading));
    try {
      final groups = await _getGroups(const NoParams());
      final spending = <String, double>{};
      final counts = <String, int>{};
      for (final g in groups) {
        final expenses = await _getExpenses(g.id);
        counts[g.id] = expenses.length;
        spending[g.id] = expenses.fold<double>(0, (s, e) => s + e.amount);
      }
      emit(state.copyWith(
        status: GroupsListStatus.success,
        groups: groups,
        spendingByGroupId: spending,
        expenseCountByGroupId: counts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GroupsListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDelete(
    GroupsListDeleteRequested event,
    Emitter<GroupsListState> emit,
  ) async {
    await _deleteGroup(event.groupId);
    add(GroupsListRefreshed());
  }
}
