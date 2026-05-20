import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/product.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_grid.dart';
import 'widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  bool _showContent = false;
  late List<Product> _flashSaleProducts;
  late List<Product> _recommendations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward().then((_) {
      if (mounted) setState(() => _showContent = true);
    });
    _flashSaleProducts = MockDataService.getFlashSaleProducts(6);
    _recommendations = MockDataService.getRecommendations(8);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return CustomScrollView(
          slivers: [
            // Search bar
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              title: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                ),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    _SearchRouteBuilder(child: const _SearchPage()),
                  ),
                  child: Row(children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search_rounded, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(width: 8),
                    Text('搜索商品', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 14)),
                  ]),
                ),
              ),
              actions: [
                Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    final count = cart.itemCount;
                    return IconButton(
                      onPressed: () => context.push('/cart'),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                        child: count > 0
                            ? Badge(key: ValueKey('badge_$count'), label: Text('$count', style: const TextStyle(fontSize: 10)),
                                child: const Icon(Icons.shopping_cart_outlined))
                            : const Icon(Icons.shopping_cart_outlined, key: ValueKey('cart_empty')),
                      ),
                    );
                  },
                ),
                Consumer<NotificationProvider>(
                  builder: (context, notif, _) {
                    final unread = notif.unreadCount;
                    return IconButton(
                      onPressed: () => context.push('/notifications'),
                      icon: unread > 0
                          ? Badge(label: Text('$unread', style: const TextStyle(fontSize: 10)),
                              child: const Icon(Icons.notifications_outlined))
                          : const Icon(Icons.notifications_outlined),
                    );
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),

            // Banner
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(offset: Offset(0, 20 * (1 - _fadeAnimation.value)), child: child),
                ),
                child: Column(children: [
                  const SizedBox(height: 6),
                  BannerCarousel(imageUrls: provider.banners),
                ]),
              ),
            ),

            // Category
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  final d = (_fadeAnimation.value - 0.15).clamp(0.0, 1.0);
                  return Opacity(opacity: d, child: Transform.translate(offset: Offset(0, 16 * (1 - d)), child: child));
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: CategoryGrid(categories: provider.categories, selected: provider.selectedCategory,
                    onTap: (cat) => provider.selectCategory(cat)),
                ),
              ),
            ),

            // ── Flash Sale ──
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  final d = (_fadeAnimation.value - 0.2).clamp(0.0, 1.0);
                  return Opacity(opacity: d, child: Transform.translate(offset: Offset(0, 20 * (1 - d)), child: child));
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: _FlashSaleSection(products: _flashSaleProducts),
                ),
              ),
            ),

            // ── Hot Products ──
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  final d = (_fadeAnimation.value - 0.25).clamp(0.0, 1.0);
                  return Opacity(opacity: d, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(gradient: AppTheme.gradientBox.gradient, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.local_fire_department, color: Colors.white, size: 16)),
                    const SizedBox(width: 8),
                    Text(provider.selectedCategory == '全部' ? '热门推荐' : provider.selectedCategory,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),

            // Product grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (!_showContent) return const SizedBox.shrink();
                    final delay = (index * 60).clamp(0, 500);
                    return AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        final itemDelay = (_fadeAnimation.value - (delay / 600)).clamp(0.0, 1.0);
                        if (itemDelay == 0) return const SizedBox.shrink();
                        return Opacity(opacity: itemDelay,
                          child: Transform.translate(offset: Offset(0, 30 * (1 - itemDelay)), child: child));
                      },
                      child: ProductCard(product: provider.products[index], index: index),
                    );
                  },
                  childCount: provider.products.length,
                ),
              ),
            ),

            // ── Guess You Like ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)]),
                      borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
                  const SizedBox(width: 8),
                  const Text('猜你喜欢', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(product: _recommendations[index], index: index),
                  childCount: _recommendations.length,
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        );
      },
    );
  }
}

// ── Flash Sale Section ──
class _FlashSaleSection extends StatefulWidget {
  final List<Product> products;
  const _FlashSaleSection({required this.products});

  @override
  State<_FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<_FlashSaleSection> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = MockDataService.flashSaleEnd.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _remaining = MockDataService.flashSaleEnd.difference(DateTime.now()));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_remaining.isNegative) return const SizedBox.shrink();
    final h = _remaining.inHours.remainder(24).toString().padLeft(2, '0');
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF3D00), Color(0xFFFF6D00)]),
              borderRadius: BorderRadius.circular(4)),
            child: const Text('限时秒杀', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
          const SizedBox(width: 10),
          Text('$h : $m : $s', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFFFF3D00))),
          const Spacer(),
          GestureDetector(onTap: () => context.push('/products'),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('更多', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
            ])),
        ]),
        const SizedBox(height: 12),
        // Products
        SizedBox(
          height: 155,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final p = widget.products[i];
              return GestureDetector(
                onTap: () => context.push('/product/${p.id}'),
                child: SizedBox(
                  width: 110,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: Image.network(p.imageUrl, width: 110, height: 110, fit: BoxFit.cover)),
                    const SizedBox(height: 6),
                    Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Row(children: [
                      Text('¥${p.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                      const SizedBox(width: 6),
                      Text('¥${(p.price * 1.4).toStringAsFixed(0)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade400, decoration: TextDecoration.lineThrough)),
                    ]),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ── Search Page ──
class _SearchRouteBuilder extends PageRouteBuilder<void> {
  _SearchRouteBuilder({required Widget child})
      : super(
    pageBuilder: (_, __, ___) => child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

class _SearchPage extends StatefulWidget {
  const _SearchPage();

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _ctrl.dispose(); _focus.dispose();
    super.dispose();
  }

  void _search(String q, SearchProvider searchProv, ProductProvider prodProv) {
    if (q.trim().isEmpty) return;
    searchProv.addToHistory(q);
    prodProv.search(q);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchProv = context.read<SearchProvider>();
    final prodProv = context.read<ProductProvider>();
    final suggestions = _query.isNotEmpty ? searchProv.suggestions : <String>[];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(21)),
          child: TextField(
            controller: _ctrl, focusNode: _focus, autofocus: true,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: '搜索商品名称、分类...', border: InputBorder.none,
              enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _ctrl.clear(); setState(() => _query = ''); })
                  : null,
            ),
            onChanged: (v) => setState(() => _query = v),
            onSubmitted: (q) => _search(q, searchProv, prodProv),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消'))],
      ),
      body: _query.isNotEmpty && suggestions.isNotEmpty
          ? ListView(
        padding: const EdgeInsets.all(14),
        children: suggestions.map((s) => ListTile(
          leading: const Icon(Icons.search, size: 20),
          title: RichText(text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            children: _highlight(s, _query),
          )),
          onTap: () => _search(s, searchProv, prodProv),
          dense: true,
        )).toList(),
      )
          : ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Hot searches
          if (_query.isEmpty) ...[
            const Text('🔥 热门搜索', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: searchProv.hotSearches.map((term) => GestureDetector(
                onTap: () => _search(term, searchProv, prodProv),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16)),
                  child: Text(term, style: const TextStyle(fontSize: 13)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],
          // Search history
          if (searchProv.history.isNotEmpty) ...[
            Row(children: [
              const Text('🕐 搜索历史', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => searchProv.clearHistory(),
                child: Icon(Icons.delete_outline, size: 18, color: Colors.grey.shade400),
              ),
            ]),
            const SizedBox(height: 8),
            ...searchProv.history.map((term) => ListTile(
              contentPadding: EdgeInsets.zero, dense: true,
              leading: Icon(Icons.history, size: 18, color: Colors.grey.shade400),
              title: Text(term, style: const TextStyle(fontSize: 14)),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                onPressed: () => searchProv.removeFromHistory(term),
              ),
              onTap: () => _search(term, searchProv, prodProv),
            )),
          ],
        ],
      ),
    );
  }

  List<TextSpan> _highlight(String text, String query) {
    final idx = text.toLowerCase().indexOf(query.toLowerCase());
    if (idx == -1) return [TextSpan(text: text)];
    return [
      TextSpan(text: text.substring(0, idx)),
      TextSpan(text: text.substring(idx, idx + query.length),
        style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.w600)),
      TextSpan(text: text.substring(idx + query.length)),
    ];
  }
}
