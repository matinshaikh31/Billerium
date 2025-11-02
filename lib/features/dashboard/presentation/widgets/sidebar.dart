import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billing_software/core/theme/app_colors.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final List<_SidebarItem> menuItems = [
    _SidebarItem('Dashboard', Icons.dashboard, '/dashboard'),
    _SidebarItem('Products', Icons.inventory_2_rounded, '/products'),
    _SidebarItem('Categories', Icons.category_outlined, '/categories'),
    _SidebarItem('Create Bill', Icons.receipt_long, '/create-bill'),
    _SidebarItem('Bills', Icons.list_alt_outlined, '/bills'),
    _SidebarItem('Stock', Icons.store_mall_directory_outlined, '/stock'),
    _SidebarItem('Transactions', Icons.swap_horiz_outlined, '/transactions'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Container(
      width: 230,
      color: const Color(0xFF111827), // Sidebar background
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo / Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "B",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "BillManager",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Menu items
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isActive =
                      currentRoute == item.route ||
                      currentRoute.startsWith("${item.route}/");

                  return InkWell(
                    onTap: () {
                      if (!isActive) context.go(item.route);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF2563EB)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: isActive ? Colors.white : Colors.white70,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item.label,
                            style: GoogleFonts.inter(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(color: Color(0xFF2A2A2D), height: 1),
            const SizedBox(height: 10),

            // Footer (Settings + Logout)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  _footerTile(Icons.settings_outlined, "Settings", () {
                    // context.go('/settings');
                  }),
                  const SizedBox(height: 4),
                  _footerTile(Icons.logout_outlined, "Logout", () {
                    // context.read<AuthCubit>().logout(context);
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem {
  final String label;
  final IconData icon;
  final String route;

  const _SidebarItem(this.label, this.icon, this.route);
}
