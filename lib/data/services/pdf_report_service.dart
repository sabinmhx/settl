import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/expense.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/settlement.dart';
import '../../domain/services/fairness_calculator.dart';
import '../../domain/services/trend_analyzer.dart';

class PdfReportService {
  Future<pw.Document> buildGroupReport({
    required Group group,
    required List<Expense> expenses,
    required SettlementOptimizationResult optimization,
    required double fairnessScore,
    required Map<String, double> contributions,
    required double totalSpending,
  }) async {
    final dateFormat = DateFormat('MMM d, yyyy');
    final money = NumberFormat.currency(symbol: '\$');

    final memberName = {for (final m in group.members) m.id: m.name};

    pw.Widget sectionTitle(String text) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('LedgerX Financial Report',
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(group.name, style: const pw.TextStyle(fontSize: 16)),
                pw.Text(
                  'Generated ${dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          sectionTitle('Summary'),
          pw.Text('Total group spending: ${money.format(totalSpending)}'),
          pw.Text('Fairness score: ${fairnessScore.toStringAsFixed(1)} / 100'),
          pw.Text(FairnessCalculator.interpretScore(fairnessScore)),
          pw.SizedBox(height: 8),
          pw.Text(optimization.summaryMessage),
          sectionTitle('Optimized Settlements'),
          if (optimization.settlements.isEmpty)
            pw.Text('All balances are settled.')
          else
            ...optimization.settlements.map(
              (s) => pw.Bullet(
                text:
                    '${memberName[s.fromId] ?? s.fromId} pays ${memberName[s.toId] ?? s.toId} ${money.format(s.amount)}',
              ),
            ),
          sectionTitle('Member Contributions'),
          ...contributions.entries.map(
            (e) => pw.Text(
              '${memberName[e.key] ?? e.key}: ${money.format(e.value)}',
            ),
          ),
          sectionTitle('Spending by Category'),
          ...TrendAnalyzer.categoryBreakdown(expenses).entries.map(
                (e) => pw.Text('${e.key}: ${money.format(e.value)}'),
              ),
          sectionTitle('Transaction History'),
          ...expenses.take(50).map(
                (e) {
                  final payers = e.payerAmounts.entries
                      .map((p) =>
                          '${memberName[p.key] ?? p.key} ${money.format(p.value)}')
                      .join(', ');
                  return pw.Text(
                    '${dateFormat.format(e.createdAt)} — ${e.title} (${e.category.label}): '
                    '${money.format(e.amount)} paid by $payers',
                    style: const pw.TextStyle(fontSize: 9),
                  );
                },
              ),
        ],
      ),
    );

    return doc;
  }
}
