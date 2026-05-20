import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/mock_data_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);
  List<Order> get activeOrders =>
      _orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList();
  List<Order> get completedOrders =>
      _orders.where((o) => o.status == OrderStatus.delivered).toList();

  OrderProvider() {
    _orders = MockDataService.orders;
  }

  void placeOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _buildCopyWith(idx, OrderStatus.cancelled);
      notifyListeners();
    }
  }

  void confirmReceived(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _buildCopyWith(idx, OrderStatus.delivered,
          deliveredAt: DateTime.now());
      notifyListeners();
    }
  }

  Order _buildCopyWith(int idx, OrderStatus status, {DateTime? deliveredAt}) {
    final o = _orders[idx];
    return Order(
      id: o.id,
      items: o.items,
      status: status,
      totalPrice: o.totalPrice,
      discount: o.discount,
      shippingFee: o.shippingFee,
      addressId: o.addressId,
      paymentMethod: o.paymentMethod,
      createdAt: o.createdAt,
      deliveredAt: deliveredAt ?? o.deliveredAt,
      trackingNumber: o.trackingNumber,
      statusTimeline: o.statusTimeline,
    );
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Order> filterByStatus(OrderStatus? status) {
    if (status == null) return orders;
    return _orders.where((o) => o.status == status).toList();
  }
}
