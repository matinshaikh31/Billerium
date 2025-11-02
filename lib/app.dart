import 'package:billing_software/core/responsive/responsive_helper.dart';
import 'package:billing_software/core/routes/app_router.dart';
import 'package:billing_software/core/theme/app_theme.dart';
import 'package:billing_software/features/auth/data/auth_firebaserepo.dart';
import 'package:billing_software/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:billing_software/features/billing2/domain/repo/bill_repository.dart';
import 'package:billing_software/features/billing2/presentation/cubit/bill_cubit.dart';
import 'package:billing_software/features/billing2/presentation/cubit/create_bill_cubit.dart';
import 'package:billing_software/features/categories/data/repositories/firebase_category_repository.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_form_cubit.dart';

import 'package:billing_software/features/products3/data/firebase_product_repository.dart';
import 'package:billing_software/features/products3/presentation/cubit/product_cubit.dart';
import 'package:billing_software/features/products3/presentation/cubit/product_form_cubit.dart';
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
                ),
              ),
              BlocProvider(
                create: (context) => CategoryFormCubit(
                  categoryRepository: FirebaseCategoryRepository(),
                ),
              ),
              BlocProvider(
                create: (context) => ProductCubit(
                  productRepository: FirebaseProductRepository(),
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
              BlocProvider(
                create: (context) =>
                    BillCubit(billRepository: FirebaseBillRepository()),
              ),
            ],
            child: ResponsiveWidget(
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
