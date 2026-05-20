import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();
    final addresses = user.sortedAddresses;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('收货地址')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/address/edit').then((_) {}),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: addresses.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.location_on_outlined, size: 64, color: Colors.grey.shade200),
        const SizedBox(height: 12),
        Text('暂无地址', style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: () => context.push('/address/edit'), child: const Text('添加新地址')),
      ]))
          : ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final addr = addresses[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: addr.isDefault ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.grey.shade100)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(addr.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(width: 12),
                Text(addr.phone, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                if (addr.isDefault) ...[const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(4)),
                    child: Text('默认', style: TextStyle(fontSize: 10, color: theme.colorScheme.primary)))],
              ]),
              const SizedBox(height: 6),
              Text(addr.fullAddress, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => context.push('/address/edit?id=${addr.id}'), child: const Text('编辑', style: TextStyle(fontSize: 13))),
                const SizedBox(width: 8),
                TextButton(onPressed: () => user.deleteAddress(addr.id),
                  child: Text('删除', style: TextStyle(color: Colors.red.shade400, fontSize: 13))),
              ]),
            ]),
          );
        },
      ),
    );
  }
}
