import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import 'package:go_router/go_router.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  bool _addedToCart = false;
  Timer? _addedTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _addedTimer?.cancel();
    super.dispose();
  }

  void _handleAddToCart(Product product) {
    context.read<CartProvider>().addItem(product);
    setState(() => _addedToCart = true);
    _addedTimer?.cancel();
    _addedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _addedToCart = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已添加到购物车'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(label: '去看看', onPressed: () => context.push('/cart')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product =
        context.read<ProductProvider>().getProductById(widget.productId);
    final theme = Theme.of(context);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('商品不存在')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          // Image gallery with hero
          SliverToBoxAdapter(
            child: Hero(
              tag: 'product_${product.id}',
              child: _ImageGallery(
                images:
                    product.images.isNotEmpty ? product.images : [product.imageUrl],
              ),
            ),
          ),

          // Content - staggered reveal
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _fadeAnim,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - _fadeAnim.value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    if (product.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: product.tags
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primaryContainer
                                            .withValues(alpha: 0.7),
                                        theme.colorScheme.secondaryContainer
                                            .withValues(alpha: 0.4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 14),

                    // Price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '¥${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.price < 100)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('包邮',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.red.shade500)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Rating
                    if (product.reviewCount > 0)
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < product.rating.round()
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 20,
                              color: Colors.amber.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${product.rating} (${product.reviewCount}条评价)',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Description
                    const Text('商品详情',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text('规格参数',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _SpecRow(label: '品牌', value: 'CrossShop'),
                    _SpecRow(label: '分类', value: product.category),
                    _SpecRow(label: '商品编号', value: product.id),

                    SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom add to cart
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite_border_rounded,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _handleAddToCart(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _addedToCart
                          ? Colors.green.shade600
                          : theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _addedToCart
                          ? const Row(
                              key: ValueKey('added'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded, size: 20),
                                SizedBox(width: 6),
                                Text('已添加'),
                              ],
                            )
                          : const Row(
                              key: ValueKey('add'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 20),
                                SizedBox(width: 6),
                                Text('加入购物车'),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageGallery extends StatefulWidget {
  final List<String> images;
  const _ImageGallery({required this.images});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _idx = 0;
  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 360,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _idx = i),
            itemCount: widget.images.length,
            itemBuilder: (_, i) => Image.network(
              widget.images[i],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                      theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              final isActive = _idx == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isActive
                      ? theme.colorScheme.primary
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ),
          Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
