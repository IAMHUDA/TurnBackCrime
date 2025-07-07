class KategoriModel {
  final int id;
  final String nama;

  KategoriModel({required this.id, required this.nama});

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'],
      nama: json['nama_kategori'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kategori': nama,
    };
  }
}
