import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_item.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifs = context.watch<NotificationProvider>().items;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('消息中心'),
        actions: [
          TextButton(onPressed: () => context.read<NotificationProvider>().clearAll(),
            child: const Text('清空', style: TextStyle(fontSize: 13))),
        ],
      ),
      body: notifs.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade200),
        const SizedBox(height: 12),
        Text('暂无消息', style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
      ]))
          : ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: notifs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final n = notifs[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: n.read ? theme.colorScheme.surface : theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _iconBg(n.type, theme), borderRadius: BorderRadius.circular(10)),
                child: Icon(_icon(n.type), size: 20, color: _iconColor(n.type, theme))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  if (!n.read) Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                  if (!n.read) const SizedBox(width: 6),
                  Expanded(child: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                  Text(_timeAgo(n.createdAt), style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                ]),
                const SizedBox(height: 4),
                Text(n.body, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ])),
            ]),
          );
        },
      ),
    );
  }

  IconData _icon(NotificationType t) => switch(t) {
    NotificationType.order => Icons.receipt_long_rounded, NotificationType.promotion => Icons.campaign_rounded,
    NotificationType.system => Icons.info_outline_rounded
  };
  Color _iconColor(NotificationType t, ThemeData theme) => switch(t) {
    NotificationType.order => theme.colorScheme.primary, NotificationType.promotion => Colors.orange,
    NotificationType.system => Colors.blue.shade600
  };
  Color _iconBg(NotificationType t, ThemeData theme) => switch(t) {
    NotificationType.order => theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
    NotificationType.promotion => Colors.orange.shade50,
    NotificationType.system => Colors.blue.shade50
  };
  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}
