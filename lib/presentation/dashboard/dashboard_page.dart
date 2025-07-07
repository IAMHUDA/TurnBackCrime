import 'package:flutter/material.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../laporan/pages/laporan_page.dart';
import 'components/bottom_nav_bar.dart';
import 'components/notification_bell.dart';
import 'components/category_card.dart';

import 'components/report_card.dart';
import '../sos/sos_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  void _logout(BuildContext context) {
    BlocProvider.of<AuthBloc>(context).add(AuthLogoutRequested());
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      _buildDashboardContent(),
      LaporanPage(),
      SOSPage(),
    ]);
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Kategori Kejahatan'),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryCard(title: 'Pencurian', icon: Icons.security, color: Colors.red),
              CategoryCard(title: 'Kekerasan', icon: Icons.warning, color: Colors.orange),
              CategoryCard(title: 'Lainnya', icon: Icons.more_horiz, color: Colors.blue),
            ],
          ),
          SizedBox(height: 20),
          Text('Statistik'),
          SizedBox(height: 12),
          
          SizedBox(height: 20),
          Text('Laporan Terbaru'),
          SizedBox(height: 12),
          ReportCard(
            title: 'Pencurian Motor',
            location: 'Jl. Malioboro',
            time: '1 jam lalu',
            description: 'Sebuah motor hilang di parkiran...',
            totalKomentar: 3,
          ),
          SizedBox(height: 12),
          ReportCard(
            title: 'Kekerasan Jalanan',
            location: 'Jl. Gejayan',
            time: '2 jam lalu',
            description: 'Terjadi perkelahian antar kelompok...',
            totalKomentar: 5,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[700]!, Colors.red[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.security, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'TurnBackCrime',
              style: TextStyle(
                color: Colors.red[800],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          NotificationBell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notifikasi clicked')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey[700]),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
