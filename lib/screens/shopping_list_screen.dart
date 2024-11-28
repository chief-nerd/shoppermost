import 'package:flutter/material.dart';
import 'package:shoppermost/cubit/api/api_cubit.dart';
import '../models/shopping_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> items = [];
  static const String channelId = 'eqt3j8idztf3bmmdz7xsy3oopc';
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadShoppingList();
  }

  bool _hasReactions(Map<String, dynamic> msg) {
    final reactions = msg['metadata']?['reactions'] as List?;
    return reactions != null && reactions.isNotEmpty;
  }

  bool _hasText(Map<String, dynamic> msg) {
    return msg['message'] != null && msg['message'].isNotEmpty;
  }

  Future<void> loadShoppingList() async {
    // Store currently bought items before reload
    final boughtItemIds = items.where((item) => item.isInCart).map((item) => item.id).toSet();

    final authCubit = context.read<ApiCubit>();
    final api = authCubit.state;

    final messages = await api.getChannelMessages(channelId);

    setState(() {
      items = messages
          .where((msg) => _hasText(msg))
          .where((msg) => !_hasReactions(msg))
          .map((msg) => ShoppingItem(
                id: msg['id'],
                text: msg['message'],
                isInCart: boughtItemIds.contains(msg['id']),
              ))
          .toList();
    });
  }

  Future<void> _completeShoppingList() async {
    final apiCubit = context.read<ApiCubit>();
    final api = apiCubit.state;

    final boughtItems = items.where((item) => item.isInCart);

    for (final item in boughtItems) {
      await api.addReaction(item.id, 'shopping_bags'); // Changed to 'white_check_mark'
    }

    await loadShoppingList();
  }

  Future<void> _handleSubmit() async {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final apiCubit = context.read<ApiCubit>();
      final api = apiCubit.state;
      if (await api.postMessage(channelId, text)) {
        _textController.clear();
        await loadShoppingList();
      }
    }
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
                onPressed: loadShoppingList,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasItemsInCart = items.any((item) => item.isInCart);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          FilledButton.icon(
            onPressed: hasItemsInCart ? _completeShoppingList : null,
            icon: const Icon(Icons.done_all),
            label: const Text('Checkout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadShoppingList,
              child: items.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text((item.text)),
                          trailing: Icon(
                            item.isInCart ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                            color: item.isInCart ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                          ),
                          onTap: () {
                            // Toggle item status
                            setState(() {
                              items[index] = ShoppingItem(
                                id: item.id,
                                text: item.text,
                                isInCart: !item.isInCart,
                              );
                            });
                          },
                        );
                      },
                    ),
            ),
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
      ),
    );
  }
}
