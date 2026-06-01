import 'package:get_it/get_it.dart';

import '../../data/datasources/local_ledger_datasource.dart';
import '../../data/repositories/ledger_repository_impl.dart';
import '../../data/services/pdf_report_service.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../../domain/services/group_analytics_service.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/create_group.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/delete_group.dart';
import '../../domain/usecases/export_pdf_report.dart';
import '../../domain/usecases/get_analytics.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/get_graph_snapshot.dart';
import '../../domain/usecases/get_group_by_id.dart';
import '../../domain/usecases/get_groups.dart';
import '../../domain/usecases/get_settlement.dart';
import '../../domain/usecases/get_settlement_payments.dart';
import '../../domain/usecases/save_settlement_payment.dart';
import '../../domain/usecases/delete_settlement_payment.dart';
import '../../domain/usecases/update_expense.dart';
import '../../domain/usecases/update_group_members.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final local = LocalLedgerDataSourceImpl();
  await local.init();
  sl.registerSingleton<LocalLedgerDataSource>(local);

  sl.registerLazySingleton(GroupAnalyticsService.new);
  sl.registerLazySingleton(PdfReportService.new);

  sl.registerLazySingleton<LedgerRepository>(
    () => LedgerRepositoryImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton(() => GetGroups(sl()));
  sl.registerLazySingleton(() => GetGroupById(sl()));
  sl.registerLazySingleton(() => CreateGroup(sl()));
  sl.registerLazySingleton(() => DeleteGroup(sl()));
  sl.registerLazySingleton(() => AddMember(sl()));
  sl.registerLazySingleton(() => RemoveMember(sl()));
  sl.registerLazySingleton(() => GetExpenses(sl()));
  sl.registerLazySingleton(() => AddExpense(sl()));
  sl.registerLazySingleton(() => UpdateExpense(sl()));
  sl.registerLazySingleton(() => DeleteExpense(sl()));
  sl.registerLazySingleton(() => GetSettlement(sl()));
  sl.registerLazySingleton(() => GetSettlementPayments(sl()));
  sl.registerLazySingleton(() => SaveSettlementPayment(sl()));
  sl.registerLazySingleton(() => DeleteSettlementPayment(sl()));
  sl.registerLazySingleton(() => GetGraphSnapshot(sl()));
  sl.registerLazySingleton(() => GetAnalytics(sl()));
  sl.registerLazySingleton(() => ExportPdfReport(sl()));
}
