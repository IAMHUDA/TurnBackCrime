part of 'laporan_bloc.dart';

class LaporanState extends Equatable {
  final List<KategoriModel> kategoriList;
  final bool isLoadingKategori;
  final KategoriModel? selectedKategori;
  final File? selectedImage;
  final LatLng? selectedLocation;
  final String? judul;
  final String? deskripsi;
  final bool isSubmitting;
  final bool isSuccess;

  const LaporanState({
    required this.kategoriList,
    required this.isLoadingKategori,
    required this.selectedKategori,
    required this.selectedImage,
    required this.selectedLocation,
    required this.judul,
    required this.deskripsi,
    required this.isSubmitting,
    required this.isSuccess,
  });

  factory LaporanState.initial() {
    return LaporanState(
      kategoriList: [],
      isLoadingKategori: false,
      selectedKategori: null,
      selectedImage: null,
      selectedLocation: null,
      judul: '',
      deskripsi: '',
      isSubmitting: false,
      isSuccess: false,
    );
  }

  LaporanState copyWith({
    List<KategoriModel>? kategoriList,
    bool? isLoadingKategori,
    KategoriModel? selectedKategori,
    File? selectedImage,
    LatLng? selectedLocation,
    String? judul,
    String? deskripsi,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return LaporanState(
      kategoriList: kategoriList ?? this.kategoriList,
      isLoadingKategori: isLoadingKategori ?? this.isLoadingKategori,
      selectedKategori: selectedKategori ?? this.selectedKategori,
      selectedImage: selectedImage ?? this.selectedImage,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        kategoriList,
        isLoadingKategori,
        selectedKategori,
        selectedImage,
        selectedLocation,
        judul,
        deskripsi,
        isSubmitting,
        isSuccess,
      ];
}
