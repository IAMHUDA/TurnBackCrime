import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  void _logout(BuildContext context) {
    BlocProvider.of<AuthBloc>(context).add(AuthLogoutRequested());
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAdmin) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Selamat Datang Admin, ${state.nama}!', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 8),
                  Text('Email: ${state.email}'),
                ],
              ),
            );
          } else {
            return Center(child: Text('User tidak ditemukan.'));
          }
        },
      ),
    );
  }
}
