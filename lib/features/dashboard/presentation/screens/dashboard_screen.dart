import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/snackbar_utils.dart';

@RoutePage()
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'Salesman';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Salesman';
    });
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name'); // Clear name too
    
    // Clear the newly added route details
    await prefs.remove('route_id');
    await prefs.remove('van_id');
    await prefs.remove('store_id');
    
    if (context.mounted) {
      SnackbarUtils.showSuccess(context, 'Logged out successfully');
      context.router.replaceAll([const LoginRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Van Sales App',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Top Left Alignment
            children: [
              // Greeting Section
              Text(
                'Hello, $_userName 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'What would you like to do today?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // 4-Grid Layout
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildDashboardCard(
                      context,
                      title: 'Customers',
                      icon: Icons.people_alt_rounded,
                      color: Colors.blue,
                      onTap: () {
                        context.router.push(const CustomerListRoute());
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Products',
                      icon: Icons.inventory_2_rounded,
                      color: Colors.orange,
                      onTap: () {
                        // TODO: Navigate to Products List
                        SnackbarUtils.showSuccess(context, 'Products Screen Coming Soon!');
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'New Invoice',
                      icon: Icons.add_shopping_cart_rounded,
                      color: Colors.green,
                      onTap: () {
                        // TODO: Navigate to Create Invoice
                        SnackbarUtils.showSuccess(context, 'Create Invoice Coming Soon!');
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Invoices',
                      icon: Icons.receipt_long_rounded,
                      color: Colors.purple,
                      onTap: () {
                        // TODO: Navigate to Invoices List
                        SnackbarUtils.showSuccess(context, 'Invoices List Coming Soon!');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

