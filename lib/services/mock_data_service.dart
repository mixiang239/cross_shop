import '../models/product.dart';

class MockDataService {
  static const List<Category> categories = [
    Category(id: '1', name: '手机数码', icon: '📱'),
    Category(id: '2', name: '电脑办公', icon: '💻'),
    Category(id: '3', name: '家用电器', icon: '🏠'),
    Category(id: '4', name: '服饰鞋包', icon: '👗'),
    Category(id: '5', name: '美妆护肤', icon: '💄'),
    Category(id: '6', name: '食品生鲜', icon: '🍎'),
    Category(id: '7', name: '图书文具', icon: '📚'),
    Category(id: '8', name: '运动户外', icon: '⚽'),
  ];

  static const List<String> banners = [
    'https://picsum.photos/800/300?random=1',
    'https://picsum.photos/800/300?random=2',
    'https://picsum.photos/800/300?random=3',
  ];

  static const List<Product> products = [
    Product(
      id: '1',
      name: '极简无线蓝牙耳机',
      description: '高品质降噪蓝牙耳机，40小时超长续航，佩戴舒适。支持AAC/SBC高清音频解码，低延迟游戏模式。',
      price: 299.0,
      imageUrl: 'https://picsum.photos/400/400?random=10',
      category: '手机数码',
      rating: 4.8,
      reviewCount: 2341,
      images: [
        'https://picsum.photos/400/400?random=10',
        'https://picsum.photos/400/400?random=11',
        'https://picsum.photos/400/400?random=12',
      ],
      tags: ['爆款', '降噪', '长续航'],
    ),
    Product(
      id: '2',
      name: '轻薄便携笔记本电脑',
      description: '14英寸2K高清屏，第12代酷睿处理器，16GB内存，512GB固态硬盘。全金属机身仅重1.2kg。',
      price: 4999.0,
      imageUrl: 'https://picsum.photos/400/400?random=20',
      category: '电脑办公',
      rating: 4.6,
      reviewCount: 876,
      images: [
        'https://picsum.photos/400/400?random=20',
        'https://picsum.photos/400/400?random=21',
      ],
      tags: ['新品', '轻薄本'],
    ),
    Product(
      id: '3',
      name: '智能扫地机器人',
      description: 'LDS激光导航，4000Pa大吸力，扫拖一体。支持APP远程控制，自动回充。',
      price: 1599.0,
      imageUrl: 'https://picsum.photos/400/400?random=30',
      category: '家用电器',
      rating: 4.5,
      reviewCount: 3421,
      images: [
        'https://picsum.photos/400/400?random=30',
        'https://picsum.photos/400/400?random=31',
      ],
      tags: ['热卖', '智能家居'],
    ),
    Product(
      id: '4',
      name: '简约纯棉T恤 男女同款',
      description: '100%新疆长绒棉，亲肤透气，不起球不缩水。多色可选，四季百搭基础款。',
      price: 79.0,
      imageUrl: 'https://picsum.photos/400/400?random=40',
      category: '服饰鞋包',
      rating: 4.3,
      reviewCount: 5643,
      images: [
        'https://picsum.photos/400/400?random=40',
        'https://picsum.photos/400/400?random=41',
      ],
      tags: ['基础款', '纯棉'],
    ),
    Product(
      id: '5',
      name: '保湿修复精华液',
      description: '含玻尿酸和烟酰胺，深层补水，修复肌肤屏障。适合所有肤质，敏感肌可用。',
      price: 189.0,
      imageUrl: 'https://picsum.photos/400/400?random=50',
      category: '美妆护肤',
      rating: 4.7,
      reviewCount: 1890,
      images: [
        'https://picsum.photos/400/400?random=50',
        'https://picsum.photos/400/400?random=51',
      ],
      tags: ['护肤', '补水'],
    ),
    Product(
      id: '6',
      name: '有机坚果大礼包',
      description: '精选6种进口坚果，每日坚果搭配，独立小包装。无添加，健康零食首选。',
      price: 128.0,
      imageUrl: 'https://picsum.photos/400/400?random=60',
      category: '食品生鲜',
      rating: 4.4,
      reviewCount: 4321,
      images: [
        'https://picsum.photos/400/400?random=60',
        'https://picsum.photos/400/400?random=61',
      ],
      tags: ['零食', '健康'],
    ),
    Product(
      id: '7',
      name: '人类简史：从动物到上帝',
      description: '尤瓦尔·赫拉利代表作，全球畅销2500万册。重新审视人类历史，颠覆你的认知。',
      price: 49.0,
      imageUrl: 'https://picsum.photos/400/400?random=70',
      category: '图书文具',
      rating: 4.9,
      reviewCount: 12054,
      images: [
        'https://picsum.photos/400/400?random=70',
        'https://picsum.photos/400/400?random=71',
      ],
      tags: ['畅销书', '历史'],
    ),
    Product(
      id: '8',
      name: '专业跑步鞋 减震回弹',
      description: '全掌碳板科技，轻量透气鞋面，缓震回弹中底。适合日常训练和马拉松比赛。',
      price: 599.0,
      imageUrl: 'https://picsum.photos/400/400?random=80',
      category: '运动户外',
      rating: 4.6,
      reviewCount: 2876,
      images: [
        'https://picsum.photos/400/400?random=80',
        'https://picsum.photos/400/400?random=81',
      ],
      tags: ['运动', '跑鞋'],
    ),
    Product(
      id: '9',
      name: '无线充电板 15W快充',
      description: '兼容iPhone和安卓手机，15W快速无线充电。超薄设计，LED指示灯，异物检测保护。',
      price: 69.0,
      imageUrl: 'https://picsum.photos/400/400?random=90',
      category: '手机数码',
      rating: 4.2,
      reviewCount: 1567,
      images: [
        'https://picsum.photos/400/400?random=90',
        'https://picsum.photos/400/400?random=91',
      ],
      tags: ['配件', '快充'],
    ),
    Product(
      id: '10',
      name: '机械键盘 青轴 87键',
      description: 'Cherry青轴，RGB背光，PBT键帽。全键无冲，可编程宏定义，电竞办公两用。',
      price: 349.0,
      imageUrl: 'https://picsum.photos/400/400?random=100',
      category: '电脑办公',
      rating: 4.5,
      reviewCount: 3210,
      images: [
        'https://picsum.photos/400/400?random=100',
        'https://picsum.photos/400/400?random=101',
      ],
      tags: ['外设', '电竞'],
    ),
  ];

  static List<Product> getProductsByCategory(String category) {
    if (category == '全部') return products;
    return products.where((p) => p.category == category).toList();
  }

  static List<Product> searchProducts(String query) {
    final q = query.toLowerCase();
    return products.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q)
    ).toList();
  }

  static Product? getProductById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
