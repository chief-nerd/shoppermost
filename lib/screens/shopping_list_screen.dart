import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth/auth_cubit.dart';
import '../cubit/shopping/shopping_cubit.dart';
import '../cubit/shopping/shopping_state.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛍️ Shopping'),
        actions: [
          BlocBuilder<ShoppingCubit, ShoppingState>(
            builder: (context, state) {
              final hasItemsInCart = state is ShoppingLoaded &&
                  state.items.any((item) => item.isInCart);
              return FilledButton.icon(
                onPressed: hasItemsInCart
                    ? () => context.read<ShoppingCubit>().checkout()
                    : null,
                icon: const Icon(Icons.done_all),
                label: const Text('Checkout'),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) {
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: context.read<ShoppingCubit>()),
                      BlocProvider.value(value: context.read<AuthCubit>()),
                    ],
                    child: const SettingsScreen(),
                  );
                }),
              );
              if (context.mounted) {
                context.read<ShoppingCubit>().loadItems(forceRefresh: true);
              }
            },
          ),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Add new item',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _handleSubmit(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _handleSubmit,
                    ),
                  ],
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
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Dismissible(
              key: Key(item.id),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                context.read<ShoppingCubit>().toggleItem(item);
                return false; // Stay in list
              },
              background: Container(
                color: Colors.green.withOpacity(0.5),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.green.withOpacity(0.5),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
              child: ListTile(
                title: Text(item.text),
                trailing: Icon(
                  item.isInCart
                      ? Icons.shopping_cart
                      : Icons.shopping_cart_outlined,
                  color: item.isInCart
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                ),
                onTap: () => context.read<ShoppingCubit>().toggleItem(item),
              ),
            );
          },
        ),
      );
    }

    if (state is ShoppingError) {
      final needsChannel = state.error.contains('No channel selected');
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(needsChannel ? 'No channel selected' : 'An error occurred'),
            const SizedBox(height: 16),
            if (needsChannel)
              FilledButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) {
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider.value(
                              value: context.read<ShoppingCubit>()),
                          BlocProvider.value(value: context.read<AuthCubit>()),
                        ],
                        child: const SettingsScreen(),
                      );
                    }),
                  );
                  if (context.mounted) {
                    context.read<ShoppingCubit>().loadItems(forceRefresh: true);
                  }
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              )
            else
              ElevatedButton(
                onPressed: () =>
                    context.read<ShoppingCubit>().loadItems(forceRefresh: true),
                child: const Text('Retry'),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No items in shopping list',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () =>
                    context.read<ShoppingCubit>().loadItems(forceRefresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
