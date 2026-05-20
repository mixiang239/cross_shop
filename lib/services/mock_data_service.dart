import '../models/product.dart';
import '../models/order.dart';
import '../models/address.dart';
import '../models/review.dart';
import '../models/coupon.dart';
import '../models/notification_item.dart';

class MockDataService {
  // ── Categories ──
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

  // ── Banners ──
  static const List<String> banners = [
    'https://picsum.photos/800/300?random=1',
    'https://picsum.photos/800/300?random=2',
    'https://picsum.photos/800/300?random=3',
    'https://picsum.photos/800/300?random=4',
  ];

  // ── Hot Searches ──
  static const List<String> hotSearches = [
    '蓝牙耳机', '笔记本电脑', '扫地机器人', 'T恤男', '精华液',
    '坚果礼盒', '跑鞋', '机械键盘', '无线充电', '面包机',
  ];

  static List<String> getSearchSuggestions(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    final all = [
      ...products.map((p) => p.name),
      ...categories.map((c) => c.name),
      ...hotSearches,
    ];
    return all.where((s) => s.toLowerCase().contains(q)).take(6).toList();
  }

  // ── Products with SKUs ──
  static const List<Product> products = [
    Product(
      id: '1', name: '极简无线蓝牙耳机',
      description: '高品质降噪蓝牙耳机，40小时超长续航，佩戴舒适。支持AAC/SBC高清音频解码，低延迟游戏模式，IPX5防水。',
      price: 299.0, imageUrl: 'https://picsum.photos/400/400?random=10',
      category: '手机数码', rating: 4.8, reviewCount: 2341,
      images: ['https://picsum.photos/400/400?random=10','https://picsum.photos/400/400?random=11','https://picsum.photos/400/400?random=12'],
      tags: ['爆款', '降噪', '长续航'],
      skus: [ProductSku(label:'颜色',value:'珍珠白'),ProductSku(label:'颜色',value:'星空黑'),ProductSku(label:'颜色',value:'雾霾蓝')],
      specLabels: ['颜色'],
    ),
    Product(
      id: '2', name: '轻薄便携笔记本电脑',
      description: '14英寸2K高清屏，第12代酷睿处理器，16GB内存，512GB固态硬盘。全金属机身仅重1.2kg。',
      price: 4999.0, imageUrl: 'https://picsum.photos/400/400?random=20',
      category: '电脑办公', rating: 4.6, reviewCount: 876,
      images: ['https://picsum.photos/400/400?random=20','https://picsum.photos/400/400?random=21'],
      tags: ['新品', '轻薄本'],
      skus: [ProductSku(label:'配置',value:'i5/16G/512G'),ProductSku(label:'配置',value:'i7/16G/1T',priceDelta:1000)],
      specLabels: ['配置'],
    ),
    Product(
      id: '3', name: '智能扫地机器人',
      description: 'LDS激光导航，4000Pa大吸力，扫拖一体。支持APP远程控制，自动回充，5200mAh大电池。',
      price: 1599.0, imageUrl: 'https://picsum.photos/400/400?random=30',
      category: '家用电器', rating: 4.5, reviewCount: 3421,
      images: ['https://picsum.photos/400/400?random=30','https://picsum.photos/400/400?random=31'],
      tags: ['热卖', '智能家居'],
    ),
    Product(
      id: '4', name: '简约纯棉T恤 男女同款',
      description: '100%新疆长绒棉，亲肤透气，不起球不缩水。多色可选，四季百搭基础款。',
      price: 79.0, imageUrl: 'https://picsum.photos/400/400?random=40',
      category: '服饰鞋包', rating: 4.3, reviewCount: 5643,
      images: ['https://picsum.photos/400/400?random=40','https://picsum.photos/400/400?random=41'],
      tags: ['基础款', '纯棉'],
      skus: [ProductSku(label:'尺码',value:'M'),ProductSku(label:'尺码',value:'L'),ProductSku(label:'尺码',value:'XL'),ProductSku(label:'尺码',value:'XXL')],
      specLabels: ['尺码'],
    ),
    Product(
      id: '5', name: '保湿修复精华液',
      description: '含玻尿酸和烟酰胺，深层补水，修复肌肤屏障。适合所有肤质，敏感肌可用。',
      price: 189.0, imageUrl: 'https://picsum.photos/400/400?random=50',
      category: '美妆护肤', rating: 4.7, reviewCount: 1890,
      images: ['https://picsum.photos/400/400?random=50','https://picsum.photos/400/400?random=51'],
      tags: ['护肤', '补水'],
    ),
    Product(
      id: '6', name: '有机坚果大礼包',
      description: '精选6种进口坚果，每日坚果搭配，独立小包装。无添加，健康零食首选。',
      price: 128.0, imageUrl: 'https://picsum.photos/400/400?random=60',
      category: '食品生鲜', rating: 4.4, reviewCount: 4321,
      images: ['https://picsum.photos/400/400?random=60','https://picsum.photos/400/400?random=61'],
      tags: ['零食', '健康'],
    ),
    Product(
      id: '7', name: '人类简史：从动物到上帝',
      description: '尤瓦尔·赫拉利代表作，全球畅销2500万册。重新审视人类历史，颠覆你的认知。',
      price: 49.0, imageUrl: 'https://picsum.photos/400/400?random=70',
      category: '图书文具', rating: 4.9, reviewCount: 12054,
      images: ['https://picsum.photos/400/400?random=70','https://picsum.photos/400/400?random=71'],
      tags: ['畅销书', '历史'],
    ),
    Product(
      id: '8', name: '专业跑步鞋 减震回弹',
      description: '全掌碳板科技，轻量透气鞋面，缓震回弹中底。适合日常训练和马拉松比赛。',
      price: 599.0, imageUrl: 'https://picsum.photos/400/400?random=80',
      category: '运动户外', rating: 4.6, reviewCount: 2876,
      images: ['https://picsum.photos/400/400?random=80','https://picsum.photos/400/400?random=81'],
      tags: ['运动', '跑鞋'],
      skus: [ProductSku(label:'尺码',value:'39'),ProductSku(label:'尺码',value:'40'),ProductSku(label:'尺码',value:'41'),ProductSku(label:'尺码',value:'42'),ProductSku(label:'尺码',value:'43')],
      specLabels: ['尺码'],
    ),
    Product(
      id: '9', name: '无线充电板 15W快充',
      description: '兼容iPhone和安卓手机，15W快速无线充电。超薄设计，LED指示灯，异物检测保护。',
      price: 69.0, imageUrl: 'https://picsum.photos/400/400?random=90',
      category: '手机数码', rating: 4.2, reviewCount: 1567,
      images: ['https://picsum.photos/400/400?random=90','https://picsum.photos/400/400?random=91'],
      tags: ['配件', '快充'],
    ),
    Product(
      id: '10', name: '机械键盘 青轴 87键',
      description: 'Cherry青轴，RGB背光，PBT键帽。全键无冲，可编程宏定义，电竞办公两用。',
      price: 349.0, imageUrl: 'https://picsum.photos/400/400?random=100',
      category: '电脑办公', rating: 4.5, reviewCount: 3210,
      images: ['https://picsum.photos/400/400?random=100','https://picsum.photos/400/400?random=101'],
      tags: ['外设', '电竞'],
      skus: [ProductSku(label:'轴体',value:'青轴'),ProductSku(label:'轴体',value:'红轴',priceDelta:20),ProductSku(label:'轴体',value:'茶轴')],
      specLabels: ['轴体'],
    ),
    Product(
      id: '11', name: '智能面包机 全自动',
      description: '19大菜单，自动投果料，3种烧色可选，13小时预约。'
           '不锈钢外壳，易清洁。',
      price: 399.0, imageUrl: 'https://picsum.photos/400/400?random=110',
      category: '家用电器', rating: 4.3, reviewCount: 892,
      images: ['https://picsum.photos/400/400?random=110','https://picsum.photos/400/400?random=111'],
      tags: ['厨房', '智能'],
    ),
    Product(
      id: '12', name: '休闲双肩包 防泼水',
      description: '大容量多隔层，加厚肩带，防泼水面料。可放15.6寸笔记本。',
      price: 159.0, imageUrl: 'https://picsum.photos/400/400?random=120',
      category: '服饰鞋包', rating: 4.4, reviewCount: 2103,
      images: ['https://picsum.photos/400/400?random=120','https://picsum.photos/400/400?random=121'],
      tags: ['双肩包', '防泼水'],
      skus: [ProductSku(label:'颜色',value:'黑色'),ProductSku(label:'颜色',value:'灰色'),ProductSku(label:'颜色',value:'蓝色')],
      specLabels: ['颜色'],
    ),
  ];

  // ── Addresses ──
  static const List<Address> addresses = [
    Address(id:'a1',name:'张三',phone:'13800138000',province:'北京市',city:'北京市',district:'朝阳区',detail:'望京SOHO T1 1205',isDefault:true),
    Address(id:'a2',name:'张三',phone:'13800138000',province:'上海市',city:'上海市',district:'浦东新区',detail:'张江高科技园区B座301'),
    Address(id:'a3',name:'李四',phone:'13900139000',province:'广东省',city:'深圳市',district:'南山区',detail:'科技园南路8号',isDefault:false),
  ];

  // ── Reviews ──
  static final List<Review> reviews = [
    Review(id:'r1',productId:'1',userName:'数码控',avatarUrl:'',rating:5,content:'音质很棒，降噪效果出乎意料的好，续航也很给力，推荐购买！',sku:'颜色:珍珠白',createdAt:_dt(-3),likeCount:128),
    Review(id:'r2',productId:'1',userName:'小明同学',avatarUrl:'',rating:4,content:'整体不错，佩戴舒服，就是低音稍微有点薄，其他都满意。',sku:'颜色:星空黑',createdAt:_dt(-7),likeCount:45),
    Review(id:'r3',productId:'1',userName:'耳机发烧友',avatarUrl:'',rating:5,content:'这个价位最好的TWS耳机，没有之一。延迟很低，打游戏完全没问题。',sku:'颜色:雾霾蓝',createdAt:_dt(-14),likeCount:256),
    Review(id:'r4',productId:'7',userName:'书虫阿强',avatarUrl:'',rating:5,content:'非常精彩的一本书，颠覆了对人类历史的认知，强烈推荐！',createdAt:_dt(-5),likeCount:89),
    Review(id:'r5',productId:'8',userName:'跑者无疆',avatarUrl:'',rating:4,content:'鞋底很弹，包裹性也不错。跑了50公里后感觉磨合得很好。',sku:'尺码:42',createdAt:_dt(-10),likeCount:67),
  ];

  // ── Orders ──
  static final List<Order> orders = [
    Order(
      id:'o1',
      items:[OrderItem(productId:'1',productName:'极简无线蓝牙耳机',imageUrl:'https://picsum.photos/200/200?random=10',price:299,quantity:1,sku:'颜色:珍珠白')],
      status:OrderStatus.shipped,totalPrice:299,discount:30,shippingFee:0,
      addressId:'a1',paymentMethod:'微信支付',createdAt:_dt(-2).subtract(const Duration(hours:3)),
      trackingNumber:'SF1234567890',
      statusTimeline:['下单成功','已付款','仓库拣货中','已发货'],
    ),
    Order(
      id:'o2',
      items:[
        OrderItem(productId:'3',productName:'智能扫地机器人',imageUrl:'https://picsum.photos/200/200?random=30',price:1599,quantity:1),
        OrderItem(productId:'6',productName:'有机坚果大礼包',imageUrl:'https://picsum.photos/200/200?random=60',price:128,quantity:2),
      ],
      status:OrderStatus.delivered,totalPrice:1855,discount:100,shippingFee:0,
      addressId:'a1',paymentMethod:'支付宝',createdAt:_dt(-10),
      deliveredAt:_dt(-7),
      trackingNumber:'YT9876543210',
      statusTimeline:['下单成功','已付款','仓库拣货中','已发货','运输中','已签收'],
    ),
    Order(
      id:'o3',
      items:[OrderItem(productId:'10',productName:'机械键盘 青轴 87键',imageUrl:'https://picsum.photos/200/200?random=100',price:349,quantity:1,sku:'轴体:红轴')],
      status:OrderStatus.pending,totalPrice:369,discount:0,shippingFee:10,
      addressId:'a2',paymentMethod:'微信支付',createdAt:DateTime.now().subtract(const Duration(minutes:30)),
      statusTimeline:['下单成功'],
    ),
  ];

  // ── Coupons ──
  static final List<Coupon> coupons = [
    Coupon(id:'c1',title:'满200减30',description:'全品类通用',discount:30,minSpend:200,validUntil:DateTime.now().add(const Duration(days:7))),
    Coupon(id:'c2',title:'满500减80',description:'数码品类专用',discount:80,minSpend:500,validUntil:DateTime.now().add(const Duration(days:3))),
    Coupon(id:'c3',title:'新用户专享券',description:'无门槛立减',discount:15,minSpend:0,validUntil:DateTime.now().add(const Duration(days:30))),
    Coupon(id:'c4',title:'满99减10',description:'食品生鲜专用',discount:10,minSpend:99,validUntil:DateTime.now().add(const Duration(days:5))),
    Coupon(id:'c5',title:'限时秒杀券',description:'满300减50',discount:50,minSpend:300,validUntil:DateTime.now().add(const Duration(hours:12))),
  ];

  // ── Notifications ──
  static final List<NotificationItem> notifications = [
    NotificationItem(id:'n1',title:'订单已发货',body:'您的订单o1已发货，快递单号SF1234567890',type:NotificationType.order,createdAt:_dt(-2)),
    NotificationItem(id:'n2',title:'促销活动',body:'618年中大促，全场低至5折！',type:NotificationType.promotion,createdAt:_dt(-1)),
    NotificationItem(id:'n3',title:'优惠券到账',body:'一张满200减30优惠券已发放到您的账户',type:NotificationType.system,createdAt:_dt(-0.5)),
    NotificationItem(id:'n4',title:'订单已签收',body:'您的订单o2已签收，记得评价哦',type:NotificationType.order,createdAt:_dt(-7)),
    NotificationItem(id:'n5',title:'会员福利',body:'本月会员专属秒杀将于今晚8点开启',type:NotificationType.promotion,createdAt:_dt(-0.2)),
  ];

  // ── Flash sale data ──
  static final DateTime flashSaleEnd = DateTime.now().add(const Duration(hours:2, minutes:35, seconds:18));

  // ── Helpers ──
  static DateTime _dt(double daysAgo) => DateTime.now().subtract(Duration(milliseconds: (daysAgo * 86400000).round()));

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
    try { return products.firstWhere((p) => p.id == id); }
    catch (_) { return null; }
  }

  static List<Review> getReviewsForProduct(String productId) {
    return reviews.where((r) => r.productId == productId).toList();
  }

  /// "Guess you like" — shuffle for variety
  static List<Product> getRecommendations(int count) {
    final list = List<Product>.from(products);
    list.shuffle();
    return list.take(count).toList();
  }

  static List<Product> getFlashSaleProducts(int count) {
    return products.take(count).toList();
  }
}
