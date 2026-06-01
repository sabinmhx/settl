import '../entities/analytics.dart';
import '../entities/expense.dart';
import '../entities/member.dart';

class SpendingClassifier {
  static const _frequentPayerThreshold = 1.35;
  static const _lowContributorThreshold = 0.65;

  static List<MemberBehaviorInsight> classifyMembers({
    required List<Member> members,
    required List<Expense> expenses,
    required Map<String, double> netBalances,
  }) {
    final paid = <String, double>{for (final m in members) m.id: 0.0};
    final owed = <String, double>{for (final m in members) m.id: 0.0};

    for (final expense in expenses) {
      for (final entry in expense.payerAmounts.entries) {
        paid[entry.key] = (paid[entry.key] ?? 0) + entry.value;
      }
      for (final entry in expense.splitAmounts.entries) {
        owed[entry.key] = (owed[entry.key] ?? 0) + entry.value;
      }
    }

    final payRatios = members.map((m) {
      final o = owed[m.id] ?? 0;
      final p = paid[m.id] ?? 0;
      return o > 0 ? p / o : (p > 0 ? 2.0 : 1.0);
    }).toList();

    final avgRatio = payRatios.isEmpty
        ? 1.0
        : payRatios.reduce((a, b) => a + b) / payRatios.length;

    return members.map((member) {
      final o = owed[member.id] ?? 0;
      final p = paid[member.id] ?? 0;
      final ratio = o > 0 ? p / o : (p > 0 ? 2.0 : 1.0);
      final behavior = _classify(ratio, avgRatio);
      final net = netBalances[member.id] ?? 0;

      return MemberBehaviorInsight(
        member: member,
        behavior: behavior,
        totalPaid: p,
        totalOwed: o,
        payRatio: ratio,
        predictionNote: _prediction(behavior, net),
      );
    }).toList();
  }

  static SpendingBehavior _classify(double ratio, double avgRatio) {
    if (ratio >= avgRatio * _frequentPayerThreshold) {
      return SpendingBehavior.frequentPayer;
    }
    if (ratio <= avgRatio * _lowContributorThreshold) {
      return SpendingBehavior.lowContributor;
    }
    return SpendingBehavior.balancedSpender;
  }

  static String _prediction(SpendingBehavior behavior, double netBalance) {
    switch (behavior) {
      case SpendingBehavior.frequentPayer:
        if (netBalance > 0) {
          return 'Likely to remain a net creditor; group may owe them more over time.';
        }
        return 'Pays often but may absorb costs — watch for burnout on large expenses.';
      case SpendingBehavior.lowContributor:
        if (netBalance < 0) {
          return 'Trend toward increasing debt unless settlement cadence improves.';
        }
        return 'Lower pay frequency — imbalance may grow with new shared expenses.';
      case SpendingBehavior.balancedSpender:
        return 'Stable pattern expected; net balance should stay near equilibrium.';
    }
  }

  static String behaviorLabel(SpendingBehavior b) {
    switch (b) {
      case SpendingBehavior.frequentPayer:
        return 'Frequent Payer';
      case SpendingBehavior.balancedSpender:
        return 'Balanced Spender';
      case SpendingBehavior.lowContributor:
        return 'Low Contributor';
    }
  }
}
