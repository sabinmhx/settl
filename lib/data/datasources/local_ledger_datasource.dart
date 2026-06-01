import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/expense.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/settlement_payment.dart';
import '../mappers/entity_mappers.dart';

abstract class LocalLedgerDataSource {
  Future<void> init();
  Future<List<Group>> getAllGroups();
  Future<Group?> getGroup(String id);
  Future<void> saveGroup(Group group);
  Future<void> deleteGroup(String id);
  Future<List<Expense>> getExpensesForGroup(String groupId);
  Future<void> saveExpense(Expense expense);
  Future<void> deleteExpense(Expense expense);
  Future<List<SettlementPayment>> getPaymentsForGroup(String groupId);
  Future<void> savePayment(SettlementPayment payment);
  Future<void> deletePayment(SettlementPayment payment);
}

class LocalLedgerDataSourceImpl implements LocalLedgerDataSource {
  static const _groupsBox = 'groups';
  static const _expensesBox = 'expenses';
  static const _paymentsBox = 'settlement_payments';

  late Box<String> _groups;
  late Box<String> _expenses;
  late Box<String> _payments;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _groups = await Hive.openBox<String>(_groupsBox);
    _expenses = await Hive.openBox<String>(_expensesBox);
    _payments = await Hive.openBox<String>(_paymentsBox);
  }

  @override
  Future<List<Group>> getAllGroups() async {
    return _groups.values
        .map((s) => EntityMappers.groupFromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Group?> getGroup(String id) async {
    final raw = _groups.get(id);
    if (raw == null) return null;
    return EntityMappers.groupFromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveGroup(Group group) async {
    await _groups.put(group.id, jsonEncode(EntityMappers.groupToJson(group)));
  }

  @override
  Future<void> deleteGroup(String id) async {
    await _groups.delete(id);
    final expenseKeys = _expenses.keys
        .where((k) => k.toString().startsWith('$id:'))
        .toList();
    for (final key in expenseKeys) {
      await _expenses.delete(key);
    }
    final paymentKeys = _payments.keys
        .where((k) => k.toString().startsWith('$id:'))
        .toList();
    for (final key in paymentKeys) {
      await _payments.delete(key);
    }
  }

  @override
  Future<List<Expense>> getExpensesForGroup(String groupId) async {
    return _expenses.keys
        .where((k) => k.toString().startsWith('$groupId:'))
        .map((k) => _expenses.get(k))
        .whereType<String>()
        .map((s) =>
            EntityMappers.expenseFromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    final key = '${expense.groupId}:${expense.id}';
    await _expenses.put(key, jsonEncode(EntityMappers.expenseToJson(expense)));
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    await _expenses.delete('${expense.groupId}:${expense.id}');
  }

  @override
  Future<List<SettlementPayment>> getPaymentsForGroup(String groupId) async {
    return _payments.keys
        .where((k) => k.toString().startsWith('$groupId:'))
        .map((k) => _payments.get(k))
        .whereType<String>()
        .map((s) => EntityMappers.settlementPaymentFromJson(
              jsonDecode(s) as Map<String, dynamic>,
            ))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> savePayment(SettlementPayment payment) async {
    final key = '${payment.groupId}:${payment.id}';
    await _payments.put(
      key,
      jsonEncode(EntityMappers.settlementPaymentToJson(payment)),
    );
  }

  @override
  Future<void> deletePayment(SettlementPayment payment) async {
    await _payments.delete('${payment.groupId}:${payment.id}');
  }
}
