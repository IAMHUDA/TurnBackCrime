abstract class LaporanDetailEvent {}

class FetchLaporanDetail extends LaporanDetailEvent {
  final int id;

  FetchLaporanDetail(this.id);
}
