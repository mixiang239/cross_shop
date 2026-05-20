# CrossShop

跨端电商 App，基于 Flutter 构建，支持 Android / iOS / Web / HarmonyOS。

## 功能

### 首页
- 搜索栏（热搜标签、搜索历史、关键词建议）
- 自动轮播 Banner（渐变遮罩、视差缩放）
- 分类导航（动画选中态）
- 限时秒杀（实时倒计时、横向滑动）
- 热门推荐 / 猜你喜欢（交错入场动画）

### 商品
- 商品列表 — 分类筛选 Chip、动画切换
- 商品详情 — Hero 过渡动画、图片画廊、SKU 规格选择、数量步进器
- 用户评价 — 星级评分、SKU 标签、点赞
- 常见问题 — Q&A 模块

### 购物 & 订单
- 购物车 — 数量增减、滑动删除、结算按钮
- 结账流程 — 收货地址、支付方式、优惠券、金额汇总、下单成功动画
- 订单列表 — Tab 筛选（全部/待付款/待发货/已完成/已取消）
- 订单详情 — 渐变状态卡、物流时间线、商品清单、价格明细

### 用户
- 个人中心 — 渐变头部、订单统计入口
- 登录模拟 — 一键登录
- 收货地址 — 增删改、默认地址
- 收藏夹 — 心形切换
- 消息中心 — 未读红点、类型图标、时间格式化
- 优惠券 — 领取动画、渐变卡片

### 通用
- 暗色模式 — 自适应系统主题
- 交错动画 — 首页内容分层入场
- 页面过渡 — 搜索页上滑淡入

## 技术栈

| 类别 | 方案 |
|------|------|
| 框架 | Flutter 3.x |
| 状态管理 | Provider（6 个 Provider） |
| 路由 | go_router（ShellRoute + 子路由） |
| 动画 | AnimationController、Hero、交错动画、Dismissible |
| 主题 | Material 3 + 自定义 ColorScheme + 渐变 |

## 项目结构

```
lib/
├── app.dart                      # 路由 & Provider 注册
├── main.dart                     # 入口
├── models/                       # 数据模型
│   ├── product.dart              # 商品 + SKU
│   ├── cart_item.dart
│   ├── order.dart                # 订单 + 状态枚举
│   ├── address.dart
│   ├── review.dart
│   ├── coupon.dart
│   └── notification_item.dart
├── providers/                    # 状态管理
│   ├── product_provider.dart
│   ├── cart_provider.dart
│   ├── order_provider.dart
│   ├── user_provider.dart
│   ├── search_provider.dart
│   └── notification_provider.dart
├── screens/
│   ├── home/                     # 首页
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── banner_carousel.dart
│   │       ├── category_grid.dart
│   │       └── product_card.dart
│   ├── product_list/             # 商品列表
│   ├── product_detail/            # 商品详情
│   ├── cart/                     # 购物车
│   ├── checkout/                 # 结账
│   ├── orders/                   # 订单列表 & 详情
│   ├── address/                  # 地址管理
│   ├── favorites/                # 收藏夹
│   ├── notifications/            # 消息中心
│   ├── coupon/                   # 优惠券
│   └── profile/                  # 个人中心
├── services/
│   └── mock_data_service.dart    # 模拟数据
├── theme/
│   └── app_theme.dart
└── widgets/
    └── bottom_nav.dart
```

## 运行

```bash
flutter pub get          # 安装依赖
flutter run              # 开发运行
flutter build apk --release  # 构建 Android
flutter build ios            # 构建 iOS
```

## License

MIT
