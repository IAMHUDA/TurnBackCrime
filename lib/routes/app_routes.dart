import 'package:flutter/material.dart';
import 'package:turnbackcrime/presentation/admin/pengguna/kelola_pengguna_page.dart';
import '../presentation/auth/pages/login_page.dart';
import '../presentation/auth/pages/register_page.dart';
import '../presentation/auth/pages/splash_screen.dart';
import '../presentation/auth/pages/complete_profile_page.dart';
import '../presentation/dashboard/dashboard_page.dart';
import '../presentation/dashboard/admin_dashboard_page.dart';
import '../presentation/laporan/pages/laporan_page.dart'; 
import '../presentation/laporan_detail/pages/laporan_detail_page.dart';
import '../presentation/profile/profile_page.dart';
import '../presentation/admin/laporan/kelola_laporan_page.dart';

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
      case '/kelola-pengguna':
        return MaterialPageRoute(builder: (_) => const KelolaPenggunaPage());
      case '/kelola-laporan': // New route for admin report management
        return MaterialPageRoute(builder: (_) => const KelolaLaporanPage());
      case '/laporan_detail':
        final laporanId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => DetailLaporanPage(laporanId: laporanId),  
        );
      case '/profile':
  return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}
