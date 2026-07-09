import 'package:flutter/material.dart';
import 'package:pgold_app/routes/app_router.dart';
import 'package:pgold_app/utils/colors.dart';
import 'package:pgold_app/services/mock_api_service.dart';
import 'package:pgold_app/stores/dashboard_store.dart';

class PGoldApp extends StatefulWidget {
  const PGoldApp({super.key});

  @override
  State<PGoldApp> createState() => _PGoldAppState();
}

class _PGoldAppState extends State<PGoldApp> {
  final _apiService = MockApiService();
  late final DashboardStore _dashboardStore;

  @override
  void initState() {
    super.initState();
    _dashboardStore = DashboardStore(_apiService);
    _apiService.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PGold Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter(_apiService, _dashboardStore),
    );
  }
}
