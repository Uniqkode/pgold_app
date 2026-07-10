import 'package:go_router/go_router.dart';
import 'package:pgold_app/screens/dashboard_screen.dart';
import 'package:pgold_app/screens/report_screen.dart';
import 'package:pgold_app/screens/splash_screen.dart';
import 'package:pgold_app/screens/transfer_history_screen.dart';
import 'package:pgold_app/screens/transaction_detail_screen.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/stores/dashboard_store.dart';

GoRouter appRouter(ApiService apiService, DashboardStore dashboardStore) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => DashboardScreen(
          dashboardStore: dashboardStore,
          apiService: apiService,
        ),
      ),
      GoRoute(
        path: '/transfer-history',
        builder: (context, state) => TransferHistoryScreen(
          apiService: apiService,
        ),
      ),
      GoRoute(
        path: '/transaction-details/:id',
        builder: (context, state) => TransactionDetailScreen(
          transactionId: state.pathParameters['id']!,
          apiService: apiService,
        ),
      ),
      GoRoute(
        path: '/report-transaction/:id',
        builder: (context, state) => ReportScreen(
          transactionId: state.pathParameters['id']!,
          apiService: apiService,
        ),
      ),
    ],
  );
}
