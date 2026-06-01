import 'package:equatable/equatable.dart';

/// A direct repayment from one member to another (partial or full).
class SettlementPayment extends Equatable {
  const SettlementPayment({
    required this.id,
    required this.groupId,
    required this.fromId,
    required this.toId,
    required this.amount,
    required this.createdAt,
    this.note = '',
  });

  final String id;
  final String groupId;
  final String fromId;
  final String toId;
  final double amount;
  final DateTime createdAt;
  final String note;

  SettlementPayment copyWith({
    String? id,
    String? groupId,
    String? fromId,
    String? toId,
    double? amount,
    DateTime? createdAt,
    String? note,
  }) =>
      SettlementPayment(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        fromId: fromId ?? this.fromId,
        toId: toId ?? this.toId,
        amount: amount ?? this.amount,
        createdAt: createdAt ?? this.createdAt,
        note: note ?? this.note,
      );

  @override
  List<Object?> get props => [id, groupId, fromId, toId, amount, createdAt, note];
}
