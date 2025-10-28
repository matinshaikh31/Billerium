import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../navigation/router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.receipt_long, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  'Billing & Inventory',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state.isAuthenticated && state.admin != null) {
                      return Text(
                        state.admin!.email,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: AppRouter.dashboard,
                ),
                _DrawerItem(
                  icon: Icons.receipt,
                  title: 'Create Bill',
                  route: AppRouter.billing,
                ),
                _DrawerItem(
                  icon: Icons.list_alt,
                  title: 'Bills',
                  route: AppRouter.bills,
                ),
                _DrawerItem(
                  icon: Icons.inventory_2,
                  title: 'Products',
                  route: AppRouter.products,
                ),
                _DrawerItem(
                  icon: Icons.category,
                  title: 'Categories',
                  route: AppRouter.categories,
                ),
                _DrawerItem(
                  icon: Icons.payment,
                  title: 'Transactions',
                  route: AppRouter.transactions,
                ),
                _DrawerItem(
                  icon: Icons.warehouse,
                  title: 'Stock',
                  route: AppRouter.stock,
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              context.read<AuthCubit>().logout();
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    final isSelected = currentLocation == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        // Only pop if there's a drawer to close (mobile)
        if (Scaffold.of(context).hasDrawer &&
            Scaffold.of(context).isDrawerOpen) {
          Navigator.of(context).pop();
        }
        if (!isSelected) {
          context.go(route);
        }
      },
    );
  }
}
