import 'package:billing_software/core/routes/app_router.dart';
import 'package:billing_software/core/theme/app_theme.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/features/analytics/data/firebase_analytics_repo.dart';
import 'package:billing_software/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:billing_software/features/auth/data/auth_firebaserepo.dart';
import 'package:billing_software/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:billing_software/features/billing/data/firebase_bill_repository.dart';
import 'package:billing_software/features/billing/presentation/cubit/bill_cubit.dart';
import 'package:billing_software/features/billing/presentation/cubit/create_bill_cubit.dart';
import 'package:billing_software/features/categories/data/repositories/firebase_category_repository.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_form_cubit.dart';

import 'package:billing_software/features/products/data/firebase_product_repository.dart';
import 'package:billing_software/features/products/presentation/cubit/product_cubit.dart';
import 'package:billing_software/features/products/presentation/cubit/product_form_cubit.dart';
import 'package:billing_software/features/transactions/presentation/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BillingApp extends StatelessWidget {
  const BillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authRepo: AuthFirebaseRepo())..checkAuth(),
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previous, current) =>
            previous.isAuthenticated != current.isAuthenticated,
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => CategoryCubit(
                  categoryRepository: FirebaseCategoryRepository(),
                )..fetchCategories(),
              ),
              BlocProvider(
                create: (context) => CategoryFormCubit(
                  categoryRepository: FirebaseCategoryRepository(),
                ),
              ),
              BlocProvider(
                create: (context) => ProductCubit(
                  // productRepository: FirebaseProductRepository(),
                ),
              ),
              BlocProvider(
                create: (context) => ProductFormCubit(
                  productRepository: FirebaseProductRepository(),
                ),
              ),
              BlocProvider(
                create: (context) => CreateBillCubit(
                  billRepository: FirebaseBillRepository(),
                  productRepository: FirebaseProductRepository(),
                ),
              ),
              BlocProvider(create: (context) => BillCubit()),
              BlocProvider(create: (context) => TransactionCubit()),
              BlocProvider(
                create: (context) => AnalyticsCubit(
                  analyticsRepo: FirebaseAnalyticsRepository(),
                  categoryRepo: FirebaseCategoryRepository(),
                  productRepo: FirebaseProductRepository(),
                ),
              ),
            ],
            child: ResponsiveWid(
              mobile: MaterialApp.router(
                title: 'Billerium',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                routerConfig: appRoute,
              ),
              desktop: MaterialApp.router(
                title: 'Billerium',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                routerConfig: appRoute,
              ),
            ),
          );
        },
      ),
    );
  }
}
