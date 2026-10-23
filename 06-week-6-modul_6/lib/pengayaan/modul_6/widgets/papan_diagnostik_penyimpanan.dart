import 'package:flutter/material.dart';
import 'package:modul_6/pengayaan/modul_6/repositories/sesi_repository.dart';

class PapanDiagnostikPenyimpanan extends StatefulWidget {
  const PapanDiagnostikPenyimpanan({super.key, required this.repository});

  final SesiRepository repository;

  @override
  State<PapanDiagnostikPenyimpanan> createState() =>
      _PapanDiagnostikPenyimpananState();
}

class _PapanDiagnostikPenyimpananState
    extends State<PapanDiagnostikPenyimpanan> {
  bool _sedangMengintip = false;
  bool _sudahMengintip = false;
  String? _hasilIntip;

  Future<void> _intip() async {
    setState(() => _sedangMengintip = true);
    final String? hasil = await widget.repository.intipMentah();
    if (!mounted) return;
    setState(() {
      _hasilIntip = hasil;
      _sudahMengintip = true;
      _sedangMengintip = false;
    });
  }

  @override
  void didUpdateWidget(covariant PapanDiagnostikPenyimpanan oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ganti penyimpaanan -> hasil lama tidak berlaku lagi.
    if (oldWidget.repository != widget.repository) {
      _sudahMengintip = false;
      _hasilIntip = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Papan Diagnostik: ${widget.repository.nama}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(widget.repository.keterangan),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _sedangMengintip ? null : _intip,
              icon: _sedangMengintip
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.visibility_outlined),
              label: Text(
                _sedangMengintip ? 'Mengintip…' : 'Intip isi penyimpanan',
              ),
            ),
            if (_sudahMengintip) ...<Widget>[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: warna.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _hasilIntip ?? 'null',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}