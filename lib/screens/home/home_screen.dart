import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward().then((_) {
      if (mounted) setState(() => _showContent = true);
    });
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
            // Animated search bar
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              title: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    _SearchRouteBuilder(
                      child: _SearchPage(
                        onSearch: (q) {
                          provider.search(q);
                        },
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(Icons.search_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4)),
                      const SizedBox(width: 8),
                      Text(
                        '搜索商品',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
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
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: count > 0
                            ? Badge(
                                key: ValueKey('badge_$count'),
                                label: Text('$count',
                                    style: const TextStyle(fontSize: 10)),
                                child: const Icon(
                                    Icons.shopping_cart_outlined),
                              )
                            : const Icon(Icons.shopping_cart_outlined,
                                key: ValueKey('cart_empty')),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),

            // Banner - fade in from top
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    BannerCarousel(imageUrls: provider.banners),
                  ],
                ),
              ),
            ),

            // Category - staggered
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  final delay =
                      (_fadeAnimation.value - 0.15).clamp(0.0, 1.0);
                  return Opacity(
                    opacity: delay,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - delay)),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: CategoryGrid(
                    categories: provider.categories,
                    selected: provider.selectedCategory,
                    onTap: (cat) => provider.selectCategory(cat),
                  ),
                ),
              ),
            ),

            // Section title
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  final delay =
                      (_fadeAnimation.value - 0.25).clamp(0.0, 1.0);
                  return Opacity(opacity: delay, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: AppTheme.gradientBox.gradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.local_fire_department,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.selectedCategory == '全部'
                            ? '热门推荐'
                            : provider.selectedCategory,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Product grid - staggered item animation
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (!_showContent) return const SizedBox.shrink();
                    final delay = (index * 60).clamp(0, 500);
                    return AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        final itemDelay =
                            (_fadeAnimation.value - (delay / 600))
                                .clamp(0.0, 1.0);
                        if (itemDelay == 0) return const SizedBox.shrink();
                        return Opacity(
                          opacity: itemDelay,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - itemDelay)),
                            child: child,
                          ),
                        );
                      },
                      child: ProductCard(
                        product: provider.products[index],
                        index: index,
                      ),
                    );
                  },
                  childCount: provider.products.length,
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      },
    );
  }
}

// Custom search page with slide-up transition
class _SearchRouteBuilder extends PageRouteBuilder<void> {
  _SearchRouteBuilder({required Widget child})
      : super(
          pageBuilder: (_, __, ___) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

class _SearchPage extends StatefulWidget {
  final ValueChanged<String> onSearch;
  const _SearchPage({required this.onSearch});

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final AnimationController _anim;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_anim);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(21),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: '搜索商品名称、分类...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (q) {
              if (q.trim().isNotEmpty) {
                widget.onSearch(q);
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
      body: _controller.text.isEmpty
          ? Center(
              child: AnimatedBuilder(
                animation: _shimmerAnim,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.3 + (_shimmerAnim.value * 0.3),
                    child: child,
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_rounded,
                        size: 64,
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    Text(
                      '输入关键词开始搜索',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.35),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
