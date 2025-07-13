import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'routes/app_routes.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/laporan/bloc/laporan_bloc.dart';
import 'presentation/riwayat_laporan/bloc/riwayat_laporan_bloc.dart';
import 'presentation/riwayat_laporan/bloc/riwayat_laporan_event.dart';
import 'presentation/laporan_detail/bloc/laporan_detail_bloc.dart';

import 'data/repository/kategori/kategori_repository.dart';
import 'data/repository/laporan/laporan_repositori.dart';
import 'data/repository/komentar/komentar_repository.dart';
import 'services/service_http_client.dart';
import 'presentation/komentar/bloc/komentar_bloc.dart';
import 'presentation/sos/bloc/sos_bloc.dart';
import 'data/repository/sos/sos_repository.dart';
import 'presentation/sos/sos_email_service.dart';
import 'presentation/profile/bloc/profile_bloc.dart';
import 'data/repository/pengguna/user_repository.dart';
import 'presentation/admin/pengguna/bloc/pengguna_bloc.dart';
import 'presentation/admin/laporan/bloc/kelola_laporan_bloc.dart';
import 'data/repository/laporan/kelola_laporan_repository.dart'; // Repository BARU (untuk admin)

void main() {
  runApp(const TurnBackCrimeApp());
}

class TurnBackCrimeApp extends StatelessWidget {
  const TurnBackCrimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = ServiceHttpClient();
    final kategoriRepository = KategoriRepository(httpClient);
    final laporanRepository = LaporanRepository(httpClient); // Repository lama
    final komentarRepository = KomentarRepository(httpClient);
    final sosRepository = SOSRepository(httpClient);
    final userRepository = UserRepository(httpClient);
    final kelolaLaporanRepository = KelolaLaporanRepository(httpClient); // INISIALISASI REPOSITORY BARU

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ServiceHttpClient>(
          create: (context) => httpClient,
        ),
        RepositoryProvider<KategoriRepository>(
          create: (context) => kategoriRepository,
        ),
        RepositoryProvider<LaporanRepository>( // Repository untuk user
          create: (context) => laporanRepository,
        ),
        RepositoryProvider<KomentarRepository>(
          create: (context) => komentarRepository,
        ),
        RepositoryProvider<SOSRepository>(
          create: (context) => sosRepository,
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => userRepository,
        ),
        // TAMBAHKAN REPOSITORY BARU UNTUK KELOLA LAPORAN DI SINI
        RepositoryProvider<KelolaLaporanRepository>(
          create: (context) => kelolaLaporanRepository,
        ),
      ],
      child: MultiBlocProvider(
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
          BlocProvider<RiwayatLaporanBloc>(
            create: (context) => RiwayatLaporanBloc(
              laporanRepository,
            )..add(FetchRiwayatLaporan()),
          ),
          BlocProvider<LaporanDetailBloc>(
            create: (context) => LaporanDetailBloc(
              laporanRepository: laporanRepository,
            ),
          ),
          BlocProvider<KomentarBloc>(
            create: (context) => KomentarBloc(
              context.read<KomentarRepository>(),
            ),
          ),
          BlocProvider(
            create: (_) => SOSBloc(SOSRepository(httpClient), SOSEmailService()),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(httpClient),
          ),
          BlocProvider<PenggunaBloc>(
            create: (context) => PenggunaBloc(
              context.read<UserRepository>(),
            ),
          ),
          // SESUAIKAN BLOC KELOLA LAPORAN DI SINI
          BlocProvider<KelolaLaporanBloc>(
            create: (context) => KelolaLaporanBloc(
              // Gunakan kelolaLaporanRepository yang baru
              kelolaLaporanRepository: context.read<KelolaLaporanRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'TurnBackCrime',
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: AppRoutes.generateRoute,
        ),
      ),
    );
  }
}