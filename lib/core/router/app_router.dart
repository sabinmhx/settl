import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settl/presentation/blocs/group_detail/group_detail_event.dart';
import 'package:settl/presentation/blocs/groups_list/groups_list_event.dart';

import '../../domain/entities/expense.dart';
import '../../domain/entities/group.dart';
import '../../presentation/blocs/analytics/analytics_bloc.dart';
import '../../presentation/blocs/create_group/create_group_cubit.dart';
import '../../presentation/blocs/expense_form/expense_form_cubit.dart';
import '../../presentation/blocs/graph/graph_bloc.dart';
import '../../presentation/blocs/group_detail/group_detail_bloc.dart';
import '../../presentation/blocs/groups_list/groups_list_bloc.dart';
import '../../presentation/blocs/settlement/settlement_bloc.dart';
import '../../presentation/pages/create_group_page.dart';
import '../../presentation/pages/expense_form_page.dart';
import '../../presentation/pages/group_detail_page.dart';
import '../../presentation/pages/group_insights_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/settlement_page.dart';
import '../di/injection.dart';

class AppRoutes {
  static const home = '/';
  static const createGroup = '/groups/create';
  static const groupDetail = '/groups/:id';
  static const addExpense = '/groups/:id/expenses/add';
  static const editExpense = '/groups/:id/expenses/edit';
  static const settlements = '/groups/:id/settlement';
  static const insights = '/groups/:id/insights';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              GroupsListBloc(sl(), sl(), sl(), sl())..add(GroupsListStarted()),
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.createGroup,
        builder: (context, state) => BlocProvider(
          create: (_) => CreateGroupCubit(sl()),
          child: const CreateGroupPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.groupDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) =>
                GroupDetailBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl())
                  ..add(GroupDetailStarted(id)),
            child: GroupDetailPage(groupId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addExpense,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) =>
                ExpenseFormCubit(sl(), sl(), sl(), sl())..init(groupId: id),
            child: ExpenseFormPage(groupId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editExpense,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final expense = state.extra as Expense;
          return BlocProvider(
            create: (_) =>
                ExpenseFormCubit(sl(), sl(), sl(), sl())
                  ..init(groupId: id, expense: expense),
            child: ExpenseFormPage(groupId: id, expenseToEdit: expense),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settlements,
        builder: (context, state) {
          final group = state.extra as Group;
          return BlocProvider(
            create: (_) =>
                SettlementBloc(sl(), sl(), sl(), sl(), sl(), sl())
                  ..add(SettlementStarted(group.id)),
            child: SettlementPage(group: group),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.insights,
        builder: (context, state) {
          final group = state.extra as Group;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => GraphBloc(sl())..add(GraphStarted(group.id)),
              ),
              BlocProvider(
                create: (_) =>
                    AnalyticsBloc(sl(), sl(), sl())
                      ..add(AnalyticsStarted(group)),
              ),
            ],
            child: GroupInsightsPage(group: group),
          );
        },
      ),
    ],
  );
}
