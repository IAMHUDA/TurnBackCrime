import 'package:flutter_bloc/flutter_bloc.dart';
import 'laporan_detail_event.dart';
import 'laporan_detail_state.dart';
import '../../../../data/repository/laporan/laporan_repositori.dart';

class LaporanDetailBloc extends Bloc<LaporanDetailEvent, LaporanDetailState> {
  final LaporanRepository laporanRepository;

  LaporanDetailBloc({required this.laporanRepository}) : super(LaporanDetailInitial()) {
    on<FetchLaporanDetail>((event, emit) async {
      emit(LaporanDetailLoading());
      try {
        final laporan = await laporanRepository.getLaporanById(event.id);
        emit(LaporanDetailLoaded(laporan));
      } catch (e) {
        emit(LaporanDetailError(e.toString()));
      }
    });
  }
}
