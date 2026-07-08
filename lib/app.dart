import 'package:flutter/material.dart';
import 'package:pgold_app/screens/dashboard_screen.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PGold Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: DashboardScreen(dashboardStore: _dashboardStore),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/transaction-details':
            final id = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text('Transaction $id')),
                body: const Center(child: Text('Coming soon...')),
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}
