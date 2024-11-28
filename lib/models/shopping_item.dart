class ShoppingItem {
  final String id;
  final String text;
  final bool isInCart;

  ShoppingItem({
    required this.id,
    required this.text,
    this.isInCart = false,
  });
}
