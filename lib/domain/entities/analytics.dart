import 'package:equatable/equatable.dart';

import 'member.dart';
import 'settlement.dart';

enum SpendingBehavior {
  frequentPayer,
  balancedSpender,
  lowContributor,
}

class MemberBehaviorInsight extends Equatable {
  const MemberBehaviorInsight({
    required this.member,
    required this.behavior,
    required this.totalPaid,
    required this.totalOwed,
    required this.payRatio,
    required this.predictionNote,
  });

  final Member member;
  final SpendingBehavior behavior;
  final double totalPaid;
  final double totalOwed;
  final double payRatio;
  final String predictionNote;

  @override
  List<Object?> get props =>
      [member, behavior, totalPaid, totalOwed, payRatio, predictionNote];
}

class GroupAnalyticsSnapshot extends Equatable {
  const GroupAnalyticsSnapshot({
    required this.totalSpending,
    required this.contributionsByMember,
    required this.fairnessScore,
    required this.behaviorInsights,
    required this.monthlyTotals,
    required this.naiveTransactionCount,
    required this.optimizedTransactionCount,
  });

  final double totalSpending;
  final Map<String, double> contributionsByMember;
  final double fairnessScore;
  final List<MemberBehaviorInsight> behaviorInsights;
  final Map<String, double> monthlyTotals;
  final int naiveTransactionCount;
  final int optimizedTransactionCount;

  @override
  List<Object?> get props => [
        totalSpending,
        contributionsByMember,
        fairnessScore,
        behaviorInsights,
        monthlyTotals,
        naiveTransactionCount,
        optimizedTransactionCount,
      ];
}

class GraphSnapshot extends Equatable {
  const GraphSnapshot({
    required this.edges,
    required this.netBalances,
  });

  final List<DebtEdge> edges;
  final Map<String, double> netBalances;

  @override
  List<Object?> get props => [edges, netBalances];
}
