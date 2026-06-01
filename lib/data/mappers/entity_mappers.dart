import '../../domain/entities/expense.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/settlement_payment.dart';

class EntityMappers {
  static Member memberFromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as String,
        name: json['name'] as String,
        colorHex: json['colorHex'] as int? ?? 0xFF3D5AFE,
      );

  static Map<String, dynamic> memberToJson(Member m) => {
        'id': m.id,
        'name': m.name,
        'colorHex': m.colorHex,
      };

  static Group groupFromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        members: (json['members'] as List<dynamic>)
            .map((e) => memberFromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  static Map<String, dynamic> groupToJson(Group g) => {
        'id': g.id,
        'name': g.name,
        'description': g.description,
        'members': g.members.map(memberToJson).toList(),
        'createdAt': g.createdAt.toIso8601String(),
      };

  static Expense expenseFromJson(Map<String, dynamic> json) {
    final rawSplits = json['splitAmounts'] as Map<String, dynamic>;
    final rawPayers = json['payerAmounts'] as Map<String, dynamic>?;
    final legacyPayerId = json['payerId'] as String?;
    final amount = (json['amount'] as num).toDouble();

    final payerAmounts = rawPayers != null
        ? rawPayers.map((k, v) => MapEntry(k, (v as num).toDouble()))
        : legacyPayerId != null
            ? {legacyPayerId: amount}
            : <String, double>{};

    return Expense(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      amount: amount,
      payerAmounts: payerAmounts,
      splitAmounts:
          rawSplits.map((k, v) => MapEntry(k, (v as num).toDouble())),
      category: ExpenseCategory.fromString(json['category'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String? ?? '',
    );
  }

  static Map<String, dynamic> expenseToJson(Expense e) => {
        'id': e.id,
        'groupId': e.groupId,
        'title': e.title,
        'amount': e.amount,
        'payerAmounts': e.payerAmounts,
        'splitAmounts': e.splitAmounts,
        'category': e.category.name,
        'createdAt': e.createdAt.toIso8601String(),
        'note': e.note,
      };

  static SettlementPayment settlementPaymentFromJson(Map<String, dynamic> json) =>
      SettlementPayment(
        id: json['id'] as String,
        groupId: json['groupId'] as String,
        fromId: json['fromId'] as String,
        toId: json['toId'] as String,
        amount: (json['amount'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        note: json['note'] as String? ?? '',
      );

  static Map<String, dynamic> settlementPaymentToJson(SettlementPayment p) => {
        'id': p.id,
        'groupId': p.groupId,
        'fromId': p.fromId,
        'toId': p.toId,
        'amount': p.amount,
        'createdAt': p.createdAt.toIso8601String(),
        'note': p.note,
      };
}
