import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/orders/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/invoice_list_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/', page: SplashRoute.page, initial: true),
        AutoRoute(path: '/login', page: LoginRoute.page),
        AutoRoute(path: '/dashboard', page: DashboardRoute.page),
        AutoRoute(path: '/customers', page: CustomerListRoute.page),
        AutoRoute(path: '/products', page: ProductListRoute.page),
        AutoRoute(path: '/product-detail', page: ProductDetailRoute.page),
        AutoRoute(path: '/checkout', page: CheckoutRoute.page),
        AutoRoute(path: '/invoices', page: InvoiceListRoute.page),
      ];
}
