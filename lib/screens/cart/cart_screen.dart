import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  bool _shaking = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _checkout(CartProvider cart) {
    if (cart.items.isEmpty) return;
    setState(() => _shaking = true);
    _shakeCtrl.forward().then((_) {
      _shakeCtrl.reverse().then((_) {
        if (mounted) setState(() => _shaking = false);
      });
    });
    context.push('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('购物车')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Text('购物车是空的',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade400)),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/products'),
                    child: const Text('去逛逛'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Dismissible(
                      key: ValueKey(item.product.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child:
                            const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return true;
                      },
                      onDismissed: (_) {
                        cart.removeItem(item.product.id);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.3),
                                  ),
                                  child: Icon(Icons.image_outlined,
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.2)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '¥${item.product.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity stepper
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove,
                                    onTap: () =>
                                        cart.decreaseQuantity(item.product.id),
                                  ),
                                  AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    transitionBuilder:
                                        (child, animation) =>
                                            ScaleTransition(
                                                scale: animation,
                                                child: child),
                                    child: Text(
                                      '${item.quantity}',
                                      key: ValueKey(
                                          '${item.product.id}_${item.quantity}'),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add,
                                    onTap: () =>
                                        cart.increaseQuantity(item.product.id),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('合计',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500)),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Text(
                              '¥${cart.totalPrice.toStringAsFixed(0)}',
                              key: ValueKey(
                                  'total_${cart.totalPrice.toStringAsFixed(0)}'),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _shakeCtrl,
                          builder: (context, child) {
                            final shake = _shaking
                                ? math.sin(_shakeCtrl.value * math.pi * 2) * 3
                                : 0.0;
                            return Transform.translate(
                              offset: Offset(shake, 0),
                              child: child,
                            );
                          },
                          child: ElevatedButton(
                            onPressed: () => _checkout(cart),
                            child: Text('结算 (${cart.itemCount})'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
