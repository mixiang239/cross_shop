class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> tags;
  final List<ProductSku> skus;
  final List<String> specLabels;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 0,
    this.reviewCount = 0,
    this.images = const [],
    this.tags = const [],
    this.skus = const [],
    this.specLabels = const [],
  });
}

class ProductSku {
  final String label;
  final String value;
  final double? priceDelta;

  const ProductSku({
    required this.label,
    required this.value,
    this.priceDelta,
  });
}

class Category {
  final String id;
  final String name;
  final String icon;

  const Category({required this.id, required this.name, required this.icon});
}
