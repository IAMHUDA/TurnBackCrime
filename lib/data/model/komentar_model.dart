class Komentar {
  final int id;
  final int idPengguna;
  final int idLaporan;
  final String isiKomentar;
  final DateTime createdAt;
  final String namaPengguna;
  final String waktuLalu;

  Komentar({
    required this.id,
    required this.idPengguna,
    required this.idLaporan,
    required this.isiKomentar,
    required this.createdAt,
    required this.namaPengguna,
    required this.waktuLalu,
  });

  factory Komentar.fromJson(Map<String, dynamic> json) {
    return Komentar(
      id: json['id'],
      idPengguna: json['id_pengguna'],
      idLaporan: json['id_laporan'],
      isiKomentar: json['isi_komentar'],
      createdAt: DateTime.parse(json['created_at']),
      namaPengguna: json['nama_pengguna'],
      waktuLalu: json['waktu_lalu'],
    );
  }
}

class KomentarResponse {
  final List<Komentar> data;
  final MetaData meta;

  KomentarResponse({
    required this.data,
    required this.meta,
  });

  factory KomentarResponse.fromJson(Map<String, dynamic> json) {
    return KomentarResponse(
      data: (json['data'] as List)
          .map((e) => Komentar.fromJson(e))
          .toList(),
      meta: MetaData.fromJson(json['meta']),
    );
  }

  KomentarResponse copyWith({
    List<Komentar>? data,
    MetaData? meta,
  }) {
    return KomentarResponse(
      data: data ?? this.data,
      meta: meta ?? this.meta,
    );
  }
}

class MetaData {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  MetaData({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['total_pages'],
    );
  }

  MetaData copyWith({
    int? total,
    int? page,
    int? limit,
    int? totalPages,
  }) {
    return MetaData(
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}