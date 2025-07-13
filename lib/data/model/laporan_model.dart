class LaporanModel {
  final int id;
  final int? idPengguna;
  final String? judul;
  final int? idKategori;
  final String? deskripsi;
  final String? foto;
  final double? lokasiLat;
  final double? lokasiLong;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final int? totalKomentar;

  LaporanModel({
    required this.id,
    this.idPengguna,
    this.judul,
    this.idKategori,
    this.deskripsi,
    this.foto,
    this.lokasiLat,
    this.lokasiLong,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.totalKomentar,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      id: json['id'],
      idPengguna: json['id_pengguna'],
      judul: json['judul'],
      idKategori: json['id_kategori'],
      deskripsi: json['deskripsi'],
      foto: json['foto'],
      lokasiLat: json['lokasi_lat'] != null ? json['lokasi_lat'].toDouble() : null,
      lokasiLong: json['lokasi_long'] != null ? json['lokasi_long'].toDouble() : null,
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      totalKomentar: json['total_komentar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'created_at': createdAt,
      'total_komentar': totalKomentar,
    };
  }
}
