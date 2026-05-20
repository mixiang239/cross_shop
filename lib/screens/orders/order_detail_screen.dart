import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.read<OrderProvider>().getOrderById(orderId);
    if (order == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('订单不存在')));
    }

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('订单详情')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [theme.colorScheme.primary, const Color(0xFFFF8F00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Icon(_statusIcon(order.status), color: Colors.white, size: 36),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_statusText(order.status), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(_statusHint(order.status), style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // Timeline
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('物流跟踪', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              ...List.generate(order.statusTimeline.length, (i) {
                final isLast = i == order.statusTimeline.length - 1;
                final isActive = i <= order.statusTimeline.length - 1;
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(children: [
                    Container(width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? theme.colorScheme.primary : Colors.grey.shade300,
                        border: Border.all(color: isActive ? theme.colorScheme.primary : Colors.grey.shade300, width: 2),
                      )),
                    if (!isLast) Container(width: 2, height: 28, color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.grey.shade200),
                  ]),
                  const SizedBox(width: 12),
                  Expanded(child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(order.statusTimeline[i], style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive ? null : Colors.grey.shade500)),
                      if (i == order.statusTimeline.length - 1 && order.trackingNumber.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('快递单号: ${order.trackingNumber}', style: TextStyle(color: Colors.blue.shade600, fontSize: 12)),
                      ],
                    ]),
                  )),
                ]);
              }),
            ]),
          ),
          const SizedBox(height: 20),

          // Products
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('商品信息', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(6),
                    child: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item.productName, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text('x${item.quantity}', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(width: 12),
                  Text('¥${(item.price * item.quantity).toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                ]),
              )),
            ]),
          ),

          const SizedBox(height: 20),

          // Price details
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100)),
            child: Column(children: [
              _row('商品总额', '¥${order.totalPrice.toStringAsFixed(0)}', theme.colorScheme.primary),
              _row('优惠', '-¥${order.discount.toStringAsFixed(0)}', theme.colorScheme.primary),
              _row('运费', order.shippingFee == 0 ? '免运费' : '¥${order.shippingFee.toStringAsFixed(0)}', theme.colorScheme.primary),
              const Divider(height: 16),
              _row('实付款', '¥${order.payableAmount.toStringAsFixed(0)}', theme.colorScheme.primary, isBold: true),
            ]),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color primary, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: isBold ? 18 : 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
          color: isBold ? primary : null)),
      ]),
    );
  }

  IconData _statusIcon(OrderStatus s) => switch (s) {
    OrderStatus.pending => Icons.payment_outlined, OrderStatus.processing => Icons.inventory_outlined,
    OrderStatus.shipped => Icons.local_shipping_outlined, OrderStatus.delivered => Icons.check_circle_outline,
    OrderStatus.cancelled => Icons.cancel_outlined
  };

  String _statusText(OrderStatus s) => switch (s) {
    OrderStatus.pending => '等待付款', OrderStatus.processing => '正在处理',
    OrderStatus.shipped => '正在配送', OrderStatus.delivered => '已签收', OrderStatus.cancelled => '已取消'
  };

  String _statusHint(OrderStatus s) => switch (s) {
    OrderStatus.pending => '请尽快完成支付', OrderStatus.processing => '仓库正在拣货',
    OrderStatus.shipped => '快递正在派送中', OrderStatus.delivered => '感谢您的购买', OrderStatus.cancelled => '订单已取消'
  };
}
