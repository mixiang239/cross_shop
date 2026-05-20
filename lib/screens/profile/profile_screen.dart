import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/user_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/notification_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();
    final orders = context.watch<OrderProvider>().orders;
    final unreadNum = context.watch<NotificationProvider>().unreadCount;
    final activeOrders = orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length;
    final completedOrders = orders.where((o) => o.status == OrderStatus.delivered).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(slivers: [
        // Gradient header
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 60, 16, 0),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8F00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFFFF6B35).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Row(children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, child) => Transform.scale(scale: 1 + (_pulseCtrl.value * 0.05), child: child),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2)),
                  child: CircleAvatar(radius: 34, backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(Icons.person_rounded, size: 36, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user.isLoggedIn ? user.userName : '登录/注册',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(user.isLoggedIn ? '欢迎回来' : '登录后享受专属优惠与权益',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                ]),
              ),
              GestureDetector(
                onTap: () {
                  if (!user.isLoggedIn) {
                    user.login('CrossShop用户', '');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('登录成功！'), behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.green.shade600));
                  }
                },
                child: Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6)),
              ),
            ]),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Orders card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade100)),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 12, 4),
                  child: Row(children: [
                    const Text('我的订单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton(onPressed: () => context.push('/orders'),
                      child: Text('查看全部 $activeOrders', style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
                  ]),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _orderItem(Icons.payment_outlined, '待付款', () => context.push('/orders')),
                    _orderItem(Icons.local_shipping_outlined, '待发货', () => context.push('/orders')),
                    _orderItem(Icons.inbox_outlined, '待收货', () => context.push('/orders')),
                    _orderItem(Icons.rate_review_outlined, '待评价', () {}, badge: activeOrders),
                  ]),
                ),
              ]),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // Menu group 1
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade100)),
              child: Column(children: [
                _menuTile(Icons.card_giftcard_outlined, '优惠券', () => context.push('/coupons'),
                  trailing: Text('5张可用', style: TextStyle(fontSize: 12, color: Colors.orange.shade600))),
                _divider(),
                _menuTile(Icons.favorite_outline, '我的收藏', () => context.push('/favorites'),
                  trailing: Text('${user.favoriteCount}', style: TextStyle(fontSize: 12, color: Colors.grey.shade400))),
                _divider(),
                _menuTile(Icons.location_on_outlined, '收货地址', () => context.push('/address')),
                _divider(),
                _menuTile(Icons.notifications_outlined, '消息中心', () => context.push('/notifications'),
                  trailing: unreadNum > 0 ? Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    child: Text('$unreadNum', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))) : null),
              ]),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // Menu group 2
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade100)),
              child: Column(children: [
                _menuTile(Icons.history, '浏览记录', () {}),
                _divider(),
                _menuTile(Icons.support_outlined, '客服中心', () {}),
                _divider(),
                _menuTile(Icons.settings_outlined, '设置', () {}),
                _divider(),
                _menuTile(Icons.info_outline, '关于', () {}),
              ]),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ]),
    );
  }

  Widget _orderItem(IconData icon, String label, VoidCallback onTap, {int badge = 0}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Stack(clipBehavior: Clip.none, children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 24, color: theme.colorScheme.primary.withValues(alpha: 0.7))),
          if (badge > 0) Positioned(right: -4, top: -4,
            child: Container(padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))))),
        ]),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: Colors.grey.shade600)),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 64, endIndent: 16, color: Colors.grey.shade100);
}
