import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/billing/presentation/pages/billing_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/products/presentation/pages/products_page.dart';

class AppRouter {
  static const String login = '/';
  static const String home = '/home';
  static const String dashboard = '/home';
  static const String products = '/products';
  static const String categories = '/categories';
  static const String billing = '/billing';
  static const String transactions = '/transactions';
  static const String stock = '/stock';
  static const String bills = '/bills';

  static GoRouter router(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: login,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final isAuthenticated = authCubit.state.isAuthenticated;
        final isLoggingIn = state.matchedLocation == login;

        // If not authenticated and not on login page, redirect to login
        if (!isAuthenticated && !isLoggingIn) {
          return login;
        }

        // If authenticated and on login page, redirect to home
        if (isAuthenticated && isLoggingIn) {
          return home;
        }

        return null;
      },
      routes: [
        GoRoute(path: login, builder: (context, state) => const LoginPage()),
        GoRoute(path: home, builder: (context, state) => const DashboardPage()),
        GoRoute(
          path: products,
          builder: (context, state) => const ProductsPage(),
        ),
        GoRoute(
          path: categories,
          builder: (context, state) => const CategoriesPage(),
        ),
        GoRoute(
          path: billing,
          builder: (context, state) => const BillingPage(),
        ),
      ],
    );
  }
}

// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
