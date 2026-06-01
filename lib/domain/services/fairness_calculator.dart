import 'dart:math' as math;

class FairnessCalculator {
  static double compute({
    required Map<String, double> contributionsByMember,
    required double totalSpending,
  }) {
    if (totalSpending <= 0 || contributionsByMember.isEmpty) return 100;

    final shares =
        contributionsByMember.values.map((c) => c / totalSpending).toList();

    if (shares.length == 1) return 100;

    final mean = shares.reduce((a, b) => a + b) / shares.length;
    final variance =
        shares.map((s) => math.pow(s - mean, 2)).reduce((a, b) => a + b) /
            shares.length;

    final n = shares.length.toDouble();
    final maxVariance = (n - 1) / (n * n);
    final normalized =
        maxVariance > 0 ? (variance / maxVariance).clamp(0.0, 1.0) : 0.0;

    return ((1 - normalized) * 100).clamp(0, 100);
  }

  static String interpretScore(double score) {
    if (score >= 85) return 'Highly fair — contributions are well balanced.';
    if (score >= 65) return 'Moderately fair — minor contribution gaps.';
    if (score >= 45) return 'Uneven — some members carry more of the spend.';
    return 'Imbalanced — significant contribution disparity detected.';
  }
}
