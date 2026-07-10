import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/services/mock_api_service.dart';
import 'package:pgold_app/stores/dashboard_store.dart';
import 'package:pgold_app/widgets/empty_state_widget.dart';
import 'package:pgold_app/widgets/error_widget.dart';
import 'package:pgold_app/widgets/loading_widget.dart';
import 'package:pgold_app/widgets/transaction_card.dart';
import 'package:pgold_app/widgets/wallet_header.dart';

class DashboardScreen extends StatefulWidget {
  final DashboardStore dashboardStore;
  final ApiService apiService;

  const DashboardScreen({
    super.key,
    required this.dashboardStore,
    required this.apiService,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isBalanceHidden = false;
  bool _mockEmptyTxns = false;
  bool _mockDashboardError = false;
  bool _mockTxnNotFound = false;

  MockApiService get _mockService => widget.apiService as MockApiService;

  @override
  void initState() {
    super.initState();
    widget.dashboardStore.fetchDashboard();
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.bug_report_rounded,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dev Settings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Simulate edge cases',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: const Text('Empty Transactions'),
              subtitle: const Text('Dashboard shows no transactions'),
              value: _mockEmptyTxns,
              onChanged: (value) {
                setState(() => _mockEmptyTxns = value);
                _mockService.setEmptyTransactions(value);
                widget.dashboardStore.fetchDashboard();
              },
            ),
            SwitchListTile(
              title: const Text('Dashboard Error'),
              subtitle: const Text('Dashboard load fails with error'),
              value: _mockDashboardError,
              onChanged: (value) {
                setState(() => _mockDashboardError = value);
                _mockService.setDashboardFailure(value);
                widget.dashboardStore.fetchDashboard();
              },
            ),
            SwitchListTile(
              title: const Text('Transaction Not Found'),
              subtitle: const Text('Tapping a txn shows not found'),
              value: _mockTxnNotFound,
              onChanged: (value) {
                setState(() => _mockTxnNotFound = value);
                _mockService.setTransactionNotFound(value);
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Toggle on, then refresh or tap a transaction to test.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: _buildDrawer(theme),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Observer(
          builder: (_) {
            final name = widget.dashboardStore.user?.name;
            if (name == null) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.10),
                    theme.colorScheme.primary.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                'Hello, $name',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            );
          },
        ),
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

            if (store.user == null) {
              return const SizedBox.shrink();
            }

            if (store.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                children: [
                  _StaggeredFadeIn(
                    delayMs: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: WalletHeader(
                        user: store.user!,
                        isBalanceHidden: _isBalanceHidden,
                        onToggleVisibility: () {
                          setState(() => _isBalanceHidden = !_isBalanceHidden);
                        },
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: EmptyStateWidget(),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
              children: [
                _StaggeredFadeIn(
                  delayMs: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: WalletHeader(
                      user: store.user!,
                      isBalanceHidden: _isBalanceHidden,
                      onToggleVisibility: () {
                        setState(() => _isBalanceHidden = !_isBalanceHidden);
                      },
                    ),
                  ),
                ),
                if (!store.isEmpty) ...[
                  _StaggeredFadeIn(
                    delayMs: 80,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push('/transfer-history');
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('View All'),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...store.transactions
                      .take(3)
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (entry) => _StaggeredFadeIn(
                          delayMs: 120 + entry.key * 80,
                          child: TransactionCard(
                            transaction: entry.value,
                            onTap: () {
                              context.push(
                                '/transaction-details/${entry.value.id}',
                              );
                            },
                          ),
                        ),
                      ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StaggeredFadeIn extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _StaggeredFadeIn({required this.child, this.delayMs = 0});

  @override
  State<_StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<_StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(_animation),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
