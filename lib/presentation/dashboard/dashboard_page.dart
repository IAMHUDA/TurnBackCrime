import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';
import '../laporan/pages/laporan_page.dart';
import 'components/bottom_nav_bar.dart';
import 'components/notification_bell.dart';
import 'components/category_card.dart';
import '../riwayat_laporan/bloc/riwayat_laporan_bloc.dart';
import '../riwayat_laporan/bloc/riwayat_laporan_event.dart';
import '../riwayat_laporan/bloc/riwayat_laporan_state.dart';
import '../laporan_detail/pages/laporan_detail_page.dart';
import '../sos/sos_page.dart';
import '../riwayat_laporan/pages/riwayat_laporan_page.dart';
import 'components/report_card.dart';
import '../../presentation/komentar/komentar_section.dart';
import '../../../data/model/user_model.dart';
import '../komentar/bloc/komentar_bloc.dart';
import '../../data/repository/komentar/komentar_repository.dart';
import '../profile/profile_page.dart';
import '../../data/model/laporan_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final Map<int, bool> _komentarVisible = {};
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiwayatLaporanBloc>().add(FetchRiwayatLaporan());
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 100 && !_showAppBarTitle) {
      setState(() => _showAppBarTitle = true);
    } else if (_scrollController.offset <= 100 && _showAppBarTitle) {
      setState(() => _showAppBarTitle = false);
    }
  }

  void _logout(BuildContext context) {
    BlocProvider.of<AuthBloc>(context).add(AuthLogoutRequested());
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Widget _buildMapSection(List<LaporanModel> laporanList) {
  Set<Circle> circles = {};
  Set<Marker> markers = {};

  // Filter hanya laporan yang memiliki lokasi
  final laporanDenganLokasi = laporanList.where((laporan) => 
    laporan.lokasiLat != null && laporan.lokasiLong != null).toList();

  // Jika tidak ada laporan dengan lokasi, tampilkan peta default
  if (laporanDenganLokasi.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daerah Rawan Kejahatan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-6.2088, 106.8456), // Jakarta default
                  zoom: 13,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('Tidak ada laporan dengan data lokasi'),
          ),
        ],
      ),
    );
  }

  // Proses laporan yang memiliki lokasi
  for (var laporan in laporanDenganLokasi) {
    final lat = laporan.lokasiLat!;
    final long = laporan.lokasiLong!;
    final id = laporan.id!.toString();

    circles.add(
      Circle(
        circleId: CircleId('circle_$id'),
        center: LatLng(lat, long),
        radius: 300,
        fillColor: Colors.redAccent.withOpacity(0.3),
        strokeColor: Colors.red,
        strokeWidth: 2,
      ),
    );

    markers.add(
      Marker(
        markerId: MarkerId('marker_$id'),
        position: LatLng(lat, long),
        infoWindow: InfoWindow(title: laporan.judul ?? 'Laporan'),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daerah Rawan Kejahatan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  laporanDenganLokasi.first.lokasiLat!,
                  laporanDenganLokasi.first.lokasiLong!,
                ),
                zoom: 13,
              ),
              circles: circles,
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildDashboardContent() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        UserModel? user;
        if (authState is AuthAuthenticated || authState is AuthAdmin) {
          user = (authState as dynamic).user;
        }

        return BlocBuilder<RiwayatLaporanBloc, RiwayatLaporanState>(
          builder: (context, state) {
            if (state is RiwayatLaporanLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                ),
              );
            } else if (state is RiwayatLaporanLoaded) {
              final laporanList = state.laporanList;
              if (laporanList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.report_problem,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada laporan',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jadilah yang pertama melaporkan kejahatan',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _currentIndex = 1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Buat Laporan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: Colors.redAccent,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  context.read<RiwayatLaporanBloc>().add(FetchRiwayatLaporan());
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 220,
                      collapsedHeight: kToolbarHeight,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      title: _showAppBarTitle
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Halo, ${user?.nama?.split(' ')[0] ?? 'Pengguna'}',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    NotificationBell(
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.logout,
                                        color: Colors.grey[700],
                                      ),
                                      onPressed: () => _logout(context),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : null,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        titlePadding: _showAppBarTitle
                            ? const EdgeInsetsDirectional.only(
                                start: 16,
                                bottom: 16,
                              )
                            : EdgeInsets.zero,
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.red[900]!, Colors.red[700]!],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.security,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Halo, ${user?.nama?.split(' ')[0] ?? 'Pengguna'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Apa yang terjadi hari ini?',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Laporkan kejahatan di sekitarmu',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kategori Kejahatan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: const [
                                  CategoryCard(
                                    title: 'Pencurian',
                                    icon: Icons.credit_card_off,
                                    color: Colors.redAccent,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFF416C),
                                        Color(0xFFFF4B2B),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  CategoryCard(
                                    title: 'Kekerasan',
                                    icon: Icons.warning_amber_rounded,
                                    color: Colors.orangeAccent,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFFB347),
                                        Color(0xFFFFCC33),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  CategoryCard(
                                    title: 'Penipuan',
                                    icon: Icons.money_off,
                                    color: Colors.purpleAccent,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFDA22FF),
                                        Color(0xFF9733EE),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  CategoryCard(
                                    title: 'Lainnya',
                                    icon: Icons.more_horiz,
                                    color: Colors.blueAccent,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1FA2FF),
                                        Color(0xFF12D8FA),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildMapSection(laporanList),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Laporan Terbaru',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    context.read<RiwayatLaporanBloc>().add(
                                          FetchRiwayatLaporan(),
                                        );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final laporan = state.laporanList[index];
                        final komentarVisible =
                            _komentarVisible[laporan.id!] ?? false;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailLaporanPage(
                                      laporanId: laporan.id!,
                                    ),
                                  ),
                                );
                              },
                              child: ReportCard(
                                title: laporan.judul ?? 'Tidak ada judul',
                                location: (laporan.lokasiLat != null &&
                                        laporan.lokasiLong != null)
                                    ? '${_getLocationName(laporan.lokasiLat!, laporan.lokasiLong!)}'
                                    : 'Lokasi tidak tersedia',
                                time: _formatDate(laporan.createdAt),
                                description: laporan.deskripsi ?? '',
                                totalKomentar: laporan.totalKomentar ?? 0,
                                onKomentarTap: () {
                                  setState(() {
                                    _komentarVisible[laporan.id!] =
                                        !(komentarVisible);
                                  });
                                },
                              ),
                            ),
                            if (komentarVisible && user != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: BlocProvider<KomentarBloc>(
                                  key: ValueKey('komentar_${laporan.id}'),
                                  create: (_) => KomentarBloc(
                                    RepositoryProvider.of<KomentarRepository>(
                                        context),
                                  )..add(
                                      LoadKomentar(idLaporan: laporan.id!),
                                    ),
                                  child: KomentarSection(
                                    key: ValueKey('section_${laporan.id}'),
                                    laporanId: laporan.id!,
                                    showInput: true,
                                  ),
                                ),
                              ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(height: 1, thickness: 1),
                            ),
                          ],
                        );
                      }, childCount: state.laporanList.length),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal memuat data',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan coba lagi nanti',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      context.read<RiwayatLaporanBloc>().add(
                            FetchRiwayatLaporan(),
                          );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getLocationName(double lat, double long) {
    if (lat > -6.3 && lat < -6.1 && long > 106.7 && long < 106.9) {
      return 'Jakarta Pusat';
    } else if (lat > -6.9 && lat < -6.1 && long > 107.5 && long < 107.7) {
      return 'Bandung';
    }
    return 'Lokasi: ${lat.toStringAsFixed(4)}, ${long.toStringAsFixed(4)}';
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[700]!, Colors.red[900]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'TurnBackCrime',
                    style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              actions: [
                if (_currentIndex != 4)
                  NotificationBell(onTap: () {}),
                if (_currentIndex == 4)
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.grey[700]),
                    onPressed: () => _logout(context),
                  ),
              ],
            ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (_currentIndex == 0) return _buildDashboardContent();
          if (_currentIndex == 1) return const LaporanPage();
          if (_currentIndex == 2) {
            if (state is AuthAuthenticated || state is AuthAdmin) {
              final user = (state as dynamic).user;
              return SOSPage(
                idPengguna: user.id!,
                nama: user.nama,
                emailTujuan: user.email,
              );
            } else {
              return const Center(child: Text('Silakan login dahulu.'));
            }
          }
          if (_currentIndex == 3) return const RiwayatLaporanPage();
          if (_currentIndex == 4) return const ProfilePage();
          return const Center(child: Text('Tidak ditemukan.'));
        },
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanPage(),
                  ),
                );
              },
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.add, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
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