import '../entities/analytics.dart';
import '../entities/expense.dart';
import '../entities/group.dart';
import '../entities/settlement.dart';
import '../entities/settlement_payment.dart';

abstract class LedgerRepository {
  Future<List<Group>> getGroups();
  Future<Group?> getGroupById(String id);
  Future<void> saveGroup(Group group);
  Future<void> deleteGroup(String id);

  Future<List<Expense>> getExpenses(String groupId);
  Future<void> saveExpense(Expense expense);
  Future<void> deleteExpense(Expense expense);

  Future<List<SettlementPayment>> getSettlementPayments(String groupId);
  Future<void> saveSettlementPayment(SettlementPayment payment);
  Future<void> deleteSettlementPayment(SettlementPayment payment);

  Future<SettlementOptimizationResult> getSettlementOptimization(String groupId);
  Future<GraphSnapshot> getGraphSnapshot(String groupId);
  Future<GroupAnalyticsSnapshot> getAnalytics(String groupId);
  Future<Map<String, double>> getCategoryBreakdown(String groupId);
  Future<Group> seedDemoGroup();
  Future<void> exportGroupPdf(String groupId);
}
