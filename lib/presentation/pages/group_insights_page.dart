import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/entities/group.dart';
import '../../domain/services/fairness_calculator.dart';
import '../../domain/services/spending_classifier.dart';
import '../blocs/analytics/analytics_bloc.dart';
import '../blocs/graph/graph_bloc.dart';
import '../widgets/debt_graph_painter.dart';
import '../widgets/stat_card.dart';

class GroupInsightsPage extends StatelessWidget {
  const GroupInsightsPage({super.key, required this.group});
  final Group group;

  @override
  Widget build(BuildContext context) {
    final memberNames = {for (final m in group.members) m.id: m.name};

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              title: const Text('Insights'),
              actions: [
                BlocBuilder<AnalyticsBloc, AnalyticsState>(
                  buildWhen: (a, b) => a.isExporting != b.isExporting,
                  builder: (context, state) => IconButton(
                    icon: state.isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined),
                    onPressed: state.isExporting
                        ? null
                        : () => context
                            .read<AnalyticsBloc>()
                            .add(AnalyticsExportPdf()),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.surface,
                        AppColors.primary.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Analytics'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OverviewTab(group: group, memberNames: memberNames),
              _AnalyticsTab(group: group, memberNames: memberNames),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.group, required this.memberNames});
  final Group group;
  final Map<String, String> memberNames;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphBloc, GraphState>(
      builder: (context, graphState) {
        return BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, analyticsState) {
            if (graphState.status == GraphStatus.loading ||
                analyticsState.status == AnalyticsStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final snap = analyticsState.snapshot;
            final graph = graphState.snapshot;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (snap != null)
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Total spend',
                          value: formatMoney(snap.totalSpending),
                          icon: Icons.payments_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          label: 'Fairness',
                          value: '${snap.fairnessScore.toStringAsFixed(0)}%',
                          icon: Icons.balance_outlined,
                          accentColor: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Debt graph',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (graph == null)
                  const Card(
                    child: SizedBox(
                      height: 240,
                      child: Center(child: Text('No graph data')),
                    ),
                  )
                else
                  _GraphCard(group: group, graphState: graphState, graph: graph),
                if (snap != null) ...[
                  const SizedBox(height: 16),
                  StatCard(
                    label: 'Settlement efficiency',
                    value:
                        '${snap.optimizedTransactionCount} of ${snap.naiveTransactionCount} payments',
                    icon: Icons.swap_horiz,
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _GraphCard extends StatelessWidget {
  const _GraphCard({
    required this.group,
    required this.graphState,
    required this.graph,
  });

  final Group group;
  final GraphState graphState;
  final GraphSnapshot graph;

  @override
  Widget build(BuildContext context) {
    final maxEdge = graph.edges.isEmpty
        ? 1.0
        : graph.edges.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: CustomPaint(
              painter: DebtGraphPainter(
                members: group.members,
                edges: graph.edges,
                netBalances: graph.netBalances,
                selectedMemberId: graphState.selectedMemberId,
                maxEdgeAmount: maxEdge,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: group.members.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final m = group.members[i];
                  final net = graph.netBalances[m.id] ?? 0;
                  final selected = graphState.selectedMemberId == m.id;
                  return FilterChip(
                    label: Text('${m.name} ${formatMoney(net.abs())}'),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    onSelected: (_) => context.read<GraphBloc>().add(
                          GraphMemberSelected(selected ? null : m.id),
                        ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab({required this.group, required this.memberNames});
  final Group group;
  final Map<String, String> memberNames;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state.status == AnalyticsStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        final snap = state.snapshot;
        if (snap == null) {
          return const Center(child: Text('No analytics data'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Contributions',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: _ContributionPie(
                contributions: snap.contributionsByMember,
                memberNames: memberNames,
                total: snap.totalSpending,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Spending trends',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SizedBox(height: 200, child: _TrendChart(monthlyTotals: snap.monthlyTotals)),
            const SizedBox(height: 20),
            Text(
              FairnessCalculator.interpretScore(snap.fairnessScore),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Text(
              'Behavior',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            ...snap.behaviorInsights.map((i) => _BehaviorTile(insight: i)),
            const SizedBox(height: 16),
            const Text(
              'By category',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            ...state.categoryBreakdown.entries.map(
              (e) => Card(
                margin: const EdgeInsets.only(top: 8),
                child: ListTile(
                  title: Text(e.key),
                  trailing: Text(
                    formatMoney(e.value),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ContributionPie extends StatelessWidget {
  const _ContributionPie({
    required this.contributions,
    required this.memberNames,
    required this.total,
  });

  final Map<String, double> contributions;
  final Map<String, String> memberNames;
  final double total;

  static const _colors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.warning,
    AppColors.graphNode,
    AppColors.danger,
    AppColors.primaryMuted,
  ];

  @override
  Widget build(BuildContext context) {
    if (total <= 0) {
      return const Card(child: Center(child: Text('No spending data')));
    }
    var i = 0;
    final sections = contributions.entries.map((e) {
      final color = _colors[i++ % _colors.length];
      return PieChartSectionData(
        value: e.value,
        title: '${((e.value / total) * 100).toStringAsFixed(0)}%',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: PieChart(
        PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 28),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.monthlyTotals});
  final Map<String, double> monthlyTotals;

  @override
  Widget build(BuildContext context) {
    if (monthlyTotals.isEmpty) {
      return const Card(child: Center(child: Text('Add expenses to see trends')));
    }
    final keys = monthlyTotals.keys.toList();
    final spots = [
      for (var i = 0; i < keys.length; i++)
        FlSpot(i.toDouble(), monthlyTotals[keys[i]]!),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: AppColors.cardBorder, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, _) => Text(
                    formatCompact(v),
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= keys.length) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      keys[idx].substring(5),
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BehaviorTile extends StatelessWidget {
  const _BehaviorTile({required this.insight});
  final MemberBehaviorInsight insight;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(insight.member.colorHex),
          child: Text(
            insight.member.name.isNotEmpty
                ? insight.member.name[0].toUpperCase()
                : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(insight.member.name),
        subtitle: Text(
          '${SpendingClassifier.behaviorLabel(insight.behavior)} · ${insight.predictionNote}',
        ),
        isThreeLine: true,
      ),
    );
  }
}
