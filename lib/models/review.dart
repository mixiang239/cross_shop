class Review {
  final String id;
  final String productId;
  final String userName;
  final String avatarUrl;
  final double rating;
  final String content;
  final List<String> images;
  final String sku;
  final DateTime createdAt;
  final int likeCount;

  const Review({
    required this.id,
    required this.productId,
    required this.userName,
    required this.avatarUrl,
    required this.rating,
    required this.content,
    this.images = const [],
    this.sku = '',
    required this.createdAt,
    this.likeCount = 0,
  });
}
