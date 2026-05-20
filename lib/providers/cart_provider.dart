import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  void addItem(Product product) {
    final existing = _items.where((e) => e.product.id == product.id);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    final item = _items.firstWhere((e) => e.product.id == productId);
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final item = _items.firstWhere((e) => e.product.id == productId);
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.removeWhere((e) => e.product.id == productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
