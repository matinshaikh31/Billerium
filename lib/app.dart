import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/navigation/router.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/categories/data/repositories/firebase_category_repository.dart';
import 'features/categories/presentation/cubit/category_cubit.dart';
import 'features/products/data/repositories/firebase_product_repository.dart';
import 'features/products/presentation/cubit/product_cubit.dart';
import 'features/billing/data/repositories/firebase_bill_repository.dart';
import 'features/billing/presentation/cubit/billing_cubit.dart';

class BillingApp extends StatelessWidget {
  const BillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => FirebaseAuthRepository()),
        RepositoryProvider(create: (context) => FirebaseCategoryRepository()),
        RepositoryProvider(create: (context) => FirebaseProductRepository()),
        RepositoryProvider(create: (context) => FirebaseBillRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthCubit(context.read<FirebaseAuthRepository>())
                  ..checkAuthStatus(),
          ),
          BlocProvider(
            create: (context) =>
                CategoryCubit(context.read<FirebaseCategoryRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                ProductCubit(context.read<FirebaseProductRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                BillingCubit(context.read<FirebaseBillRepository>()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final authCubit = context.read<AuthCubit>();
            final router = AppRouter.router(authCubit);

            return MaterialApp.router(
              title: 'BillManager - Inventory & POS',
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF2563EB),
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  centerTitle: false,
                  elevation: 0,
                ),
                cardTheme: CardThemeData(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
