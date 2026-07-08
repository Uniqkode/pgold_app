import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pgold_app/stores/dashboard_store.dart';
import 'package:pgold_app/widgets/empty_state_widget.dart';
import 'package:pgold_app/widgets/error_widget.dart';
import 'package:pgold_app/widgets/loading_widget.dart';
import 'package:pgold_app/widgets/transaction_card.dart';
import 'package:pgold_app/widgets/wallet_header.dart';

class DashboardScreen extends StatefulWidget {
  final DashboardStore dashboardStore;

  const DashboardScreen({super.key, required this.dashboardStore});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    widget.dashboardStore.fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PGold Wallet'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => widget.dashboardStore.fetchDashboard(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => widget.dashboardStore.fetchDashboard(),
        child: Observer(
          builder: (_) {
            final store = widget.dashboardStore;

            if (store.isLoading) {
              return const LoadingWidget();
            }

            if (store.error != null) {
              return AppErrorWidget(
                message: store.error!,
                onRetry: () => store.fetchDashboard(),
              );
            }

            if (store.isEmpty) {
              return const EmptyStateWidget();
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: WalletHeader(user: store.user!),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...store.transactions.map(
                  (txn) => TransactionCard(
                    transaction: txn,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/transaction-details',
                        arguments: txn.id,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
