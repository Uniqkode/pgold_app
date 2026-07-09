import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
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
  bool _isBalanceHidden = false;

  @override
  void initState() {
    super.initState();
    widget.dashboardStore.fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
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
                  Center(
                    child: _StaggeredFadeIn(
                      delayMs: 0,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.12),
                              theme.colorScheme.primary.withValues(alpha: 0.04),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                        child: Text(
                          'Hello, ${store.user!.name}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _StaggeredFadeIn(
                    delayMs: 80,
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
                  _StaggeredFadeIn(
                    delayMs: 160,
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
                          delayMs: 240 + entry.key * 80,
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
              );
            },
          ),
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
