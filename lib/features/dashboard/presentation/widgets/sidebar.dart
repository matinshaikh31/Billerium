// ---------------------------
// Desktop Sidebar (Light Background for Logo Visibility)
// ---------------------------
import 'package:billing_software/core/routes/routes.dart';
import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key});

  static final List<SidebarItem> sidebarItems = [
    SidebarItem("Dashboard", Routes.dashboard, Icons.dashboard_outlined),
    SidebarItem("Products", Routes.products, Icons.inventory_2_outlined),
    SidebarItem("Categories", Routes.categories, Icons.category_outlined),
    SidebarItem("Create Bill", Routes.createBill, Icons.receipt_long_outlined),
    SidebarItem("Bills", Routes.bills, Icons.description_outlined),
    SidebarItem("Transactions", Routes.transcations, Icons.swap_horiz_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.secondary, // 🌿 Light beige background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with visible logo
          Center(
            child: Image.asset("logo.png", height: 180), // logo stays visible
          ),
          Divider(color: AppColors.borderGrey, height: 1),

          // Menu Label
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Text(
              "Menu",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: sidebarItems.length,
              itemBuilder: (context, index) {
                final item = sidebarItems[index];
                return _SidebarItemWidget(item: item);
              },
            ),
          ),

          Divider(color: AppColors.borderGrey, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _FooterButton(
                  icon: Icons.settings_outlined,
                  label: "Settings",
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _FooterButton(
                  icon: Icons.logout,
                  label: "Logout",
                  onTap: () {
                    context.read<AuthCubit>().logout(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// Sidebar Item Widget
// ---------------------------
class _SidebarItemWidget extends StatefulWidget {
  final SidebarItem item;
  const _SidebarItemWidget({required this.item});

  @override
  State<_SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<_SidebarItemWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isActive =
        currentRoute == widget.item.route ||
        currentRoute.startsWith("${widget.item.route}/");

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (!isActive) context.go(widget.item.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.1)
                : (isHovered
                      ? AppColors.primary.withOpacity(0.05)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border(left: BorderSide(color: AppColors.primary, width: 3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                widget.item.label,
                style: GoogleFonts.inter(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.9),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------
// Footer Button Widget
// ---------------------------
class _FooterButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_FooterButton> createState() => _FooterButtonState();
}

class _FooterButtonState extends State<_FooterButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isHovered
                ? AppColors.primary.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------
// Mobile Sidebar (Matches Desktop Look)
// ---------------------------
class MobileSidebar extends StatelessWidget {
  const MobileSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: AppColors.secondary, // same light background
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "B",
                      style: GoogleFonts.inter(
                        color: AppColors.secondary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Billerium",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: AppColors.borderGrey, height: 1),

            // Menu Label
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                "Menu",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: DesktopSidebar.sidebarItems.length,
                itemBuilder: (context, index) {
                  final item = DesktopSidebar.sidebarItems[index];
                  final isActive =
                      currentRoute == item.route ||
                      currentRoute.startsWith("${item.route}/");

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      selected: isActive,
                      selectedTileColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: Icon(
                        item.icon,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      title: Text(
                        item.label,
                        style: GoogleFonts.inter(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        context.go(item.route);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),

            Divider(color: AppColors.borderGrey, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.settings_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      "Settings",
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      "Logout",
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AuthCubit>().logout(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------
// Sidebar Item Model
// ---------------------------
class SidebarItem {
  final String label;
  final String route;
  final IconData icon;
  const SidebarItem(this.label, this.route, this.icon);
}
