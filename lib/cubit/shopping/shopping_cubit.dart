import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/mattermost_api.dart';
import '../../models/shopping_item.dart';
import 'shopping_state.dart';

class ShoppingCubit extends Cubit<ShoppingState> {
  final MattermostApi _api;

  ShoppingCubit(this._api) : super(ShoppingInitial());

  Future<void> loadItems() async {
    emit(ShoppingLoading());
    try {
      final messages = await _api.getChannelMessages('shopping');
      final items = messages.map((m) => ShoppingItem(id: m['id'], text: m['message'], isInCart: m['reactions']?.any((r) => r['emoji_name'] == 'thumbsup') ?? false)).toList();
      emit(ShoppingLoaded(items));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }
}
