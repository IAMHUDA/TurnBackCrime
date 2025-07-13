import '../../../data/model/laporan_model.dart';

abstract class RiwayatLaporanState {}

class RiwayatLaporanInitial extends RiwayatLaporanState {}

class RiwayatLaporanLoading extends RiwayatLaporanState {}

class RiwayatLaporanLoaded extends RiwayatLaporanState {
  final List<LaporanModel> laporanList;

  RiwayatLaporanLoaded(this.laporanList);
}

class RiwayatLaporanError extends RiwayatLaporanState {
  final String message;

  RiwayatLaporanError(this.message);
}
