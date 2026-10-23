import 'package:flutter/material.dart';
import 'package:modul_6/modul_06/models/sesi_pengguna.dart';
import 'package:modul_6/pengayaan/modul_6/controllers/sesi_controller.dart';

class GerbangSesi extends StatelessWidget {
  const GerbangSesi({
    super.key,
    required this.controller,
    required this.form,
    required this.beranda,
  });

  final SesiController controller;
  final WidgetBuilder form;
  final Widget Function(BuildContext context, SesiPengguna sesi) beranda;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? _) {
        switch (controller.status) {
          case StatusSesi.memeriksa:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memeriksa sesi tersimpan…'),
                  ],
                ),
              ),
            );
          case StatusSesi.masuk:
            final SesiPengguna? sesi = controller.sesi;
            if (sesi == null) return form(context);
            return beranda(context, sesi);
          case StatusSesi.keluar:
          case StatusSesi.memproses:
          case StatusSesi.gagal:
          case StatusSesi.kedaluwarsa:
            return form(context);
        }
      },
    );
  }
}
