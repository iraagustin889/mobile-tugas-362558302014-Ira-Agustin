import 'package:modul_6/modul_06/models/sesi_pengguna.dart';

class SesiMemori {
  SesiPengguna? _sesi;
  int jumlahPenulisan = 0; // Dipakai pengujian.

  SesiPengguna? baca() => _sesi;
  bool get adaSesi => _sesi != null;

  Future<void> simpan(SesiPengguna sesi) async {
    _sesi = sesi;
    jumlahPenulisan++;
  }

  Future<void> hapus() async { _sesi = null; }
}
