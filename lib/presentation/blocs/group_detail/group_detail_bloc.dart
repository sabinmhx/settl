import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/delete_group.dart';
import '../../../domain/usecases/get_analytics.dart';
import '../../../domain/usecases/get_expenses.dart';
import '../../../domain/usecases/get_group_by_id.dart';
import '../../../domain/usecases/get_settlement.dart';
import '../../../domain/usecases/get_settlement_payments.dart';
import '../../../domain/usecases/update_group_members.dart';
import 'group_detail_event.dart';
import 'group_detail_state.dart';

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  GroupDetailBloc(
    this._getGroup,
    this._getExpenses,
    this._getAnalytics,
    this._getSettlement,
    this._getPayments,
    this._addMember,
    this._removeMember,
    this._deleteGroup,
  ) : super(const GroupDetailState()) {
    on<GroupDetailStarted>(_onLoad);
    on<GroupDetailRefreshed>(_onLoad);
    on<GroupDetailAddMember>(_onAddMember);
    on<GroupDetailRemoveMember>(_onRemoveMember);
    on<GroupDetailDeleteGroup>(_onDelete);
  }

  final GetGroupById _getGroup;
  final GetExpenses _getExpenses;
  final GetAnalytics _getAnalytics;
  final GetSettlement _getSettlement;
  final GetSettlementPayments _getPayments;
  final AddMember _addMember;
  final RemoveMember _removeMember;
  final DeleteGroup _deleteGroup;

  Future<void> _onLoad(
    GroupDetailEvent event,
    Emitter<GroupDetailState> emit,
  ) async {
    final groupId = event is GroupDetailStarted
        ? event.groupId
        : (event as GroupDetailRefreshed).groupId;

    emit(state.copyWith(status: GroupDetailStatus.loading));
    try {
      final group = await _getGroup(groupId);
      if (group == null) {
        emit(state.copyWith(
          status: GroupDetailStatus.failure,
          errorMessage: 'Group not found',
        ));
        return;
      }
      final expenses = await _getExpenses(groupId);
      final analytics = await _getAnalytics(groupId);
      final settlement = await _getSettlement(groupId);
      final payments = await _getPayments(groupId);
      emit(state.copyWith(
        status: GroupDetailStatus.success,
        group: group,
        expenses: expenses,
        analytics: analytics,
        settlement: settlement,
        payments: payments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GroupDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddMember(
    GroupDetailAddMember event,
    Emitter<GroupDetailState> emit,
  ) async {
    final group = state.group;
    if (group == null) return;
    await _addMember(AddMemberParams(group: group, memberName: event.name));
    add(GroupDetailRefreshed(group.id));
  }

  Future<void> _onRemoveMember(
    GroupDetailRemoveMember event,
    Emitter<GroupDetailState> emit,
  ) async {
    final group = state.group;
    if (group == null) return;
    await _removeMember(RemoveMemberParams(group: group, memberId: event.memberId));
    add(GroupDetailRefreshed(group.id));
  }

  Future<void> _onDelete(
    GroupDetailDeleteGroup event,
    Emitter<GroupDetailState> emit,
  ) async {
    final group = state.group;
    if (group == null) return;
    await _deleteGroup(group.id);
    emit(state.copyWith(deleted: true));
  }
}
