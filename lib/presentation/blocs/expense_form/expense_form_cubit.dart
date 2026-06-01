import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/expense.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/usecases/add_expense.dart';
import '../../../domain/usecases/delete_expense.dart';
import '../../../domain/usecases/get_group_by_id.dart';
import '../../../domain/usecases/update_expense.dart';

part 'expense_form_state.dart';

class ExpenseFormCubit extends Cubit<ExpenseFormState> {
  ExpenseFormCubit(
    this._getGroup,
    this._addExpense,
    this._updateExpense,
    this._deleteExpense,
  ) : super(const ExpenseFormState());

  final GetGroupById _getGroup;
  final AddExpense _addExpense;
  final UpdateExpense _updateExpense;
  final DeleteExpense _deleteExpense;

  Future<void> init({required String groupId, Expense? expense}) async {
    emit(state.copyWith(status: ExpenseFormStatus.loading));
    final group = await _getGroup(groupId);
    if (group == null) {
      emit(state.copyWith(status: ExpenseFormStatus.failure));
      return;
    }

    final allMemberIds = group.members.map((m) => m.id).toSet();

    if (expense != null) {
      final splitIds = expense.splitAmounts.entries
          .where((e) => e.value > 0.001)
          .map((e) => e.key)
          .toSet();
      final participants = splitIds.isEmpty ? allMemberIds : splitIds;

      emit(state.copyWith(
        status: ExpenseFormStatus.ready,
        group: group,
        isEditing: true,
        editingExpenseId: expense.id,
        originalCreatedAt: expense.createdAt,
        title: expense.title,
        amountText: expense.amount.toStringAsFixed(2),
        category: expense.category,
        note: expense.note,
        splitMode: _detectSplitMode(expense.splitAmounts, participants),
        splitMemberIds: participants,
        splitAmountTexts: {
          for (final m in group.members)
            m.id: expense.splitAmounts[m.id]?.toStringAsFixed(2) ?? '',
        },
        payerAmountTexts: {
          for (final m in group.members)
            m.id: expense.payerAmounts[m.id]?.toStringAsFixed(2) ?? '',
        },
        clearValidation: true,
      ));
      return;
    }

    emit(state.copyWith(
      status: ExpenseFormStatus.ready,
      group: group,
      splitMemberIds: allMemberIds,
      splitAmountTexts: {for (final m in group.members) m.id: ''},
      payerAmountTexts: {for (final m in group.members) m.id: ''},
      clearValidation: true,
    ));
  }

  SplitMode _detectSplitMode(Map<String, double> splits, Set<String> ids) {
    if (ids.length <= 1) return SplitMode.equal;
    final values = ids.map((id) => splits[id] ?? 0).where((v) => v > 0).toList();
    if (values.isEmpty) return SplitMode.equal;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final equal = values.every((v) => (v - mean).abs() < 0.03);
    return equal ? SplitMode.equal : SplitMode.custom;
  }

  void setTitle(String v) => emit(state.copyWith(title: v, clearValidation: true));

  void setAmount(String v) => emit(state.copyWith(amountText: v, clearValidation: true));

  void setCategory(ExpenseCategory c) => emit(state.copyWith(category: c));

  void setNote(String v) => emit(state.copyWith(note: v));

  void setSplitMode(SplitMode mode) {
    if (mode == SplitMode.custom) {
      emit(state.copyWith(
        splitMode: mode,
        splitAmountTexts: _equalSplitTexts(),
        clearValidation: true,
      ));
      return;
    }
    emit(state.copyWith(splitMode: mode, clearValidation: true));
  }

  void toggleSplitMember(String memberId, bool included) {
    final ids = Set<String>.from(state.splitMemberIds);
    if (included) {
      ids.add(memberId);
    } else if (ids.length > 1) {
      ids.remove(memberId);
      if (state.splitMode == SplitMode.custom) {
        final texts = Map<String, String>.from(state.splitAmountTexts);
        texts[memberId] = '';
        emit(state.copyWith(
          splitMemberIds: ids,
          splitAmountTexts: texts,
          clearValidation: true,
        ));
        return;
      }
    }
    emit(state.copyWith(splitMemberIds: ids, clearValidation: true));
  }

  void setSplitAmount(String memberId, String text) {
    final texts = Map<String, String>.from(state.splitAmountTexts);
    texts[memberId] = text;
    emit(state.copyWith(
      splitMode: SplitMode.custom,
      splitAmountTexts: texts,
      clearValidation: true,
    ));
  }

  void splitSharesEvenly() {
    emit(state.copyWith(
      splitMode: SplitMode.equal,
      splitAmountTexts: _equalSplitTexts(),
      clearValidation: true,
    ));
  }

  void setPayerAmount(String memberId, String text) {
    final texts = Map<String, String>.from(state.payerAmountTexts);
    texts[memberId] = text;
    emit(state.copyWith(payerAmountTexts: texts, clearValidation: true));
  }

  void assignFullTotalToPayer(String memberId) {
    final group = state.group;
    if (group == null || state.totalAmount <= 0) return;
    final texts = {for (final m in group.members) m.id: ''};
    texts[memberId] = state.totalAmount.toStringAsFixed(2);
    emit(state.copyWith(payerAmountTexts: texts, clearValidation: true));
  }

  void splitContributionsEvenly() {
    final group = state.group;
    final total = state.totalAmount;
    if (group == null || total <= 0) return;

    final active = state.payerAmountTexts.entries
        .where((e) => (double.tryParse(e.value.replaceAll(',', '')) ?? 0) > 0)
        .map((e) => e.key)
        .toList();
    final ids = active.isNotEmpty
        ? active
        : group.members.map((m) => m.id).toList();

    final share = total / ids.length;
    final texts = Map<String, String>.from(state.payerAmountTexts);
    for (final m in group.members) {
      texts[m.id] = ids.contains(m.id) ? share.toStringAsFixed(2) : '';
    }
    _fixRounding(texts, ids, total);
    emit(state.copyWith(payerAmountTexts: texts, clearValidation: true));
  }

  Map<String, double> _buildSplitAmounts() {
    final total = state.totalAmount;
    final ids = state.splitMemberIds.toList();
    if (state.splitMode == SplitMode.equal) {
      return ExpenseSplitHelper.equalSplit(ids, total);
    }
    return state.parsedSplitAmounts;
  }

  String? _validate() {
    if (state.title.trim().isEmpty) return 'Add a title for this expense.';
    if (state.totalAmount <= 0) return 'Enter the total price.';
    if (state.splitMemberIds.isEmpty) {
      return 'Select at least one person who shared this expense.';
    }

    final splitAmounts = _buildSplitAmounts();
    final splitSum = splitAmounts.values.fold(0.0, (s, v) => s + v);
    if (splitAmounts.isEmpty) {
      return 'Enter how much each person owes.';
    }
    if ((splitSum - state.totalAmount).abs() > 0.02) {
      return 'Shares (${splitSum.toStringAsFixed(2)}) must equal total '
          '(${state.totalAmount.toStringAsFixed(2)}).';
    }

    final payers = state.parsedPayerAmounts;
    if (payers.isEmpty) return 'Enter who paid (contributions must sum to total).';
    final payerSum = payers.values.fold(0.0, (s, v) => s + v);
    if ((payerSum - state.totalAmount).abs() > 0.02) {
      return 'Contributions (${payerSum.toStringAsFixed(2)}) must equal total '
          '(${state.totalAmount.toStringAsFixed(2)}).';
    }
    return null;
  }

  Future<bool> submit() async {
    final group = state.group;
    if (group == null) return false;

    final validation = _validate();
    if (validation != null) {
      emit(state.copyWith(validationMessage: validation));
      return false;
    }

    final amount = state.totalAmount;
    final splitAmounts = _buildSplitAmounts();
    final payerAmounts = state.parsedPayerAmounts;

    emit(state.copyWith(status: ExpenseFormStatus.submitting, clearValidation: true));
    try {
      if (state.isEditing && state.editingExpenseId != null) {
        await _updateExpense(UpdateExpenseParams(
          expenseId: state.editingExpenseId!,
          groupId: group.id,
          title: state.title,
          amount: amount,
          payerAmounts: payerAmounts,
          category: state.category,
          splitAmounts: splitAmounts,
          createdAt: state.originalCreatedAt ?? DateTime.now(),
          note: state.note,
        ));
      } else {
        await _addExpense(AddExpenseParams(
          groupId: group.id,
          title: state.title,
          payerAmounts: payerAmounts,
          category: state.category,
          splitAmounts: splitAmounts,
          note: state.note,
        ));
      }
      return true;
    } catch (_) {
      emit(state.copyWith(
        status: ExpenseFormStatus.ready,
        validationMessage: 'Could not save expense.',
      ));
      return false;
    }
  }

  Future<void> delete(Expense expense) => _deleteExpense(expense);

  Map<String, String> _equalSplitTexts() {
    final group = state.group;
    if (group == null || state.totalAmount <= 0 || state.splitMemberIds.isEmpty) {
      return state.splitAmountTexts;
    }
    final splits =
        ExpenseSplitHelper.equalSplit(state.splitMemberIds.toList(), state.totalAmount);
    final texts = Map<String, String>.from(state.splitAmountTexts);
    for (final m in group.members) {
      texts[m.id] =
          splits.containsKey(m.id) ? splits[m.id]!.toStringAsFixed(2) : '';
    }
    return texts;
  }

  void _fixRounding(Map<String, String> texts, List<String> ids, double total) {
    if (ids.isEmpty) return;
    var sum = 0.0;
    for (final id in ids) {
      sum += double.tryParse(texts[id]?.replaceAll(',', '') ?? '') ?? 0;
    }
    final diff = total - sum;
    if (diff.abs() > 0.001) {
      final first = ids.first;
      final current = double.tryParse(texts[first]?.replaceAll(',', '') ?? '') ?? 0;
      texts[first] = (current + diff).toStringAsFixed(2);
    }
  }
}
