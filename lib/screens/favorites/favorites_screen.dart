import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/product_provider.dart';
import '../home/widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final prov = context.read<ProductProvider>();
    final favorites = prov.products.where((p) => user.isFavorite(p.id)).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('我的收藏')),
      body: favorites.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade200),
        const SizedBox(height: 12),
        Text('暂无收藏', style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: () => Navigator.of(context).pushNamed('/products'), child: const Text('去逛逛')),
      ]))
          : GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: favorites.length,
        itemBuilder: (_, i) => ProductCard(product: favorites[i], index: i),
      ),
    );
  }
}
