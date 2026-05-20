import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/mock_data_service.dart';
import 'package:go_router/go_router.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  bool _addedToCart = false;
  Timer? _addedTimer;
  String? _selectedSku;
  int _quantity = 1;
  final List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    // Track browse history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().addBrowseHistory(widget.productId);
    });
    _reviews.addAll(MockDataService.getReviewsForProduct(widget.productId));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _addedTimer?.cancel();
    super.dispose();
  }

  double _currentPrice(Product p) {
    if (_selectedSku == null) return p.price;
    final sku = p.skus.where((s) => s.value == _selectedSku).firstOrNull;
    return p.price + (sku?.priceDelta ?? 0);
  }

  void _handleAddToCart(Product product) {
    context.read<CartProvider>().addItem(product);
    setState(() { _addedToCart = true; });
    _addedTimer?.cancel();
    _addedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _addedToCart = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_selectedSku != null ? '已添加「${_selectedSku!}」到购物车' : '已添加到购物车'),
        duration: const Duration(seconds: 1), behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(label: '去看看', onPressed: () => context.push('/cart')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = context.read<ProductProvider>().getProductById(widget.productId);
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();

    if (product == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('商品不存在')));
    }

    final price = _currentPrice(product);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(user.isFavorite(product.id) ? Icons.favorite : Icons.favorite_border,
              color: user.isFavorite(product.id) ? Colors.red : null),
            onPressed: () => user.toggleFavorite(product.id),
          ),
        ]),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(slivers: [
        // Image gallery
        SliverToBoxAdapter(
          child: Hero(
            tag: 'product_${product.id}',
            child: _ImageGallery(images: product.images.isNotEmpty ? product.images : [product.imageUrl]),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: AnimatedBuilder(
            animation: _fadeAnim,
            builder: (context, child) => Opacity(
              opacity: _fadeAnim.value,
              child: Transform.translate(offset: Offset(0, 30 * (1 - _fadeAnim.value)), child: child),
            ),
            child: Container(
              decoration: BoxDecoration(color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),

                // Tags
                if (product.tags.isNotEmpty)
                  Wrap(spacing: 6, runSpacing: 6,
                    children: product.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                          theme.colorScheme.secondaryContainer.withValues(alpha: 0.4)]),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(tag, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: theme.colorScheme.primary)),
                    )).toList()),
                const SizedBox(height: 14),

                // Price
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('¥${price.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: theme.colorScheme.primary, height: 1)),
                  if (_selectedSku != null && _currentPrice(product) != product.price) ...[
                    const SizedBox(width: 8),
                    Text('¥${product.price.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade400, decoration: TextDecoration.lineThrough)),
                  ],
                  const SizedBox(width: 8),
                  if (product.price < 100) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                    child: Text('包邮', style: TextStyle(fontSize: 11, color: Colors.red.shade500))),
                ]),
                const SizedBox(height: 12),

                // Name
                Text(product.name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, height: 1.3)),
                const SizedBox(height: 10),

                // Rating
                if (product.reviewCount > 0)
                  GestureDetector(
                    onTap: () => _scrollToReviews(),
                    child: Row(children: [
                      ...List.generate(5, (i) => Icon(
                        i < product.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 20, color: Colors.amber.shade600)),
                      const SizedBox(width: 8),
                      Text('${product.rating} (${product.reviewCount}条评价)',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      const Spacer(),
                      Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
                    ]),
                  ),
                const SizedBox(height: 16),
                const Divider(),

                // ── SKU Selection ──
                if (product.skus.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...product.specLabels.map((label) {
                    final options = product.skus.where((s) => s.label == label).toList();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 8,
                          children: options.map((sku) => GestureDetector(
                            onTap: () => setState(() => _selectedSku = sku.value),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedSku == sku.value
                                    ? theme.colorScheme.primaryContainer
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedSku == sku.value
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Text(sku.value,
                                style: TextStyle(fontSize: 13,
                                  fontWeight: _selectedSku == sku.value ? FontWeight.w600 : FontWeight.normal,
                                  color: _selectedSku == sku.value ? theme.colorScheme.primary : Colors.grey.shade700)),
                            ),
                          )).toList()),
                      ]),
                    );
                  }),
                  const Divider(),
                ],

                // ── Quantity ──
                const SizedBox(height: 12),
                Row(children: [
                  const Text('数量', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _qtyBtn(Icons.remove, () { if (_quantity > 1) setState(() => _quantity--); }),
                      SizedBox(width: 36, child: Center(child: Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
                      _qtyBtn(Icons.add, () => setState(() => _quantity++)),
                    ]),
                  ),
                ]),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Description
                const Text('商品详情', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(product.description, style: TextStyle(fontSize: 14, height: 1.7, color: Colors.grey.shade600)),

                const SizedBox(height: 20),
                const Text('规格参数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _SpecRow(label: '品牌', value: 'CrossShop'),
                _SpecRow(label: '分类', value: product.category),
                _SpecRow(label: '商品编号', value: product.id),

                const SizedBox(height: 24),

                // ── Reviews Section ──
                Row(children: [
                  const Text('用户评价', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text('(${_reviews.length})', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text('查看全部', style: TextStyle(fontSize: 13))),
                ]),
                if (_reviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('暂无评价', style: TextStyle(color: Colors.grey.shade400)))),
                ..._reviews.take(3).map((r) => _ReviewTile(review: r)),

                // ── Q&A Placeholder ──
                const SizedBox(height: 20),
                Row(children: [
                  const Text('常见问题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text('我要提问', style: TextStyle(fontSize: 13))),
                ]),
                _qaTile('这个商品支持七天无理由退货吗？', '支持，签收后7天内可申请无理由退货。'),
                _qaTile('发货速度如何？', '一般情况下下单后24小时内发货。'),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
              ]),
            ),
          ),
        ),
      ]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: Colors.grey.shade100))),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SafeArea(
          child: Row(children: [
            GestureDetector(
              onTap: () => user.toggleFavorite(product.id),
              child: Container(
                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.all(10),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    user.isFavorite(product.id) ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(user.isFavorite(product.id)),
                    color: user.isFavorite(product.id) ? Colors.red : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedContainer(duration: const Duration(milliseconds: 300), height: 50,
                child: ElevatedButton(
                  onPressed: () => _handleAddToCart(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _addedToCart ? Colors.green.shade600 : theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: AnimatedSwitcher(duration: const Duration(milliseconds: 300),
                    child: _addedToCart
                        ? const Row(key: ValueKey('added'), mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.check_rounded, size: 20), SizedBox(width: 6), Text('已添加')])
                        : const Row(key: ValueKey('add'), mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.shopping_cart_outlined, size: 20), SizedBox(width: 6), Text('加入购物车')]),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return Material(color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10),
        child: Padding(padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 18, color: Colors.grey.shade600))));
  }

  void _scrollToReviews() {
    // Simple scroll-to-reviews - already visible in layout
  }
}

// ── Review Tile ──
class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 16, backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(review.userName[0], style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13))),
          const SizedBox(width: 8),
          Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          ...List.generate(5, (i) => Icon(i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 14, color: Colors.amber.shade600)),
        ]),
        if (review.sku.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(review.sku, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
        const SizedBox(height: 6),
        Text(review.content, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        Row(children: [
          Text(_timeAgo(review.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          const Spacer(),
          Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Text('${review.likeCount}', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        ]),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    return diff.inDays > 0 ? '${diff.inDays}天前' : '${diff.inHours}小时前';
  }
}

// ── QA ──
Widget _qaTile(String question, String answer) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Q', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFF6B35))),
          const SizedBox(width: 8),
          Expanded(child: Text(question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Text('A', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green)),
          const SizedBox(width: 8),
          Expanded(child: Text(answer, style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
        ]),
      ]),
    ),
  );
}

// ── Image Gallery ──
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
    return Column(children: [
      SizedBox(height: 360,
        child: PageView.builder(
          controller: _pageCtrl, onPageChanged: (i) => setState(() => _idx = i),
          itemCount: widget.images.length,
          itemBuilder: (_, i) => Image.network(widget.images[i], fit: BoxFit.cover, width: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                theme.colorScheme.secondaryContainer.withValues(alpha: 0.2)])),
              child: Icon(Icons.image_outlined, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.2))))),
      ),
      if (widget.images.length > 1) ...[
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (i) {
            final isActive = _idx == i;
            return AnimatedContainer(duration: const Duration(milliseconds: 250), curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3), width: isActive ? 20 : 6, height: 6,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(3),
                color: isActive ? theme.colorScheme.primary : Colors.grey.shade300));
          })),
      ],
    ]);
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ]));
  }
}
