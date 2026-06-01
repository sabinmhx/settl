import '../entities/analytics.dart';
import '../entities/expense.dart';
import '../entities/group.dart';
import 'debt_graph_engine.dart';
import 'fairness_calculator.dart';
import 'settlement_optimizer.dart';
import 'spending_classifier.dart';
import 'trend_analyzer.dart';

class GroupAnalyticsService {
  GroupAnalyticsSnapshot buildSnapshot({
    required Group group,
    required List<Expense> expenses,
  }) {
    final memberIds = group.members.map((m) => m.id).toList();
    final netBalances = DebtGraphEngine.computeNetBalances(
      memberIds: memberIds,
      expenses: expenses,
    );
    final rawEdges = DebtGraphEngine.buildRawEdges(expenses);
    final optimization = SettlementOptimizer.analyze(
      netBalances: netBalances,
      rawEdgeCount: DebtGraphEngine.countNonZeroEdges(rawEdges),
    );

    final totalSpending = expenses.fold<double>(0, (s, e) => s + e.amount);
    final contributions =
        TrendAnalyzer.memberContributions(expenses, memberIds);

    return GroupAnalyticsSnapshot(
      totalSpending: totalSpending,
      contributionsByMember: contributions,
      fairnessScore: FairnessCalculator.compute(
        contributionsByMember: contributions,
        totalSpending: totalSpending,
      ),
      behaviorInsights: SpendingClassifier.classifyMembers(
        members: group.members,
        expenses: expenses,
        netBalances: netBalances,
      ),
      monthlyTotals: TrendAnalyzer.monthlySpendingTotals(expenses),
      naiveTransactionCount: optimization.naiveTransactionCount,
      optimizedTransactionCount: optimization.optimizedTransactionCount,
    );
  }
}
