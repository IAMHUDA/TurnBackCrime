import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/user_model.dart';
import './bloc/pengguna_bloc.dart';

class KelolaPenggunaPage extends StatefulWidget {
  const KelolaPenggunaPage({super.key});

  @override
  State<KelolaPenggunaPage> createState() => _KelolaPenggunaPageState();
}

class _KelolaPenggunaPageState extends State<KelolaPenggunaPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PenggunaBloc>().add(LoadPengguna());
  }

  // Tidak ada perubahan logika besar, hanya tambahkan input untuk semua field

void _showFormDialog({UserModel? user}) {
  final _namaController = TextEditingController(text: user?.nama ?? '');
  final _emailController = TextEditingController(text: user?.email ?? '');
  final _roleController = TextEditingController(text: user?.role ?? 'user');
  final _kontakDaruratController = TextEditingController(text: user?.kontakDarurat ?? '');
  final _alamatController = TextEditingController(text: user?.alamat ?? '');
  final _tanggalLahirController = TextEditingController(text: user?.tanggalLahir ?? '');
  final _emailDaruratController = TextEditingController(text: user?.emailDarurat ?? '');

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(user == null ? 'Tambah Pengguna' : 'Edit Pengguna'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _namaController, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _roleController, decoration: const InputDecoration(labelText: 'Role')),
            TextField(controller: _kontakDaruratController, decoration: const InputDecoration(labelText: 'Kontak Darurat')),
            TextField(controller: _alamatController, decoration: const InputDecoration(labelText: 'Alamat')),
            TextField(controller: _tanggalLahirController, decoration: const InputDecoration(labelText: 'Tanggal Lahir')),
            TextField(controller: _emailDaruratController, decoration: const InputDecoration(labelText: 'Email Darurat')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            final newUser = UserModel(
              id: user?.id ?? 0,
              nama: _namaController.text,
              email: _emailController.text,
              role: _roleController.text,
              kontakDarurat: _kontakDaruratController.text,
              alamat: _alamatController.text,
              tanggalLahir: _tanggalLahirController.text,
              emailDarurat: _emailDaruratController.text,
              fotoProfile: user?.fotoProfile,
            );

            if (user == null) {
              context.read<PenggunaBloc>().add(TambahPengguna(newUser));
            } else {
              context.read<PenggunaBloc>().add(UpdatePengguna(newUser));
            }

            Navigator.pop(context);
          },
          child: Text(user == null ? 'Tambah' : 'Simpan'),
        ),
      ],
    ),
  );
}


  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus ${user.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (user.id != null) {
                context.read<PenggunaBloc>().add(HapusPengguna(user.id!));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ID pengguna tidak valid.')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showFormDialog(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    context.read<PenggunaBloc>().add(SearchPengguna(_searchController.text));
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<PenggunaBloc, PenggunaState>(
        builder: (context, state) {
          if (state is PenggunaLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PenggunaLoaded) {
            return ListView.builder(
              itemCount: state.pengguna.length,
              itemBuilder: (context, index) {
                final user = state.pengguna[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user.nama),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showFormDialog(user: user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(user),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is PenggunaError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Tidak ada data pengguna'));
        },
      ),
    );
  }
}
