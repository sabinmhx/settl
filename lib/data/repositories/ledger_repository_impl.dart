import '../../domain/entities/analytics.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/settlement.dart';
import '../../domain/entities/settlement_payment.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../../domain/services/debt_graph_engine.dart';
import '../../domain/services/group_analytics_service.dart';
import '../../domain/services/settlement_optimizer.dart';
import '../../domain/services/trend_analyzer.dart';
import 'package:printing/printing.dart';

import '../datasources/local_ledger_datasource.dart';
import '../services/pdf_report_service.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  LedgerRepositoryImpl(
    this._local,
    this._analytics,
    this._pdf,
  );

  final LocalLedgerDataSource _local;
  final GroupAnalyticsService _analytics;
  final PdfReportService _pdf;

  @override
  Future<List<Group>> getGroups() => _local.getAllGroups();

  @override
  Future<Group?> getGroupById(String id) => _local.getGroup(id);

  @override
  Future<void> saveGroup(Group group) => _local.saveGroup(group);

  @override
  Future<void> deleteGroup(String id) => _local.deleteGroup(id);

  @override
  Future<List<Expense>> getExpenses(String groupId) =>
      _local.getExpensesForGroup(groupId);

  @override
  Future<void> saveExpense(Expense expense) => _local.saveExpense(expense);

  @override
  Future<void> deleteExpense(Expense expense) => _local.deleteExpense(expense);

  @override
  Future<List<SettlementPayment>> getSettlementPayments(String groupId) =>
      _local.getPaymentsForGroup(groupId);

  @override
  Future<void> saveSettlementPayment(SettlementPayment payment) =>
      _local.savePayment(payment);

  @override
  Future<void> deleteSettlementPayment(SettlementPayment payment) =>
      _local.deletePayment(payment);

  Future<List<SettlementPayment>> _payments(String groupId) =>
      getSettlementPayments(groupId);

  @override
  Future<SettlementOptimizationResult> getSettlementOptimization(
    String groupId,
  ) async {
    final group = await _requireGroup(groupId);
    final expenses = await getExpenses(groupId);
    final payments = await _payments(groupId);
    final memberIds = group.members.map((m) => m.id).toList();
    final balances = DebtGraphEngine.computeNetBalances(
      memberIds: memberIds,
      expenses: expenses,
      payments: payments,
    );
    final simplified =
        DebtGraphEngine.eliminateCyclesViaNetBalances(balances);
    final rawCount = DebtGraphEngine.countNonZeroEdges(
      DebtGraphEngine.buildRawEdges(expenses),
    );
    return SettlementOptimizer.analyze(
      netBalances: simplified,
      rawEdgeCount: rawCount,
    );
  }

  @override
  Future<GraphSnapshot> getGraphSnapshot(String groupId) async {
    final group = await _requireGroup(groupId);
    final expenses = await getExpenses(groupId);
    final payments = await _payments(groupId);
    return GraphSnapshot(
      edges: DebtGraphEngine.buildRawEdges(expenses),
      netBalances: DebtGraphEngine.computeNetBalances(
        memberIds: group.members.map((m) => m.id).toList(),
        expenses: expenses,
        payments: payments,
      ),
    );
  }

  @override
  Future<GroupAnalyticsSnapshot> getAnalytics(String groupId) async {
    final group = await _requireGroup(groupId);
    final expenses = await getExpenses(groupId);
    return _analytics.buildSnapshot(group: group, expenses: expenses);
  }

  @override
  Future<Map<String, double>> getCategoryBreakdown(String groupId) async {
    final expenses = await getExpenses(groupId);
    return TrendAnalyzer.categoryBreakdown(expenses);
  }

  @override
  Future<void> exportGroupPdf(String groupId) async {
    final group = await _requireGroup(groupId);
    final expenses = await getExpenses(groupId);
    final analytics = await getAnalytics(groupId);
    final optimization = await getSettlementOptimization(groupId);
    final doc = await _pdf.buildGroupReport(
      group: group,
      expenses: expenses,
      optimization: optimization,
      fairnessScore: analytics.fairnessScore,
      contributions: analytics.contributionsByMember,
      totalSpending: analytics.totalSpending,
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  Future<Group> _requireGroup(String id) async {
    final group = await _local.getGroup(id);
    if (group == null) throw StateError('Group not found: $id');
    return group;
  }
}
