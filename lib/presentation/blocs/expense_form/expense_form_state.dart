part of 'expense_form_cubit.dart';

enum ExpenseFormStatus { initial, loading, ready, failure, submitting }

enum SplitMode { equal, custom }

class ExpenseFormState extends Equatable {
  const ExpenseFormState({
    this.status = ExpenseFormStatus.initial,
    this.group,
    this.isEditing = false,
    this.editingExpenseId,
    this.originalCreatedAt,
    this.title = '',
    this.amountText = '',
    this.splitMode = SplitMode.equal,
    this.splitMemberIds = const {},
    this.splitAmountTexts = const {},
    this.payerAmountTexts = const {},
    this.category = ExpenseCategory.food,
    this.note = '',
    this.validationMessage,
  });

  final ExpenseFormStatus status;
  final Group? group;
  final bool isEditing;
  final String? editingExpenseId;
  final DateTime? originalCreatedAt;
  final String title;
  final String amountText;
  final SplitMode splitMode;
  /// Members who consumed / owe part of this expense.
  final Set<String> splitMemberIds;
  final Map<String, String> splitAmountTexts;
  final Map<String, String> payerAmountTexts;
  final ExpenseCategory category;
  final String note;
  final String? validationMessage;

  double get totalAmount {
    final value = double.tryParse(amountText.replaceAll(',', '').trim());
    return value != null && value > 0 ? value : 0;
  }

  Map<String, double> get parsedPayerAmounts =>
      ExpenseSplitHelper.parsePositiveAmounts(payerAmountTexts);

  Map<String, double> get parsedSplitAmounts =>
      ExpenseSplitHelper.parsePositiveAmounts(
        Map.fromEntries(
          splitAmountTexts.entries.where((e) => splitMemberIds.contains(e.key)),
        ),
      );

  double get equalSharePerPerson {
    if (splitMemberIds.isEmpty || totalAmount <= 0) return 0;
    return totalAmount / splitMemberIds.length;
  }

  double get splitAssignedTotal => parsedSplitAmounts.values.fold(0.0, (s, v) => s + v);

  bool get canSubmit =>
      title.trim().isNotEmpty && totalAmount > 0 && validationMessage == null;

  ExpenseFormState copyWith({
    ExpenseFormStatus? status,
    Group? group,
    bool? isEditing,
    String? editingExpenseId,
    DateTime? originalCreatedAt,
    String? title,
    String? amountText,
    SplitMode? splitMode,
    Set<String>? splitMemberIds,
    Map<String, String>? splitAmountTexts,
    Map<String, String>? payerAmountTexts,
    ExpenseCategory? category,
    String? note,
    String? validationMessage,
    bool clearValidation = false,
  }) =>
      ExpenseFormState(
        status: status ?? this.status,
        group: group ?? this.group,
        isEditing: isEditing ?? this.isEditing,
        editingExpenseId: editingExpenseId ?? this.editingExpenseId,
        originalCreatedAt: originalCreatedAt ?? this.originalCreatedAt,
        title: title ?? this.title,
        amountText: amountText ?? this.amountText,
        splitMode: splitMode ?? this.splitMode,
        splitMemberIds: splitMemberIds ?? this.splitMemberIds,
        splitAmountTexts: splitAmountTexts ?? this.splitAmountTexts,
        payerAmountTexts: payerAmountTexts ?? this.payerAmountTexts,
        category: category ?? this.category,
        note: note ?? this.note,
        validationMessage:
            clearValidation ? null : (validationMessage ?? this.validationMessage),
      );

  @override
  List<Object?> get props => [
        status,
        group,
        isEditing,
        editingExpenseId,
        originalCreatedAt,
        title,
        amountText,
        splitMode,
        splitMemberIds,
        splitAmountTexts,
        payerAmountTexts,
        category,
        note,
        validationMessage,
      ];
}
