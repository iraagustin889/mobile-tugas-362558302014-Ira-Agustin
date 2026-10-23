import 'package:flutter/material.dart';
import '../models/sesi_pengguna.dart';

class KartuSesi extends StatelessWidget {
  final SesiPengguna sesi;

  /// Waktu acuan untuk menghitung sisa masa berlaku.
  final DateTime sekarang;

  final VoidCallback? onKeluar;
  final bool sedangKeluar;

  /// Menampilkan token apa adanya. Default `false`.
  final bool tampilkanToken;

  const KartuSesi({
    super.key,
    required this.sesi,
    required this.sekarang,
    this.onKeluar,
    this.sedangKeluar = false,
    this.tampilkanToken = false,
  });

  /// Menyamarkan token: hanya 6 karakter awal yang terlihat.
  static String samarkanToken(String token) {
    if (token.isEmpty) return '(kosong)';
    if (token.length <= 6) return _titik(token.length);
    return '${token.substring(0, 6)}${_titik(12)}';
  }

  static String _titik(int jumlah) =>
      List<String>.filled(jumlah, '\u2022').join();

  /// Mengubah `2026-09-21T10:15:00.000` menjadi `21 Sep 2026, 10:15`.
  static String formatWaktu(String iso) {
    const List<String> bulan = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final DateTime? waktu = DateTime.tryParse(iso);
    if (waktu == null) return 'tidak diketahui';
    final String jam = waktu.hour.toString().padLeft(2, '0');
    final String menit = waktu.minute.toString().padLeft(2, '0');
    return '${waktu.day} ${bulan[waktu.month - 1]}${waktu.year}, $jam:$menit';
  }

  /// Mengubah Duration menjadi `1 jam 5 menit` / `45 detik`.
  static String formatSisa(Duration sisa) {
    if (sisa.inSeconds <= 0) return 'sudah berakhir';
    if (sisa.inMinutes < 1) return '${sisa.inSeconds} detik';
    if (sisa.inHours < 1) return '${sisa.inMinutes} menit';
    final int menit = sisa.inMinutes.remainder(60);
    return menit == 0
        ? '${sisa.inHours} jam'
        : '${sisa.inHours} jam$menit menit';
  }

  @override
  Widget build(BuildContext context) {
    final Duration sisa = sesi.sisaWaktu(sekarang);
    final String tokenTampil =
        tampilkanToken ? sesi.token : samarkanToken(sesi.token);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    sesi.nama.isNotEmpty ? sesi.nama[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        sesi.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        sesi.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(SesiPengguna.labelPeran(sesi.peran)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            _ItemInfo(
              label: 'Waktu Masuk',
              nilai: formatWaktu(sesi.masukPada),
              ikon: Icons.login_rounded,
            ),
            const SizedBox(height: 8),
            _ItemInfo(
              label: 'Kedaluwarsa',
              nilai: formatWaktu(sesi.kedaluwarsaPada),
              ikon: Icons.timer_outlined,
            ),
            const SizedBox(height: 8),
            _ItemInfo(
              label: 'Sisa Masa Berlaku',
              nilai: formatSisa(sisa),
              ikon: Icons.hourglass_bottom_rounded,
            ),
            const SizedBox(height: 8),
            _ItemInfo(
              label: 'Token',
              nilai: tokenTampil,
              ikon: Icons.key_rounded,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: sedangKeluar ? null : onKeluar,
                icon: sedangKeluar
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout_rounded),
                label: Text(sedangKeluar ? 'Sedang keluar…' : 'Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemInfo extends StatelessWidget {
  final String label;
  final String nilai;
  final IconData ikon;

  const _ItemInfo({
    required this.label,
    required this.nilai,
    required this.ikon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(ikon, size: 16, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Expanded(
          child: Text(
            nilai,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
