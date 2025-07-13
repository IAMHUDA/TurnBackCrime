import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SOSEmailService {
  Future<void> kirimEmailSOS({
    required String nama,
    required String emailTujuan,
    required double lat,
    required double long,
  }) async {
    final smtpServer = SmtpServer(
      'sandbox.smtp.mailtrap.io',
      port: 2525,
      username: 'c46921ef999f2e', // Ganti dengan user Mailtrap
      password: '92ab2fc199620f', // Ganti dengan password Mailtrap
    );

    final message = Message()
      ..from = Address('sos@app.com', 'TurnBackCrime App')
      ..recipients.add(emailTujuan)
      ..subject = '🔴 SOS Alert dari $nama'
      ..text = '''
Pesan Darurat dari $nama

Lokasi: https://maps.google.com/?q=$lat,$long
Waktu: ${DateTime.now()}

Mohon segera bantu!
''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Pesan terkirim: ' + sendReport.toString());
    } catch (e) {
      print('Gagal mengirim email: $e');
      rethrow;
    }
  }
}
