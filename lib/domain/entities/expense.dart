import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  food,
  transport,
  accommodation,
  entertainment,
  utilities,
  shopping,
  other;

  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.accommodation:
        return 'Accommodation';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  static ExpenseCategory fromString(String value) =>
      ExpenseCategory.values.firstWhere(
        (c) => c.name == value,
        orElse: () => ExpenseCategory.other,
      );
}

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.payerAmounts,
    required this.splitAmounts,
    required this.category,
    required this.createdAt,
    this.note = '',
  });

  final String id;
  final String groupId;
  final String title;
  final double amount;
  /// How much each member contributed toward paying this expense.
  final Map<String, double> payerAmounts;
  final Map<String, double> splitAmounts;
  final ExpenseCategory category;
  final DateTime createdAt;
  final String note;

  bool get hasMultiplePayers => payerAmounts.length > 1;

  double get totalPaid =>
      payerAmounts.values.fold(0.0, (sum, value) => sum + value);

  /// Legacy single-payer id — largest contributor, for older call sites.
  String? get primaryPayerId {
    if (payerAmounts.isEmpty) return null;
    return payerAmounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        title,
        amount,
        payerAmounts,
        splitAmounts,
        category,
        createdAt,
        note,
      ];
}
