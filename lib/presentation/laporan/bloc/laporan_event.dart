part of 'laporan_bloc.dart';

abstract class LaporanEvent extends Equatable {
  const LaporanEvent();

  @override
  List<Object?> get props => [];
}

class FetchKategori extends LaporanEvent {}

class SelectKategori extends LaporanEvent {
  final KategoriModel kategori;

  SelectKategori(this.kategori);

  @override
  List<Object?> get props => [kategori];
}

class AddKategori extends LaporanEvent {
  final String kategori;

  AddKategori(this.kategori);

  @override
  List<Object?> get props => [kategori];
}

class SelectImage extends LaporanEvent {
  final String imagePath;

  SelectImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class SelectLocation extends LaporanEvent {
  final double latitude;
  final double longitude;

  SelectLocation({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class SetJudul extends LaporanEvent {
  final String judul;

  SetJudul(this.judul);

  @override
  List<Object?> get props => [judul];
}

class SetDeskripsi extends LaporanEvent {
  final String deskripsi;

  SetDeskripsi(this.deskripsi);

  @override
  List<Object?> get props => [deskripsi];
}

class SubmitLaporan extends LaporanEvent {}
class ResetLaporanStatus extends LaporanEvent {}
