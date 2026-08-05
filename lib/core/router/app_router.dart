import 'package:auto_route/auto_route.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // തുടക്കത്തിൽ കാണിക്കേണ്ട സ്ക്രീൻ (Initial Route)
        AutoRoute(path: '/', page: SplashRoute.page, initial: true),
        // ലോഗിൻ സ്ക്രീൻ
        AutoRoute(path: '/login', page: LoginRoute.page),
        // ഡാഷ്ബോർഡ് സ്ക്രീൻ
        AutoRoute(path: '/dashboard', page: DashboardRoute.page),
        // Customer List സ്ക്രീൻ
        AutoRoute(path: '/customers', page: CustomerListRoute.page),
      ];
}
