import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';
import 'providers/search_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/product_list/product_list_screen.dart';
import 'screens/product_detail/product_detail_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/orders/order_list_screen.dart';
import 'screens/orders/order_detail_screen.dart';
import 'screens/address/address_screen.dart';
import 'screens/address/address_edit_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/notifications/notification_screen.dart';
import 'screens/coupon/coupon_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppBottomNav(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/products', builder: (_, __) => const ProductListScreen()),
        GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) =>
          ProductDetailScreen(productId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/checkout',
      builder: (_, __) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (_, __) => const OrderListScreen(),
    ),
    GoRoute(
      path: '/order/:id',
      builder: (_, state) =>
          OrderDetailScreen(orderId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/address',
      builder: (_, __) => const AddressScreen(),
    ),
    GoRoute(
      path: '/address/edit',
      builder: (_, state) {
        final id = state.uri.queryParameters['id'];
        return AddressEditScreen(addressId: id);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (_, __) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/coupons',
      builder: (_, __) => const CouponScreen(),
    ),
  ],
);

class CrossShopApp extends StatelessWidget {
  const CrossShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp.router(
        title: 'CrossShop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
