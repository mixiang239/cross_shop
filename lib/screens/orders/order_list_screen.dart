import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this)..addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() => _activeTab = _tabCtrl.index);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  OrderStatus? _statusFromIndex(int i) {
    return switch (i) { 1 => OrderStatus.pending, 2 => OrderStatus.shipped, 3 => OrderStatus.delivered, 4 => OrderStatus.cancelled, _ => null };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orders = context.watch<OrderProvider>().filterByStatus(_statusFromIndex(_activeTab));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('我的订单'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: false,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey.shade500,
          tabs: const [
            Tab(text: '全部'), Tab(text: '待付款'), Tab(text: '待收货'),
            Tab(text: '已完成'), Tab(text: '已取消'),
          ],
        ),
      ),
      body: orders.isEmpty
          ? Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Text('暂无订单', style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
        ]),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _OrderCard(
            order: order,
            onTap: () => context.push('/order/${order.id}'),
            onCancel: () => context.read<OrderProvider>().cancelOrder(order.id),
            onConfirm: () => context.read<OrderProvider>().confirmReceived(order.id),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _OrderCard({required this.order, required this.onTap, required this.onCancel, required this.onConfirm});

  String _statusText(OrderStatus s) => switch (s) {
    OrderStatus.pending => '待付款', OrderStatus.processing => '处理中',
    OrderStatus.shipped => '待收货', OrderStatus.delivered => '已完成',
    OrderStatus.cancelled => '已取消'
  };

  Color _statusColor(OrderStatus s) => switch (s) {
    OrderStatus.pending => Colors.orange, OrderStatus.shipped => Colors.blue,
    OrderStatus.delivered => Colors.green, OrderStatus.cancelled => Colors.grey,
    _ => Colors.grey
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Text('订单号: ${order.id}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const Spacer(),
            Text(_statusText(order.status), style: TextStyle(color: _statusColor(order.status), fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
          const Divider(height: 20),
          // Items
          ...order.items.take(3).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(6),
                child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                if (item.sku != null) ...[
                  const SizedBox(height: 3),
                  Text(item.sku!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
                const SizedBox(height: 4),
                Row(children: [
                  Text('¥${item.price.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(width: 8),
                  Text('x${item.quantity}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ]),
              ])),
            ]),
          )),
          if (order.items.length > 3)
            Padding(padding: const EdgeInsets.only(top: 4),
              child: Text('共${order.itemCount}件商品', style: TextStyle(color: Colors.grey.shade400, fontSize: 12))),
          const Divider(height: 20),
          Row(children: [
            Text('合计 ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            Text('¥${order.payableAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
            const Spacer(),
            if (order.status == OrderStatus.pending)
              OutlinedButton(onPressed: onCancel, style: OutlinedButton.styleFrom(minimumSize: const Size(70, 32), padding: const EdgeInsets.symmetric(horizontal: 12)),
                child: const Text('取消订单', style: TextStyle(fontSize: 12))),
            if (order.status == OrderStatus.shipped) ...[
              OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(minimumSize: const Size(70, 32), padding: const EdgeInsets.symmetric(horizontal: 12)),
                child: const Text('查看物流', style: TextStyle(fontSize: 12))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: onConfirm, style: ElevatedButton.styleFrom(minimumSize: const Size(70, 32), padding: const EdgeInsets.symmetric(horizontal: 12)),
                child: const Text('确认收货', style: TextStyle(fontSize: 12))),
            ],
          ]),
        ]),
      ),
    );
  }
}
