import 'package:billing_software/core/routes/routes.dart';
import 'package:billing_software/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:billing_software/features/auth/presentation/pages/login_page.dart';
import 'package:billing_software/features/billing2/presentation/page/create_bill_page.dart';
import 'package:billing_software/features/categories/presentation/pages/categories_page.dart';
import 'package:billing_software/features/dashboard/presentation/pages/dashboard.dart';
import 'package:billing_software/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:billing_software/features/products3/presentation/page/prooduct_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRoute = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: Routes.dashboard,

  // Improved redirect logic
  redirect: (context, state) {
    final authCubit = context.read<AuthCubit>();
    final currentPath = state.matchedLocation;
    final isAuthenticated = authCubit.state.isAuthenticated;

    // If user is not authenticated and trying to access protected routes
    if (!isAuthenticated && currentPath != Routes.login) {
      return Routes.login;
    }

    // If user is authenticated and on login page, redirect to dashboard
    if (isAuthenticated && currentPath == Routes.login) {
      return Routes.dashboard;
    }

    // No redirect needed
    return null;
  },

  routes: [
    // Login route outside ShellRoute
    GoRoute(path: Routes.login, builder: (context, state) => const LoginPage()),

    // Protected dashboard + nested routes
    ShellRoute(
      builder: (context, state, child) {
        return Dashboard(child: child);
      },
      routes: [
        GoRoute(
          path: Routes.dashboard,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DashboardPage()),
        ),
        GoRoute(
          path: Routes.products,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProductsPage()),
        ),
        GoRoute(
          path: Routes.categories,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CategoriesPage()),
        ),
        GoRoute(
          path: Routes.createBill,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CreateBillPage()),
        ),
        GoRoute(
          path: Routes.bills,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DashboardPage()),
        ),
        GoRoute(
          path: Routes.transcations,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DashboardPage()),
        ),
      ],
    ),
  ],
);
