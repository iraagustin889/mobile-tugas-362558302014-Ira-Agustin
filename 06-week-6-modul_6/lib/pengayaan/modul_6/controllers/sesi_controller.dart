import 'package:flutter/foundation.dart';
import 'package:modul_6/modul_06/models/sesi_pengguna.dart';
import 'package:modul_6/modul_06/services/auth_api.dart';
import 'package:modul_6/pengayaan/modul_6/repositories/sesi_repository.dart';

enum StatusSesi { memeriksa, keluar, memproses, masuk, gagal, kedaluwarsa }

class SesiController extends ChangeNotifier {
  SesiController({
    required this.repository,
    required this.api,
    DateTime Function()? jam,
  }) : jam = jam ?? DateTime.now;

  final SesiRepository repository;
  final AuthApi api;
  final DateTime Function() jam;

  StatusSesi _status = StatusSesi.memeriksa;
  SesiPengguna? _sesi;
  String? _pesan;

  StatusSesi get status => _status;
  SesiPengguna? get sesi => _sesi;
  String? get pesan => _pesan;

  void _ubah(
    StatusSesi status, {
    SesiPengguna? sesi,
    String? pesan,
    bool bersihkanPesan = false,
  }) {
    _status = status;
    _sesi = sesi;
    _pesan = bersihkanPesan ? null : pesan;
    notifyListeners();
  }

  Future<void> pulihkan() async {
    _ubah(StatusSesi.memeriksa, bersihkanPesan: true);

    final SesiPengguna? tersimpan = await repository.baca();
    if (tersimpan == null) {
      _ubah(StatusSesi.keluar, sesi: null);
      return;
    }

    if (tersimpan.sudahKedaluwarsa(jam())) {
      await repository.hapus(); // Sesi mati dibuang, bukan dibiarkan.
      _ubah(
        StatusSesi.kedaluwarsa,
        sesi: null,
        pesan: 'Sesi Anda sudah berakhir. Silakan masuk kembali.',
      );
      return;
    }

    _ubah(StatusSesi.masuk, sesi: tersimpan);
  }

  Future<void> masuk({required String email, required String sandi}) async {
    if (_status == StatusSesi.memproses) return; // Cegah kirim ganda.
    _ubah(StatusSesi.memproses, bersihkanPesan: true);

    try {
      final SesiPengguna hasil = await api.masuk(email: email, sandi: sandi);
      await repository.simpan(hasil);
      _ubah(StatusSesi.masuk, sesi: hasil);
    } on AuthException catch (e) {
      _ubah(StatusSesi.gagal, pesan: e.pesan);
    } catch (e) {
      debugPrint('Login gagal tak terduga: $e');
      _ubah(
        StatusSesi.gagal,
        pesan: 'Terjadi kesalahan tak terduga. Coba lagi.',
      );
    }
  }

  Future<void> keluar() async {
    await repository.hapus();
    _ubah(StatusSesi.keluar, sesi: null); // Bukan gagal.
  }

  Future<void> perbaruiSesi({
    Duration masaBerlaku = const Duration(hours: 2),
  }) async {
    final SesiPengguna? sekarang = _sesi;
    if (sekarang == null) return;

    if (sekarang.sudahKedaluwarsa(jam())) {
      await repository.hapus();
      _ubah(
        StatusSesi.kedaluwarsa,
        sesi: null,
        pesan: 'Sesi sudah berakhir dan tidak dapat diperbarui.',
      );
      return;
    }

    final SesiPengguna baru =
        await api.perbaruiSesi(sekarang, masaBerlaku: masaBerlaku);
    await repository.simpan(baru);
    _ubah(StatusSesi.masuk, sesi: baru);
  }
}
