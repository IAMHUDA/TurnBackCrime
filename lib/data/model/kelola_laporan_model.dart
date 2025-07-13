// lib/data/model/kelola_laporan_model.dart

class KelolaLaporanModel {
  final int? id;
  final int? idPengguna;
  final String? judul;
  final String? deskripsi;
  final int? idKategori;
  final String? status;
  final double? lokasiLat;
  final double? lokasiLong;
  final String? foto; // URL foto
  final String? createdAt;
  final String? updatedAt;
  final int? totalKomentar;
  final String? namaKategori; // Tambahkan ini

  KelolaLaporanModel({
    this.id,
    this.idPengguna,
    this.judul,
    this.deskripsi,
    this.idKategori,
    this.status,
    this.lokasiLat,
    this.lokasiLong,
    this.foto,
    this.createdAt,
    this.updatedAt,
    this.totalKomentar,
    this.namaKategori, // Tambahkan ini
  });

  factory KelolaLaporanModel.fromJson(Map<String, dynamic> json) {
    final baseUrl = 'http://10.0.2.2:5000/uploads/';
    return KelolaLaporanModel(
      id: json['id'],
      idPengguna: json['id_pengguna'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      idKategori: json['id_kategori'],
      status: json['status'],
      lokasiLat: (json['lokasi_lat'] as num?)?.toDouble(),
      lokasiLong: (json['lokasi_long'] as num?)?.toDouble(),
      foto: json['foto'] != null
          ? baseUrl + json['foto']
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      totalKomentar: json['total_komentar'],
      namaKategori: json['nama_kategori'], // Pastikan backend mengirim ini
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_pengguna': idPengguna,
      'judul': judul,
      'deskripsi': deskripsi,
      'id_kategori': idKategori,
      'status': status,
      'lokasi_lat': lokasiLat,
      'lokasi_long': lokasiLong,
      'foto': foto,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'total_komentar': totalKomentar,
      'nama_kategori': namaKategori, // Tambahkan ini
    };
  }

  // Metode copyWith untuk mempermudah pembaruan objek
  KelolaLaporanModel copyWith({
    int? id,
    int? idPengguna,
    String? judul,
    String? deskripsi,
    int? idKategori,
    String? status,
    double? lokasiLat,
    double? lokasiLong,
    String? foto,
    String? createdAt,
    String? updatedAt,
    int? totalKomentar,
    String? namaKategori,
  }) {
    return KelolaLaporanModel(
      id: id ?? this.id,
      idPengguna: idPengguna ?? this.idPengguna,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      idKategori: idKategori ?? this.idKategori,
      status: status ?? this.status,
      lokasiLat: lokasiLat ?? this.lokasiLat,
      lokasiLong: lokasiLong ?? this.lokasiLong,
      foto: foto ?? this.foto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalKomentar: totalKomentar ?? this.totalKomentar,
      namaKategori: namaKategori ?? this.namaKategori,
    );
  }
}