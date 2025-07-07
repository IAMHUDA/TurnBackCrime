import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnbackcrime/services/service_http_client.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../../data/data_provinsi.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class CompleteProfilePage extends StatefulWidget {
  @override
  _CompleteProfilePageState createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController kontakDaruratController = TextEditingController();
  final TextEditingController tanggalLahirController = TextEditingController();

  bool isLoading = false;
  String? selectedProvinsi;

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 3650)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User tidak ditemukan. Silakan login ulang.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }

        final httpClient = ServiceHttpClient();

        final response = await httpClient.put('/pengguna/$userId/profil', {
          'kontak_darurat': kontakDaruratController.text.trim(),
          'alamat': selectedProvinsi,
          'tanggal_lahir': tanggalLahirController.text.trim(),
        });

        if (response.statusCode == 200) {
          // ✅ Simpan data terbaru ke SharedPreferences
          await prefs.setString('alamat', selectedProvinsi!);
          await prefs.setString('kontak_darurat', kontakDaruratController.text.trim());
          await prefs.setString('tanggal_lahir', tanggalLahirController.text.trim());

          // ✅ Ambil ulang semua data yang diperlukan
          final nama = prefs.getString('nama') ?? '';
          final email = prefs.getString('email') ?? '';
          final kontakDarurat = kontakDaruratController.text.trim();
          final alamat = selectedProvinsi ?? '';
          final tanggalLahir = tanggalLahirController.text.trim();

          // ✅ Trigger Bloc agar state diperbarui
          BlocProvider.of<AuthBloc>(context).add(
            AuthProfileCompleted(
              nama: nama,
              email: email,
              kontakDarurat: kontakDarurat,
              alamat: alamat,
              tanggalLahir: tanggalLahir,
            ),
          );

          // ✅ Redirect ke Dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          String errorMessage = 'Gagal update data!';
          try {
            final responseBody = response.body;
            if (responseBody != null && responseBody.isNotEmpty) {
              final decoded = jsonDecode(responseBody);
              if (decoded['message'] != null) {
                errorMessage = decoded['message'];
              }
            }
          } catch (_) {}

          print('Error Code: ${response.statusCode}');
          print('Error Message: $errorMessage');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        print('Terjadi kesalahan: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lengkapi Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: kontakDaruratController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Kontak Darurat'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedProvinsi,
                items: DataProvinsi.provinsiList.map((provinsi) {
                  return DropdownMenuItem<String>(
                    value: provinsi,
                    child: Text(provinsi),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProvinsi = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Provinsi'),
                validator: (value) => value == null ? 'Pilih provinsi' : null,
              ),
              TextFormField(
                controller: tanggalLahirController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir (YYYY-MM-DD)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
