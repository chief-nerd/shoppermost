import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/mattermost_api.dart';
import '../../services/database_service.dart';
import '../../models/shopping_item.dart';
import 'shopping_state.dart';

class ShoppingCubit extends Cubit<ShoppingState> {
  final MattermostApi _api;
  final DatabaseService _db;
  String? _channelId;

  ShoppingCubit(this._api, {DatabaseService? db})
      : _db = db ?? DatabaseService(),
        super(ShoppingInitial());

  String? get channelId => _channelId;

  Future<List<Map<String, dynamic>>> getChannels() => _api.getMyChannels();

  Future<void> setChannel(String channelId) async {
    _channelId = channelId;
    await _api.saveChannelId(channelId);
    await loadItems(forceRefresh: true);
  }

  Future<void> loadItems({bool forceRefresh = false}) async {
    if (state is ShoppingInitial || forceRefresh) {
      emit(ShoppingLoading());
    }

    try {
      // Load from DB first for fast initial display
      final cachedItems = await _db.getItems();
      if (cachedItems.isNotEmpty && state is ShoppingLoading) {
        emit(ShoppingLoaded(cachedItems));
      }

      // Load saved channel from preferences
      _channelId ??= await _api.getSavedChannelId();

      if (_channelId == null) {
        emit(
            ShoppingError("No channel selected. Open Settings to choose one."));
        return;
      }

      final messages = await _api.getChannelMessages(_channelId!);
      final List<ShoppingItem> remoteItems = [];

      for (var msg in messages) {
        final text = msg['message'] as String?;
        if (text == null || text.trim().isEmpty) continue;

        // Skip if message has any reactions (meaning it's already "processed")
        final reactions = msg['metadata']?['reactions'] as List?;
        if (reactions != null && reactions.isNotEmpty) continue;

        // Split multi-line messages into individual items
        final lines = text.split('\n');
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          // Remove common list prefixes like "-", "*", "1.", etc.
          final cleanLine =
              line.replaceFirst(RegExp(r'^([\-\*\•\d+\.]+\s+)+'), '');
          if (cleanLine.isEmpty) continue;

          remoteItems.add(ShoppingItem(
            id: i == 0 ? msg['id'] : '${msg['id']}_$i',
            text: cleanLine,
          ));
        }
      }

      // Update DB
      await _db.clearItems();
      await _db.insertItems(remoteItems);

      emit(ShoppingLoaded(remoteItems));
    } catch (e) {
      if (state is! ShoppingLoaded) {
        emit(ShoppingError(e.toString()));
      }
    }
  }

  Future<void> toggleItem(ShoppingItem item) async {
    if (state is ShoppingLoaded) {
      final currentItems = (state as ShoppingLoaded).items;
      final updatedItems = currentItems.map((i) {
        if (i.id == item.id) {
          final updated =
              ShoppingItem(id: i.id, text: i.text, isInCart: !i.isInCart);
          _db.updateItem(updated); // Async update DB
          return updated;
        }
        return i;
      }).toList();
      emit(ShoppingLoaded(updatedItems));
    }
  }

  Future<void> addItem(String text) async {
    try {
      if (_channelId == null) return;
      final success = await _api.postMessage(_channelId!, text);
      if (success) {
        await loadItems(forceRefresh: true);
      } else {
        emit(ShoppingError("Failed to add item"));
      }
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> checkout() async {
    if (state is ShoppingLoaded) {
      final boughtItems =
          (state as ShoppingLoaded).items.where((i) => i.isInCart).toList();
      if (boughtItems.isEmpty) return;

      emit(ShoppingLoading());
      try {
        // Extract original post IDs to avoid duplicate reactions if a message was split
        final postIdsToReact = boughtItems.map((item) {
          final parts = item.id.split('_');
          return parts[0];
        }).toSet();

        await Future.wait(postIdsToReact
            .map((postId) => _api.addReaction(postId, 'shopping_bags')));
        await loadItems(forceRefresh: true);
      } catch (e) {
        emit(ShoppingError(e.toString()));
      }
    }
  }
}
