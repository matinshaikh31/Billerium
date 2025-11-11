import 'package:billing_software/core/routes/routes.dart';
import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define your auth providers
    final providers = [EmailAuthProvider()];

    // Check if mobile/tablet
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      // Add colored background for mobile
      backgroundColor: isMobile ? AppColors.primary : AppColors.backgroundColor,
      body: Column(
        children: [
          // ---------------------------
          // Mobile Logo Section (Top)
          // ---------------------------
          if (isMobile)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.9),
                    AppColors.secondary,
                  ],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                bottom: 32,
                left: 24,
                right: 24,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 160,
                    child: Image.asset("logo.png", color: Colors.white),
                  ),
                  // const SizedBox(height: 16),
                  // Text(
                  //   'Welcome to Billerium',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),

          // ---------------------------
          // Login Form Section
          // ---------------------------
          Expanded(
            child: Container(
              decoration: isMobile
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    )
                  : BoxDecoration(color: AppColors.backgroundColor),
              child: SignInScreen(
                providers: providers,
                showAuthActionSwitch: false,

                // Side panel with your logo (desktop only)
                sideBuilder: (context, constraints) {
                  // Hide side panel on mobile
                  if (isMobile) return const SizedBox.shrink();

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.9),
                          AppColors.secondary,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("logo.png"),
                          // const SizedBox(height: 32),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 40),
                          //   child: Text(
                          //     'Welcome to Billerium',
                          //     textAlign: TextAlign.center,
                          //     style: TextStyle(
                          //       fontSize: 24,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                },

                // Header builder for customization
                // headerBuilder: (context, constraints, shrinkOffset) {
                //   final isMobile = constraints.maxWidth < 600;
                //
                //   return Padding(
                //     padding: EdgeInsets.only(
                //       left: 20,
                //       right: 20,
                //       top: isMobile ? 8 : 20,
                //     ),
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Text(
                //           'Welcome Back',
                //           style: TextStyle(
                //             fontSize: isMobile ? 22 : 28,
                //             fontWeight: FontWeight.bold,
                //             color: AppColors.slateGray,
                //           ),
                //         ),
                //         const SizedBox(height: 8),
                //         Text(
                //           'Sign in to continue to your dashboard',
                //           textAlign: TextAlign.center,
                //           style: TextStyle(
                //             fontSize: isMobile ? 13 : 14,
                //             color: AppColors.slateGray.withValues(alpha: 0.7),
                //           ),
                //         ),
                //       ],
                //     ),
                //   );
                // },

                // Footer builder for custom footer
                // footerBuilder: (context, action) {
                //   return Padding(
                //     padding: const EdgeInsets.only(top: 32, bottom: 16),
                //     child: Column(
                //       children: [
                //         Row(
                //           children: [
                //             Expanded(
                //               child: Divider(
                //                 color: AppColors.slateGray.withValues(
                //                   alpha: 0.2,
                //                 ),
                //               ),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.symmetric(
                //                 horizontal: 16,
                //               ),
                //               child: Text(
                //                 'Developed by',
                //                 style: TextStyle(
                //                   fontSize: 12,
                //                   color: AppColors.slateGray.withValues(
                //                     alpha: 0.5,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             Expanded(
                //               child: Divider(
                //                 color: AppColors.slateGray.withValues(
                //                   alpha: 0.2,
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //         const SizedBox(height: 16),
                //         GestureDetector(
                //           onTap: () {
                //             // Launch URL
                //           },
                //           child: Container(
                //             padding: const EdgeInsets.symmetric(
                //               horizontal: 20,
                //               vertical: 10,
                //             ),
                //             decoration: BoxDecoration(
                //               color: AppColors.primary.withValues(alpha: 0.1),
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Row(
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Icon(
                //                   Icons.auto_awesome,
                //                   size: 16,
                //                   color: AppColors.primary,
                //                 ),
                //                 const SizedBox(width: 8),
                //                 Text(
                //                   'Diwizon',
                //                   style: TextStyle(
                //                     fontSize: 14,
                //                     fontWeight: FontWeight.bold,
                //                     color: AppColors.primary,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   );
                // },

                // ---------------------------
                // Auth Actions
                // ---------------------------
                actions: [
                  ForgotPasswordAction((context, email) {
                    // Navigate to forgot password screen or show dialog
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    );
                  }),
                  AuthStateChangeAction<SignedIn>((context, state) {
                    if (state.user != null) {
                      // Fetch categories immediately after login
                      context.read<CategoryCubit>().fetchCategories();
                      context.go(Routes.dashboard);
                    }
                  }),
                  AuthStateChangeAction<UserCreated>((context, state) {
                    // Handle user creation if needed
                  }),
                ],

                // Styling
                styles: const {
                  EmailFormStyle(signInButtonVariant: ButtonVariant.filled),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
