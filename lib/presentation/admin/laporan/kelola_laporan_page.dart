// lib/presentation/admin/laporan/pages/kelola_laporan_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../../../data/model/kelola_laporan_model.dart';
import './bloc/kelola_laporan_bloc.dart';
import './bloc/kelola_laporan_event.dart';
import './bloc/kelola_laporan_state.dart';

class KelolaLaporanPage extends StatefulWidget {
  const KelolaLaporanPage({super.key});

  @override
  State<KelolaLaporanPage> createState() => _KelolaLaporanPageState();
}

class _KelolaLaporanPageState extends State<KelolaLaporanPage> {
  // === Definisi daftar status yang valid ===
  final Set<String> _statusOptionsSet = {
    'Baru',
    'Diteruskan',
    'Tidak Valid',
    'Selesai',
  };

  List<String> get _statusOptions => _statusOptionsSet.toList();

  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatusFilter; // Untuk filter status

  // Tambahkan Timer untuk Debounce Search
  // Jika Anda belum punya package flutter_bloc_patterns atau rxdart,
  // cara sederhana adalah dengan Dart's Timer
  // import 'dart:async'; // tambahkan ini
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Muat semua laporan tanpa filter atau pencarian saat inisialisasi
      context.read<KelolaLaporanBloc>().add(FetchAllKelolaLaporan());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); // Batalkan timer jika widget dibuang
    super.dispose();
  }

  // Helper untuk memicu fetch data dengan filter dan search yang ada
  void _fetchReportsWithCurrentFilters() {
    // Ambil nilai terbaru dari controller dan dropdown
    final String? currentSearch = _searchController.text.isNotEmpty ? _searchController.text : null;
    final String? currentFilter = _selectedStatusFilter;

    // Kirim event ke Bloc dengan nilai-nilai ini
    context.read<KelolaLaporanBloc>().add(
      FetchAllKelolaLaporan(
        searchQuery: currentSearch,
        statusFilter: currentFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Laporan'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), // Tinggi untuk search dan filter
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari laporan...',
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.blue[700],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      // Implementasi Debounce
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        _fetchReportsWithCurrentFilters();
                      });
                    },
                    onSubmitted: (value) {
                      // Trigger pencarian saat submit (misal keyboard enter)
                      _fetchReportsWithCurrentFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatusFilter,
                    hint: const Text('Filter Status', style: TextStyle(color: Colors.white70)),
                    dropdownColor: Colors.blue[700],
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null, // Opsi untuk menampilkan semua
                        child: Text('Semua Status', style: TextStyle(color: Colors.white)),
                      ),
                      ..._statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status, style: const TextStyle(color: Colors.white)),
                        );
                      }),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatusFilter = newValue;
                      });
                      _fetchReportsWithCurrentFilters(); // Terapkan filter
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty || _selectedStatusFilter != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _selectedStatusFilter = null;
                      });
                      // Langsung panggil event reset filter tanpa parameter search dan filter
                      context.read<KelolaLaporanBloc>().add(FetchAllKelolaLaporan());
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      body: BlocConsumer<KelolaLaporanBloc, KelolaLaporanState>(
        listener: (context, state) {
          if (state is KelolaLaporanActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Fetch All Laporan lagi setelah sukses, ini akan memperbarui UI
            // Menggunakan _fetchReportsWithCurrentFilters agar filter/search tetap diterapkan
            _fetchReportsWithCurrentFilters();
          } else if (state is KelolaLaporanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is KelolaLaporanLoaded) {
            // Ketika laporan berhasil dimuat, pastikan semua status yang ada
            // di laporan ditambahkan ke _statusOptionsSet agar dropdown tidak error
            setState(() {
              for (var laporan in state.laporanList) {
                if (laporan.status != null) {
                  _statusOptionsSet.add(laporan.status!);
                }
              }
              // Set search dan filter controller/variable dari state bloc agar konsisten
              // HANYA jika nilainya berbeda atau jika sedang loading state awal
              // Agar tidak mengganggu input pengguna saat mengetik
              if (_searchController.text != (state.currentSearchQuery ?? '')) {
                _searchController.text = state.currentSearchQuery ?? '';
              }
              if (_selectedStatusFilter != state.currentStatusFilter) {
                 _selectedStatusFilter = state.currentStatusFilter;
              }
            });
          }
        },
        builder: (context, state) {
          if (state is KelolaLaporanLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is KelolaLaporanLoaded) {
            if (state.laporanList.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ada laporan ditemukan untuk kriteria ini.'
                  '${_searchController.text.isNotEmpty ? " (Pencarian: '${_searchController.text}')" : ""}'
                  '${_selectedStatusFilter != null ? " (Status: '${_selectedStatusFilter}')" : ""}',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.laporanList.length,
              itemBuilder: (context, index) {
                final laporan = state.laporanList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  child: ListTile(
                    leading: laporan.foto != null && laporan.foto!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              laporan.foto!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 60),
                            ),
                          )
                        : const Icon(Icons.image, size: 60, color: Colors.grey),
                    title: Text(laporan.judul ?? 'Tidak ada judul',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${laporan.status ?? 'N/A'}'),
                        Text('Kategori: ${laporan.namaKategori ?? laporan.idKategori?.toString() ?? 'N/A'}'),
                        Text(
                            'Tanggal: ${laporan.createdAt != null ? _formatDateTime(laporan.createdAt!) : 'N/A'}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showAddEditReportDialog(context, laporan: laporan);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, laporan.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.update, color: Colors.green),
                          onPressed: () {
                            _showUpdateStatusDialog(context, laporan);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      _showReportDetailDialog(context, laporan);
                    },
                  ),
                );
              },
            );
          } else if (state is KelolaLaporanError) {
            return Center(child: Text(state.message));
          }
          return const Center(
              child: Text('Tidak ada laporan. Silakan tambahkan laporan baru.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        onPressed: () {
          _showAddEditReportDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  // --- Dialog Tambah/Edit Laporan ---
  void _showAddEditReportDialog(BuildContext pageContext,
      {KelolaLaporanModel? laporan}) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final _judulController = TextEditingController(text: laporan?.judul ?? '');
    final _deskripsiController =
        TextEditingController(text: laporan?.deskripsi ?? '');
    final _idKategoriController =
        TextEditingController(text: laporan?.idKategori?.toString() ?? '');
    final _lokasiLatController =
        TextEditingController(text: laporan?.lokasiLat?.toString() ?? '');
    final _lokasiLongController =
        TextEditingController(text: laporan?.lokasiLong?.toString() ?? '');

    String? _dialogSelectedStatus = laporan?.status;
    if (_dialogSelectedStatus == null || !_statusOptionsSet.contains(_dialogSelectedStatus)) {
      _dialogSelectedStatus = _statusOptions.first; // Default untuk laporan baru atau status tidak dikenal
    }

    File? _pickedImage;
    final String? _existingImageUrl = laporan?.foto;

    void _disposeControllers() {
      _judulController.dispose();
      _deskripsiController.dispose();
      _idKategoriController.dispose();
      _lokasiLatController.dispose();
      _lokasiLongController.dispose();
    }

    showDialog(
      context: pageContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(laporan == null ? 'Tambah Laporan Baru' : 'Edit Laporan'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _judulController,
                        decoration: const InputDecoration(labelText: 'Judul'),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Harap masukkan judul';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _deskripsiController,
                        decoration: const InputDecoration(labelText: 'Deskripsi'),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Harap masukkan deskripsi';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _idKategoriController,
                        decoration:
                            const InputDecoration(labelText: 'ID Kategori'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Harap masukkan ID Kategori';
                          if (int.tryParse(value) == null)
                            return 'Input harus angka';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _dialogSelectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: _statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _dialogSelectedStatus = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Pilih status';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _lokasiLatController,
                        decoration:
                            const InputDecoration(labelText: 'Lokasi Latitude'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Harap masukkan Lokasi Latitude';
                          if (double.tryParse(value) == null)
                            return 'Input tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _lokasiLongController,
                        decoration:
                            const InputDecoration(labelText: 'Lokasi Longitude'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Harap masukkan Lokasi Longitude';
                          if (double.tryParse(value) == null)
                            return 'Input tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      if (_pickedImage != null)
                        Image.file(_pickedImage!,
                            height: 100, width: 100, fit: BoxFit.cover)
                      else if (_existingImageUrl != null &&
                          _existingImageUrl.isNotEmpty)
                        Image.network(
                          _existingImageUrl,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                        )
                      else
                        const Text('Tidak ada gambar dipilih'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image =
                              await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              _pickedImage = File(image.path);
                            });
                          }
                        },
                        child: const Text('Pilih Gambar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _disposeControllers();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_dialogSelectedStatus == null) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Status tidak boleh kosong')),
                    );
                    return;
                  }

                  if (laporan == null) {
                    // Tambah laporan baru
                    if (_pickedImage == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                            content: Text('Pilih gambar untuk laporan baru')),
                      );
                      return;
                    }
                    pageContext.read<KelolaLaporanBloc>().add(
                          AddKelolaLaporan(
                            idPengguna: 1000, // ID pengguna contoh, sesuaikan
                            judul: _judulController.text,
                            deskripsi: _deskripsiController.text,
                            idKategori: int.parse(_idKategoriController.text),
                            lokasiLat: double.parse(_lokasiLatController.text),
                            lokasiLong: double.parse(_lokasiLongController.text),
                            foto: _pickedImage!,
                            status: _dialogSelectedStatus,
                          ),
                        );
                  } else {
                    // Update laporan yang sudah ada
                    pageContext.read<KelolaLaporanBloc>().add(
                          UpdateKelolaLaporan(
                            id: laporan.id!,
                            idPengguna: laporan.idPengguna!,
                            judul: _judulController.text,
                            deskripsi: _deskripsiController.text,
                            idKategori: int.parse(_idKategoriController.text),
                            status: _dialogSelectedStatus!,
                            lokasiLat: double.parse(_lokasiLatController.text),
                            lokasiLong: double.parse(_lokasiLongController.text),
                            foto: _pickedImage,
                          ),
                        );
                  }
                  _disposeControllers();
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(laporan == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        );
      },
    );
  }

  // --- Dialog Update Status Saja ---
  void _showUpdateStatusDialog(BuildContext pageContext, KelolaLaporanModel laporan) {
    String? _statusToUpdate = laporan.status;

    if (_statusToUpdate == null || !_statusOptionsSet.contains(_statusToUpdate)) {
      _statusToUpdate = _statusOptions.first;
    }

    showDialog(
      context: pageContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Status Laporan'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButtonFormField<String>(
                value: _statusToUpdate,
                decoration: const InputDecoration(labelText: 'Pilih Status Baru'),
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _statusToUpdate = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Status tidak boleh kosong';
                  return null;
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_statusToUpdate != null) {
                  pageContext.read<KelolaLaporanBloc>().add(
                        UpdateKelolaLaporanStatus(
                          id: laporan.id!,
                          status: _statusToUpdate!,
                        ),
                      );
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Pilih status baru.')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // --- Dialog Konfirmasi Hapus ---
  void _showDeleteConfirmationDialog(BuildContext pageContext, int? id) {
    if (id == null) {
      ScaffoldMessenger.of(pageContext).showSnackBar(
        const SnackBar(content: Text('ID Laporan tidak valid.')),
      );
      return;
    }
    showDialog(
      context: pageContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Anda yakin ingin menghapus laporan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                pageContext.read<KelolaLaporanBloc>().add(DeleteKelolaLaporan(id: id));
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- Dialog Detail Laporan ---
  void _showReportDetailDialog(BuildContext context, KelolaLaporanModel laporan) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(laporan.judul ?? 'Detail Laporan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (laporan.foto != null && laporan.foto!.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          laporan.foto!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 200),
                        ),
                      ),
                    ),
                  ),
                _buildDetailRow('ID Laporan:', laporan.id.toString()),
                _buildDetailRow('ID Pengguna:', laporan.idPengguna?.toString() ?? 'N/A'),
                _buildDetailRow('Judul:', laporan.judul ?? 'N/A'),
                _buildDetailRow('Deskripsi:', laporan.deskripsi ?? 'N/A'),
                _buildDetailRow('Kategori:', laporan.namaKategori ?? laporan.idKategori?.toString() ?? 'N/A'),
                _buildDetailRow('Status:', laporan.status),
                _buildDetailRow('Lokasi (Lat, Long):',
                    '${laporan.lokasiLat?.toStringAsFixed(6) ?? 'N/A'}, ${laporan.lokasiLong?.toStringAsFixed(6) ?? 'N/A'}'),
                _buildDetailRow('Dibuat Pada:',
                    laporan.createdAt != null ? _formatDateTime(laporan.createdAt!) : 'N/A'),
                _buildDetailRow('Diperbarui Pada:',
                    laporan.updatedAt != null ? _formatDateTime(laporan.updatedAt!) : 'N/A'),
                _buildDetailRow('Total Komentar:', laporan.totalKomentar?.toString() ?? '0'),
                const Divider(),
                const Text('Catatan Internal/Komentar:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Belum ada catatan internal. (Implementasi mendatang)'),
                const SizedBox(height: 8),
                const Text('Detail Pengguna:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Nama: Pengguna A (Implementasi mendatang)'),
                const Text('Email: user@example.com (Implementasi mendatang)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showAddEditReportDialog(context, laporan: laporan);
              },
              child: const Text('Edit Laporan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }
}