import 'dart:convert';

import 'package:modul_6/modul_06/models/sesi_pengguna.dart';
import 'package:modul_6/pengayaan/modul_6/repositories/sesi_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsSesiRepository implements SesiRepository {
  PrefsSesiRepository({Future<SharedPreferences>? prefs})
      : _prefs = prefs ?? SharedPreferences.getInstance();

  static const String kunciSesi = 'modul_06_sesi_pengguna';

  final Future<SharedPreferences> _prefs;

  @override
  String get nama => 'Prefs';

  @override
  String get keterangan =>
      'SharedPreferences: bertahan, tetapi token tersimpan apa adanya.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final SharedPreferences prefs = await _prefs;
    final String? mentah = prefs.getString(kunciSesi);
    if (mentah == null) return null;
    try {
      return SesiPengguna.fromJson(
        jsonDecode(mentah) as Map<String, dynamic>,
      );
    } on FormatException {
      await prefs.remove(kunciSesi); // Data rusak dibuang.
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(kunciSesi, jsonEncode(sesi.toJson()));
  }

  @override
  Future<void> hapus() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.containsKey(kunciSesi);
  }

  @override
  Future<String?> intipMentah() async {
    final SharedPreferences prefs = await _prefs;
    // Demonstrasi ini memperlihatkan bahwa adapter preferensi dapat
    // mengembalikan nilai token melalui API biasa.
    return prefs.getString(kunciSesi);
  }
}