import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/sos_bloc.dart';

class SOSPage extends StatelessWidget {
  final int idPengguna;
  final String nama;
  final String emailTujuan;

  const SOSPage({
    super.key,
    required this.idPengguna,
    required this.nama,
    required this.emailTujuan,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SOSBloc, SOSState>(
      listener: (context, state) {
        if (state is SOSBerhasil) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('SOS berhasil dikirim via email')),
          );
        } else if (state is SOSGagal) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.red, size: 100),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<SOSBloc>().add(
                        AktifkanSOS(
                          idPengguna: idPengguna,
                          nama: nama,
                          emailTujuan: emailTujuan,
                        ),
                      );
                },
                child: state is SOSLoading
                    ? CircularProgressIndicator()
                    : Text("KIRIM SOS"),
              ),
            ],
          ),
        );
      },
    );
  }
}
