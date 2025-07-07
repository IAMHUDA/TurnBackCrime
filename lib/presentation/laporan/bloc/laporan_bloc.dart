import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/model/kategori_model.dart';
import '../../../data/repository/kategori/kategori_repository.dart';
import '../../../data/repository/laporan/laporan_repositori.dart';

part 'laporan_event.dart';
part 'laporan_state.dart';

class LaporanBloc extends Bloc<LaporanEvent, LaporanState> {
  final KategoriRepository kategoriRepository;
  final LaporanRepository laporanRepository;

  LaporanBloc({
    required this.kategoriRepository,
    required this.laporanRepository,
  }) : super(LaporanState.initial()) {
    on<FetchKategori>(_onFetchKategori);
    on<SelectKategori>(_onSelectKategori);
    on<AddKategori>(_onAddKategori);
    on<SelectImage>(_onSelectImage);
    on<SelectLocation>(_onSelectLocation);
    on<SetJudul>(_onSetJudul);
    on<SetDeskripsi>(_onSetDeskripsi);
    on<SubmitLaporan>(_onSubmitLaporan);
    on<ResetLaporanStatus>(_onResetLaporanStatus);

    add(FetchKategori());
  }

  Future<void> _onFetchKategori(FetchKategori event, Emitter<LaporanState> emit) async {
    emit(state.copyWith(isLoadingKategori: true));
    try {
      final kategoriList = await kategoriRepository.getAllKategori();
      emit(state.copyWith(kategoriList: kategoriList, isLoadingKategori: false));
    } catch (e) {
      emit(state.copyWith(isLoadingKategori: false));
    }
  }

  void _onSelectKategori(SelectKategori event, Emitter<LaporanState> emit) {
    emit(state.copyWith(selectedKategori: event.kategori));
  }

  Future<void> _onAddKategori(AddKategori event, Emitter<LaporanState> emit) async {
    try {
      await kategoriRepository.createKategori(event.kategori);
      add(FetchKategori());
    } catch (e) {
      // Gagal menambah kategori
    }
  }

  void _onSelectImage(SelectImage event, Emitter<LaporanState> emit) {
    emit(state.copyWith(selectedImage: File(event.imagePath)));
  }

  void _onSelectLocation(SelectLocation event, Emitter<LaporanState> emit) {
    emit(state.copyWith(selectedLocation: LatLng(event.latitude, event.longitude)));
  }

  void _onSetJudul(SetJudul event, Emitter<LaporanState> emit) {
    emit(state.copyWith(judul: event.judul));
  }

  void _onSetDeskripsi(SetDeskripsi event, Emitter<LaporanState> emit) {
    emit(state.copyWith(deskripsi: event.deskripsi));
  }

  Future<void> _onSubmitLaporan(SubmitLaporan event, Emitter<LaporanState> emit) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || state.selectedKategori == null || state.selectedImage == null || state.selectedLocation == null) {
        emit(state.copyWith(isSubmitting: false, isSuccess: false));
        return;
      }

      final success = await laporanRepository.submitLaporan(
        idPengguna: int.parse(userId),
        judul: state.judul ?? '',
        deskripsi: state.deskripsi ?? '',
        idKategori: state.selectedKategori!.id,
        latitude: state.selectedLocation!.latitude,
        longitude: state.selectedLocation!.longitude,
        foto: state.selectedImage!,
      );

      if (success) {
        emit(LaporanState.initial().copyWith(isSuccess: true));
      } else {
        emit(state.copyWith(isSubmitting: false, isSuccess: false));
      }
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, isSuccess: false));
    }
  }

  void _onResetLaporanStatus(ResetLaporanStatus event, Emitter<LaporanState> emit) {
    emit(state.copyWith(isSuccess: null));
  }
}
