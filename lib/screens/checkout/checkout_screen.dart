import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with SingleTickerProviderStateMixin {
  String _paymentMethod = '微信支付';
  String? _selectedCoupon;
  bool _submitting = false;
  late final AnimationController _celebCtrl;

  @override
  void initState() {
    super.initState();
    _celebCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _celebCtrl.dispose();
    super.dispose();
  }

  void _submitOrder() {
    final cart = context.read<CartProvider>();
    final user = context.read<UserProvider>();
    final orderProv = context.read<OrderProvider>();
    final addr = user.defaultAddress;
    if (addr == null || cart.items.isEmpty) return;

    setState(() => _submitting = true);

    final order = Order(
      id: 'o${DateTime.now().millisecondsSinceEpoch}',
      items: cart.items.map((item) => OrderItem(
        productId: item.product.id, productName: item.product.name,
        imageUrl: item.product.imageUrl, price: item.product.price,
        quantity: item.quantity,
      )).toList(),
      status: OrderStatus.pending,
      totalPrice: cart.totalPrice,
      discount: 0,
      shippingFee: cart.totalPrice >= 99 ? 0 : 10,
      addressId: addr.id,
      paymentMethod: _paymentMethod,
      createdAt: DateTime.now(),
      statusTimeline: ['下单成功'],
    );
    orderProv.placeOrder(order);
    cart.clear();

    _celebCtrl.forward().then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('下单成功！'), backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
        context.go('/orders');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();
    final user = context.watch<UserProvider>();
    final addr = user.defaultAddress;
    final shippingFee = cart.totalPrice < 99 ? 10.0 : 0.0;
    final total = cart.totalPrice + shippingFee;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('确认订单')),
      body: _submitting
          ? _CelebrationView(controller: _celebCtrl, orderId: DateTime.now().millisecondsSinceEpoch.toString().substring(7))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Address
          _SectionTitle(icon: Icons.location_on_outlined, title: '收货地址'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/address'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100)),
              child: addr != null
                  ? Row(children: [
                Icon(Icons.location_on, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(addr.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(width: 12), Text(addr.phone, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    if (addr.isDefault) ...[const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(3)),
                        child: Text('默认', style: TextStyle(fontSize: 10, color: theme.colorScheme.primary))),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Text(addr.fullAddress, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ])),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ])
                  : Padding(padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(child: Text('请添加收货地址', style: TextStyle(color: Colors.grey.shade500)))),
            ),
          ),

          const SizedBox(height: 20),

          // Order items
          _SectionTitle(icon: Icons.shopping_bag_outlined, title: '商品明细'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100)),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: cart.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8),
                    child: Image.network(item.product.imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('x${item.quantity}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ])),
                  Text('¥${item.subtotal.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary, fontSize: 15)),
                ]),
              )).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Payment
          _SectionTitle(icon: Icons.payment_outlined, title: '支付方式'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100)),
            child: Column(
              children: ['微信支付', '支付宝', '银行卡'].map((method) => RadioListTile<String>(
                title: Text(method, style: const TextStyle(fontSize: 14)), value: method,
                groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v ?? '微信支付'),
                dense: true, visualDensity: VisualDensity.compact,
                activeColor: theme.colorScheme.primary,
              )).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Coupon
          _SectionTitle(icon: Icons.card_giftcard_outlined, title: '优惠券'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/coupons'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100)),
              child: Row(children: [
                Icon(Icons.card_giftcard, color: Colors.orange.shade400, size: 20),
                const SizedBox(width: 10),
                Text(_selectedCoupon ?? '选择优惠券', style: TextStyle(color: _selectedCoupon != null ? Colors.orange.shade600 : Colors.grey.shade500, fontSize: 14)),
                const Spacer(), Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ]),
            ),
          ),

          const SizedBox(height: 24),

          // Price summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100)),
            child: Column(children: [
              _PriceRow('商品总额', '¥${cart.totalPrice.toStringAsFixed(0)}'),
              _PriceRow('运费', shippingFee == 0 ? '免运费' : '¥${shippingFee.toStringAsFixed(0)}', isFree: shippingFee == 0),
              const Divider(height: 16),
              Row(children: [
                const Text('应付总额', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const Spacer(),
                Text('¥${total.toStringAsFixed(0)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
              ]),
            ]),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => _submitOrder(),
            child: Text('立即支付 ¥${total.toStringAsFixed(0)}'),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: Colors.grey.shade600),
      const SizedBox(width: 6),
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isFree;
  const _PriceRow(this.label, this.value, {this.isFree = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, color: isFree ? Colors.green.shade600 : null)),
      ]),
    );
  }
}

class _CelebrationView extends StatelessWidget {
  final AnimationController controller;
  final String orderId;
  const _CelebrationView({required this.controller, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Opacity(
            opacity: (controller.value * 2).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.8 + (controller.value * 0.2),
              child: child,
            ),
          );
        },
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          const Text('下单成功！', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('订单编号: $orderId', style: TextStyle(color: Colors.grey.shade500)),
        ]),
      ),
    );
  }
}
