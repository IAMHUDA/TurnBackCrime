import '../../../../data/model/laporan_model.dart';

abstract class LaporanDetailState {}

class LaporanDetailInitial extends LaporanDetailState {}

class LaporanDetailLoading extends LaporanDetailState {}

class LaporanDetailLoaded extends LaporanDetailState {
  final LaporanModel laporan;

  LaporanDetailLoaded(this.laporan);
}

class LaporanDetailError extends LaporanDetailState {
  final String message;

  LaporanDetailError(this.message);
}
