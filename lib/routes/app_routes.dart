import 'package:flutter/material.dart';
import '../presentation/auth/pages/login_page.dart';
import '../presentation/auth/pages/register_page.dart';
import '../presentation/auth/pages/splash_screen.dart';
import '../presentation/auth/pages/complete_profile_page.dart';
import '../presentation/dashboard/dashboard_page.dart';
import '../presentation/dashboard/admin_dashboard_page.dart';
import '../presentation/laporan/pages/laporan_page.dart'; // ✅ Tambahkan ini

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => DashboardPage());
      case '/admin-dashboard':
        return MaterialPageRoute(builder: (_) => AdminDashboardPage());
      case '/complete-profile':
        return MaterialPageRoute(builder: (_) => CompleteProfilePage());
      case '/laporan': 
        return MaterialPageRoute(builder: (_) => LaporanPage());
      default:
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}
