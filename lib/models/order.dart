enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class Order {
  final String id;
  final List<OrderItem> items;
  final OrderStatus status;
  final double totalPrice;
  final double discount;
  final double shippingFee;
  final String addressId;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String trackingNumber;
  final List<String> statusTimeline;

  const Order({
    required this.id,
    required this.items,
    required this.status,
    required this.totalPrice,
    this.discount = 0,
    this.shippingFee = 0,
    required this.addressId,
    required this.paymentMethod,
    required this.createdAt,
    this.deliveredAt,
    this.trackingNumber = '',
    this.statusTimeline = const [],
  });

  double get payableAmount => totalPrice - discount + shippingFee;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final String? sku;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.sku,
  });
}
