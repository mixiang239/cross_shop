import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../home/widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(title: const Text('全部商品')),
          body: Column(
            children: [
              // Category chips
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  itemCount: provider.categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final title = index == 0
                        ? '全部'
                        : provider.categories[index - 1].name;
                    final isSel = title == provider.selectedCategory;
                    return GestureDetector(
                      onTap: () => provider.selectCategory(title),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel
                              ? theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.3)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSel ? FontWeight.w600 : FontWeight.normal,
                            color: isSel
                                ? theme.colorScheme.primary
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Product grid with fade-in
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: provider.products.length,
                    itemBuilder: (_, i) =>
                        ProductCard(product: provider.products[i], index: i),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
