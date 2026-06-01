import 'package:uuid/uuid.dart';

import '../../domain/entities/expense.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member.dart';
import '../datasources/local_ledger_datasource.dart';

class DemoDataService {
  DemoDataService(this._local);

  final LocalLedgerDataSource _local;
  final _uuid = const Uuid();

  Future<Group> seedRoommateDemo() async {
    final alice = Member(id: _uuid.v4(), name: 'Alice', colorHex: 0xFF3D5AFE);
    final bob = Member(id: _uuid.v4(), name: 'Bob', colorHex: 0xFF00D4AA);
    final carol = Member(id: _uuid.v4(), name: 'Carol', colorHex: 0xFF6C5CE7);

    final group = Group(
      id: _uuid.v4(),
      name: 'Roommates (Demo)',
      description: 'Example: shared expenses with multi-payer support',
      members: [alice, bob, carol],
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    );

    await _local.saveGroup(group);

    final splitAll = {
      alice.id: 40.0,
      bob.id: 40.0,
      carol.id: 40.0,
    };

    final expenses = [
      _expense(
        groupId: group.id,
        title: 'Groceries',
        payerAmounts: {alice.id: 120},
        splitAmounts: splitAll,
        category: ExpenseCategory.food,
      ),
      _expense(
        groupId: group.id,
        title: 'Utilities',
        payerAmounts: {bob.id: 90},
        splitAmounts: {
          alice.id: 30.0,
          bob.id: 30.0,
          carol.id: 30.0,
        },
        category: ExpenseCategory.utilities,
      ),
      _expense(
        groupId: group.id,
        title: 'Weekend trip gas',
        payerAmounts: {alice.id: 50, bob.id: 30},
        splitAmounts: {
          alice.id: 26.67,
          bob.id: 26.67,
          carol.id: 26.66,
        },
        category: ExpenseCategory.transport,
      ),
      _expense(
        groupId: group.id,
        title: 'Dinner out',
        payerAmounts: {carol.id: 60},
        splitAmounts: {
          alice.id: 20.0,
          bob.id: 20.0,
          carol.id: 20.0,
        },
        category: ExpenseCategory.food,
      ),
    ];

    for (final e in expenses) {
      await _local.saveExpense(e);
    }

    return group;
  }

  Expense _expense({
    required String groupId,
    required String title,
    required Map<String, double> payerAmounts,
    required Map<String, double> splitAmounts,
    required ExpenseCategory category,
  }) {
    final amount = payerAmounts.values.fold(0.0, (s, v) => s + v);
    return Expense(
      id: _uuid.v4(),
      groupId: groupId,
      title: title,
      amount: amount,
      payerAmounts: payerAmounts,
      splitAmounts: splitAmounts,
      category: category,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    );
  }
}
