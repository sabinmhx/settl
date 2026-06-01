import 'package:equatable/equatable.dart';

import '../../../domain/entities/analytics.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/entities/settlement.dart';
import '../../../domain/entities/settlement_payment.dart';

enum GroupDetailStatus { initial, loading, success, failure }

class GroupDetailState extends Equatable {
  const GroupDetailState({
    this.status = GroupDetailStatus.initial,
    this.group,
    this.expenses = const [],
    this.analytics,
    this.settlement,
    this.payments = const [],
    this.deleted = false,
    this.errorMessage,
  });

  final GroupDetailStatus status;
  final Group? group;
  final List<Expense> expenses;
  final GroupAnalyticsSnapshot? analytics;
  final SettlementOptimizationResult? settlement;
  final List<SettlementPayment> payments;
  final bool deleted;
  final String? errorMessage;

  GroupDetailState copyWith({
    GroupDetailStatus? status,
    Group? group,
    List<Expense>? expenses,
    GroupAnalyticsSnapshot? analytics,
    SettlementOptimizationResult? settlement,
    List<SettlementPayment>? payments,
    bool? deleted,
    String? errorMessage,
  }) =>
      GroupDetailState(
        status: status ?? this.status,
        group: group ?? this.group,
        expenses: expenses ?? this.expenses,
        analytics: analytics ?? this.analytics,
        settlement: settlement ?? this.settlement,
        payments: payments ?? this.payments,
        deleted: deleted ?? this.deleted,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, group, expenses, analytics, settlement, payments, deleted, errorMessage];
}
