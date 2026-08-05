import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/utils/snackbar_utils.dart';

@RoutePage()
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _logout(BuildContext context) async {
    // SharedPreferences-ലെ ഡാറ്റ ക്ലിയർ ചെയ്യുക
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // ടോക്കൺ റിമൂവ് ചെയ്യുന്നു
    await prefs.remove('user_id'); // യൂസർ ഐഡി റിമൂവ് ചെയ്യുന്നു
    
    // ലോഗിൻ സ്ക്രീനിലേക്ക് പോകുക (പഴയ സ്ക്രീനുകൾ എല്ലാം റിമൂവ് ചെയ്തുകൊണ്ട്)
    if (context.mounted) {
      SnackbarUtils.showSuccess(context, 'Logged out successfully');
      context.router.replaceAll([const LoginRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to Dashboard!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

