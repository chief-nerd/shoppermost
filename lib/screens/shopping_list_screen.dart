import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth/auth_cubit.dart';
import '../cubit/shopping/shopping_cubit.dart';
import '../cubit/shopping/shopping_state.dart';
import '../cubit/theme/theme_cubit.dart';
import 'settings_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ShoppingCubit>().loadItems();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<ShoppingCubit>().addItem(text);
      _textController.clear();
    }
  }

  void _navigateToSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ShoppingCubit>()),
            BlocProvider.value(value: context.read<AuthCubit>()),
            BlocProvider.value(value: context.read<ThemeCubit>()),
          ],
          child: const SettingsScreen(),
        );
      }),
    );
    if (context.mounted) {
      context.read<ShoppingCubit>().loadItems(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping'),
        actions: [
          BlocBuilder<ShoppingCubit, ShoppingState>(
            builder: (context, state) {
              final hasItemsInCart = state is ShoppingLoaded &&
                  state.items.any((item) => item.isInCart);
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: FilledButton.icon(
                  onPressed: hasItemsInCart
                      ? () => context.read<ShoppingCubit>().checkout()
                      : null,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Checkout'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: _navigateToSettings,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocConsumer<ShoppingCubit, ShoppingState>(
        listener: (context, state) {
          if (state is ShoppingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: _buildMainContent(state),
              ),
              // ── Input bar ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? cs.surface,
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Add an item…',
                          ),
                          onSubmitted: (_) => _handleSubmit(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.arrow_upward_rounded),
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(ShoppingState state) {
    if (state is ShoppingLoading && state is! ShoppingLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ShoppingLoaded) {
      final items = state.items;
      if (items.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () =>
            context.read<ShoppingCubit>().loadItems(forceRefresh: true),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final item = items[index];
            final cs = Theme.of(context).colorScheme;
            return Dismissible(
              key: Key(item.id),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                context.read<ShoppingCubit>().toggleItem(item);
                return false;
              },
              background: Container(
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Icon(Icons.shopping_cart_rounded, color: cs.primary),
              ),
              secondaryBackground: Container(
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Icon(Icons.shopping_cart_rounded, color: cs.primary),
              ),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.isInCart
                          ? cs.primary.withValues(alpha: 0.15)
                          : cs.onSurface.withValues(alpha: 0.06),
                    ),
                    child: Icon(
                      item.isInCart
                          ? Icons.check_rounded
                          : Icons.circle_outlined,
                      size: 18,
                      color: item.isInCart
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  title: Text(
                    item.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration:
                          item.isInCart ? TextDecoration.lineThrough : null,
                      color: item.isInCart
                          ? cs.onSurface.withValues(alpha: 0.45)
                          : cs.onSurface,
                    ),
                  ),
                  trailing: Icon(
                    item.isInCart
                        ? Icons.shopping_cart_rounded
                        : Icons.shopping_cart_outlined,
                    color: item.isInCart
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.25),
                    size: 20,
                  ),
                  onTap: () => context.read<ShoppingCubit>().toggleItem(item),
                ),
              ),
            );
          },
        ),
      );
    }

    if (state is ShoppingError) {
      final needsChannel = state.error.contains('No channel selected');
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.error.withValues(alpha: 0.1),
                ),
                child: Icon(
                  needsChannel
                      ? Icons.link_off_rounded
                      : Icons.error_outline_rounded,
                  size: 36,
                  color: cs.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                needsChannel ? 'No channel selected' : 'Something went wrong',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                needsChannel
                    ? 'Pick a Mattermost channel in settings to get started.'
                    : 'Please try again or check your connection.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 28),
              if (needsChannel)
                FilledButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) {
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                                value: context.read<ShoppingCubit>()),
                            BlocProvider.value(
                                value: context.read<AuthCubit>()),
                            BlocProvider.value(
                                value: context.read<ThemeCubit>()),
                          ],
                          child: const SettingsScreen(),
                        );
                      }),
                    );
                    if (mounted) {
                      context
                          .read<ShoppingCubit>()
                          .loadItems(forceRefresh: true);
                    }
                  },
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Open Settings'),
                )
              else
                FilledButton.icon(
                  onPressed: () => context
                      .read<ShoppingCubit>()
                      .loadItems(forceRefresh: true),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 40,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your list is empty',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add items below or pull down to refresh.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () =>
                  context.read<ShoppingCubit>().loadItems(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
