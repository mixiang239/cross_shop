# CrossShop

跨端电商 App，基于 Flutter 构建，支持 Android / iOS / Web。

## 功能

- **首页** — 搜索栏、自动轮播 Banner、分类导航、商品瀑布流推荐
- **商品列表** — 分类筛选、平滑动画切换
- **商品详情** — Hero 过渡动画、图片画廊、规格参数、加入购物车
- **购物车** — 数量增减、滑动删除、结算反馈
- **个人中心** — 渐变头部、订单入口、菜单导航
- **暗色模式** — 自适应系统主题

## 技术栈

| 类别 | 方案 |
|------|------|
| 框架 | Flutter 3.x |
| 状态管理 | Provider |
| 路由 | go_router (ShellRoute) |
| 动画 | 内置 AnimationController、Hero、交错动画、Dismissible |
| 主题 | Material 3 + 自定义 ColorScheme |

## 项目结构

```
lib/
├── app.dart                  # 路由配置 & 多 Provider
├── main.dart                 # 入口
├── models/                   # 数据模型
│   ├── product.dart
│   └── cart_item.dart
├── providers/                # 状态管理
│   ├── product_provider.dart
│   └── cart_provider.dart
├── screens/
│   ├── home/                 # 首页 + 子组件
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── banner_carousel.dart
│   │       ├── category_grid.dart
│   │       └── product_card.dart
│   ├── product_list/         # 商品列表
│   ├── product_detail/       # 商品详情
│   ├── cart/                 # 购物车
│   └── profile/              # 个人中心
├── services/                 # 模拟数据
│   └── mock_data_service.dart
├── theme/                    # 主题
│   └── app_theme.dart
└── widgets/                  # 通用组件
    └── bottom_nav.dart
```

## 运行

```bash
# 安装依赖
flutter pub get

# 开发运行
flutter run

# 构建 Android APK
flutter build apk --release

# 构建 iOS
flutter build ios
```

## 截图

> 运行后截图放此区域

## License

MIT
