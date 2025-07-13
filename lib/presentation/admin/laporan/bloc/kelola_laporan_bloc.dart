// lib/presentation/admin/laporan/bloc/kelola_laporan_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../../data/model/kelola_laporan_model.dart';
import '../../../../../data/repository/laporan/kelola_laporan_repository.dart'; // Sesuaikan path
import 'kelola_laporan_event.dart';
import 'kelola_laporan_state.dart';

class KelolaLaporanBloc extends Bloc<KelolaLaporanEvent, KelolaLaporanState> {
  final KelolaLaporanRepository kelolaLaporanRepository;

  String? _currentSearchQuery;
  String? _currentStatusFilter;

  KelolaLaporanBloc({required this.kelolaLaporanRepository})
      : super(KelolaLaporanInitial()) {
    on<FetchAllKelolaLaporan>(_onFetchAllKelolaLaporan);
    on<AddKelolaLaporan>(_onAddKelolaLaporan);
    on<UpdateKelolaLaporan>(_onUpdateKelolaLaporan);
    on<UpdateKelolaLaporanStatus>(_onUpdateKelolaLaporanStatus);
    on<DeleteKelolaLaporan>(_onDeleteKelolaLaporan);
    on<ResetKelolaLaporanFilters>(_onResetKelolaLaporanFilters);
  }

  Future<void> _onFetchAllKelolaLaporan(
    FetchAllKelolaLaporan event,
    Emitter<KelolaLaporanState> emit,
  ) async {
    emit(KelolaLaporanLoading());
    try {
      // Simpan parameter event ke variabel internal bloc
      _currentSearchQuery = event.searchQuery;
      _currentStatusFilter = event.statusFilter;

      final List<KelolaLaporanModel> laporanList =
          await kelolaLaporanRepository.getKelolaLaporan(
        searchQuery: _currentSearchQuery, 
        statusFilter: _currentStatusFilter, 
      );
      emit(KelolaLaporanLoaded(
        laporanList: laporanList,
        currentSearchQuery: _currentSearchQuery, 
        currentStatusFilter: _currentStatusFilter, 
      ));
    } catch (e) {
      emit(KelolaLaporanError(message: 'Gagal memuat laporan: $e'));
    }
  }

  Future<void> _onAddKelolaLaporan(
    AddKelolaLaporan event,
    Emitter<KelolaLaporanState> emit,
  ) async {
    emit(KelolaLaporanLoading());
    try {
      final newLaporan = KelolaLaporanModel(
        idPengguna: event.idPengguna,
        judul: event.judul,
        deskripsi: event.deskripsi,
        idKategori: event.idKategori,
        lokasiLat: event.lokasiLat,
        lokasiLong: event.lokasiLong,
        status: event.status ?? 'Baru', // Default status jika tidak diset
      );
      await kelolaLaporanRepository.addKelolaLaporan(newLaporan, event.foto);
      emit(const KelolaLaporanActionSuccess(message: 'Laporan berhasil ditambahkan.'));
      // Setelah sukses, muat ulang dengan filter terakhir yang tersimpan di _current...
      add(FetchAllKelolaLaporan(
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter,
      ));
    } catch (e) {
      emit(KelolaLaporanError(message: 'Gagal menambahkan laporan: $e'));
      // Jika gagal, tetap muat ulang dengan filter terakhir
      add(FetchAllKelolaLaporan(
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter,
      ));
    }
  }

  Future<void> _onUpdateKelolaLaporan(
    UpdateKelolaLaporan event,
    Emitter<KelolaLaporanState> emit,
  ) async {
    emit(KelolaLaporanLoading());
    try {
      final updatedLaporan = KelolaLaporanModel(
        id: event.id,
        idPengguna: event.idPengguna,
        judul: event.judul,
        deskripsi: event.deskripsi,
        idKategori: event.idKategori,
        status: event.status,
        lokasiLat: event.lokasiLat,
        lokasiLong: event.lokasiLong,
      );
      await kelolaLaporanRepository.updateKelolaLaporan(updatedLaporan, event.foto);
      emit(const KelolaLaporanActionSuccess(message: 'Laporan berhasil diperbarui.'));
      // Setelah sukses, muat ulang dengan filter terakhir yang tersimpan di _current...
      add(FetchAllKelolaLaporan(
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter,
      ));
    } catch (e) {
      emit(KelolaLaporanError(message: 'Gagal memperbarui laporan: $e'));
      // Jika gagal, tetap muat ulang dengan filter terakhir
      add(FetchAllKelolaLaporan(
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter,
      ));
    }
  }

  Future<void> _onUpdateKelolaLaporanStatus(
    UpdateKelolaLaporanStatus event,
    Emitter<KelolaLaporanState> emit,
  ) async {
    emit(KelolaLaporanLoading());
    try {
      await kelolaLaporanRepository.updateKelolaLaporanStatus(id: event.id, status: event.status);
      emit(const KelolaLaporanActionSuccess(message: 'Status laporan berhasil diperbarui.'));
      // Setelah update status, muat ulang dengan filter yang *sedang aktif*,
      // bukan dengan status baru dari event.status, agar laporan tetap terlihat
      // jika filter tidak cocok dengan status baru.
      add(FetchAllKelolaLaporan(
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter, // Gunakan filter terakhir yang aktif
      ));
    } catch (e) {
      emit(KelolaLaporanError(message: 'Gagal memperbarui status laporan: $e'));
      // Jika gagal, tetap muat ulang dengan filter terakhir
      add(FetchAllKelolaLaporan(
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter,
      ));
    }
  }

  Future<void> _onDeleteKelolaLaporan(
    DeleteKelolaLaporan event,
    Emitter<KelolaLaporanState> emit,
  ) async {
    emit(KelolaLaporanLoading());
    try {
      await kelolaLaporanRepository.deleteKelolaLaporan(event.id);
      emit(const KelolaLaporanActionSuccess(message: 'Laporan berhasil dihapus.'));
      // Setelah sukses, muat ulang dengan filter terakhir yang tersimpan di _current...
      add(FetchAllKelolaLaporan(
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter,
      ));
    } catch (e) {
      emit(KelolaLaporanError(message: 'Gagal menghapus laporan: $e'));
      // Jika gagal, tetap muat ulang dengan filter terakhir
      add(FetchAllKelolaLaporan(
        searchQuery: _currentSearchQuery,
        statusFilter: _currentStatusFilter,
      ));
    }
  }

  void _onResetKelolaLaporanFilters(
    ResetKelolaLaporanFilters event,
    Emitter<KelolaLaporanState> emit,
  ) {
    // Saat reset, set filter internal menjadi null
    _currentSearchQuery = null;
    _currentStatusFilter = null;
    add(FetchAllKelolaLaporan()); // Muat ulang semua tanpa filter
  }
}