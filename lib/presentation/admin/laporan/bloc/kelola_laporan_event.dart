// lib/presentation/admin/laporan/bloc/kelola_laporan_event.dart

import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class KelolaLaporanEvent extends Equatable {
  const KelolaLaporanEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllKelolaLaporan extends KelolaLaporanEvent {
  final String? searchQuery;
  final String? statusFilter;

  const FetchAllKelolaLaporan({this.searchQuery, this.statusFilter});

  @override
  List<Object?> get props => [searchQuery, statusFilter];
}
class AddKelolaLaporan extends KelolaLaporanEvent {
  final int idPengguna;
  final String judul;
  final String deskripsi;
  final int idKategori;
  final double lokasiLat;
  final double lokasiLong;
  final File foto;
  final String? status; // Tambahkan ini agar bisa diset saat add

  const AddKelolaLaporan({
    required this.idPengguna,
    required this.judul,
    required this.deskripsi,
    required this.idKategori,
    required this.lokasiLat,
    required this.lokasiLong,
    required this.foto,
    this.status, // Opsional: default "Baru" di backend
  });

  @override
  List<Object?> get props => [
        idPengguna,
        judul,
        deskripsi,
        idKategori,
        lokasiLat,
        lokasiLong,
        foto,
        status,
      ];
}

class UpdateKelolaLaporan extends KelolaLaporanEvent {
  final int id;
  final int idPengguna;
  final String judul;
  final String deskripsi;
  final int idKategori;
  final String status;
  final double lokasiLat;
  final double lokasiLong;
  final File? foto; // Opsional jika foto tidak selalu diupdate

  const UpdateKelolaLaporan({
    required this.id,
    required this.idPengguna,
    required this.judul,
    required this.deskripsi,
    required this.idKategori,
    required this.status,
    required this.lokasiLat,
    required this.lokasiLong,
    this.foto,
  });

  @override
  List<Object?> get props => [
        id,
        idPengguna,
        judul,
        deskripsi,
        idKategori,
        status,
        lokasiLat,
        lokasiLong,
        foto,
      ];
}

class UpdateKelolaLaporanStatus extends KelolaLaporanEvent {
  final int id;
  final String status;

  const UpdateKelolaLaporanStatus({required this.id, required this.status});

  @override
  List<Object?> get props => [id, status];
}

class DeleteKelolaLaporan extends KelolaLaporanEvent {
  final int id;

  const DeleteKelolaLaporan({required this.id});

  @override
  List<Object?> get props => [id];
}

// Event untuk reset filter/pencarian jika diperlukan
class ResetKelolaLaporanFilters extends KelolaLaporanEvent {}