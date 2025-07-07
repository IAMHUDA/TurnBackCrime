import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'routes/app_routes.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/laporan/bloc/laporan_bloc.dart';
import 'data/repository/kategori/kategori_repository.dart';
import 'data/repository/laporan/laporan_repositori.dart';
import 'services/service_http_client.dart';

void main() {
  runApp(const TurnBackCrimeApp());
}

class TurnBackCrimeApp extends StatelessWidget {
  const TurnBackCrimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = ServiceHttpClient();
    final kategoriRepository = KategoriRepository(httpClient);
    final laporanRepository = LaporanRepository(httpClient); 

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(httpClient),
        ),
        BlocProvider<LaporanBloc>(
          create: (context) => LaporanBloc(
            kategoriRepository: kategoriRepository,
            laporanRepository: laporanRepository, 
          )..add(FetchKategori()),
        ),
      ],
      child: MaterialApp(
        title: 'TurnBackCrime',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
