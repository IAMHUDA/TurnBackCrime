import 'package:flutter/material.dart';
import '../../../services/service_http_client.dart';
import '../../../core/utils/validator_register.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final httpClient = ServiceHttpClient();
        final response = await httpClient.post('/auth/register', {
          'nama': namaController.text,
          'email': emailController.text,
          'nomer_handphone': noHpController.text,
          'password': passwordController.text,
        });

        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registrasi gagal! ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama'),
                validator: RegisterValidator.validateName,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: RegisterValidator.validateName,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: noHpController,
                decoration: InputDecoration(labelText: 'No HP'),
                validator: RegisterValidator.validateName,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: RegisterValidator.validateName,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _register,
                child:
                    isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
