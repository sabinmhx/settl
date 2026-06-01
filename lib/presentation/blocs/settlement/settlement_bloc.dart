import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/expense.dart';
import '../../../domain/entities/settlement.dart';
import '../../../domain/entities/settlement_payment.dart';
import '../../../domain/usecases/delete_settlement_payment.dart';
import '../../../domain/usecases/get_expenses.dart';
import '../../../domain/usecases/get_graph_snapshot.dart';
import '../../../domain/usecases/get_settlement.dart';
import '../../../domain/usecases/get_settlement_payments.dart';
import '../../../domain/usecases/save_settlement_payment.dart';

part 'settlement_event.dart';
part 'settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  SettlementBloc(
    this._getSettlement,
    this._getGraph,
    this._getExpenses,
    this._getPayments,
    this._savePayment,
    this._deletePayment,
  ) : super(const SettlementState()) {
    on<SettlementStarted>(_onLoad);
    on<SettlementPaymentSaved>(_onPaymentSaved);
    on<SettlementPaymentDeleted>(_onPaymentDeleted);
  }

  final GetSettlement _getSettlement;
  final GetGraphSnapshot _getGraph;
  final GetExpenses _getExpenses;
  final GetSettlementPayments _getPayments;
  final SaveSettlementPayment _savePayment;
  final DeleteSettlementPayment _deletePayment;

  String? _groupId;

  Future<void> _onLoad(
    SettlementStarted event,
    Emitter<SettlementState> emit,
  ) async {
    _groupId = event.groupId;
    emit(state.copyWith(status: SettlementStatus.loading));
    try {
      await _reload(event.groupId, emit);
    } catch (e) {
      emit(state.copyWith(
        status: SettlementStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPaymentSaved(
    SettlementPaymentSaved event,
    Emitter<SettlementState> emit,
  ) async {
    final groupId = _groupId ?? event.params.groupId;
    await _savePayment(event.params);
    await _reload(groupId, emit);
  }

  Future<void> _onPaymentDeleted(
    SettlementPaymentDeleted event,
    Emitter<SettlementState> emit,
  ) async {
    final groupId = _groupId ?? event.payment.groupId;
    await _deletePayment(event.payment);
    await _reload(groupId, emit);
  }

  Future<void> _reload(String groupId, Emitter<SettlementState> emit) async {
    final result = await _getSettlement(groupId);
    final graph = await _getGraph(groupId);
    final expenses = await _getExpenses(groupId);
    final payments = await _getPayments(groupId);
    emit(state.copyWith(
      status: SettlementStatus.success,
      optimization: result,
      netBalances: graph.netBalances,
      rawEdgeCount: graph.edges.length,
      expenses: expenses,
      payments: payments,
    ));
  }
}
