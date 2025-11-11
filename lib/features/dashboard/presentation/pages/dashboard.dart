import 'package:billing_software/core/routes/routes.dart';
import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/widgets/responsive_widget.dart';
import 'package:billing_software/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:billing_software/features/dashboard/presentation/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------
// Dashboard with Sidebar
// ---------------------------
class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWid(
      mobile: _buildMobileLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // ✅ perfect choice
      body: Row(
        children: [
          const DesktopSidebar(), // left panel (light beige)
          Expanded(child: child), // right content (slightly darker tone)
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "B",
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "BillManager",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      drawer: const MobileSidebar(),
      body: child,
    );
  }
}
