import 'package:flutter_bloc/flutter_bloc.dart';
import 'riwayat_laporan_event.dart';
import 'riwayat_laporan_state.dart';
import '../../../data/repository/laporan/laporan_repositori.dart';

class RiwayatLaporanBloc extends Bloc<RiwayatLaporanEvent, RiwayatLaporanState> {
  final LaporanRepository laporanRepository;

  RiwayatLaporanBloc(this.laporanRepository) : super(RiwayatLaporanInitial()) {
    on<FetchRiwayatLaporan>((event, emit) async {
      emit(RiwayatLaporanLoading());

      try {
        final laporanList = await laporanRepository.getLaporan();
        emit(RiwayatLaporanLoaded(laporanList));
      } catch (e) {
        emit(RiwayatLaporanError(e.toString()));
      }
    });
  }
}
