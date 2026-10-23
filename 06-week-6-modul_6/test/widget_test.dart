import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modul_6/modul_06/modul_06_app.dart';
import 'package:modul_6/modul_06/services/auth_api.dart';

void main() {
  testWidgets('Login demo berhasil lalu keluar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Modul06App(api: AuthApi(tunda: Duration.zero)),
    );
    await tester.pumpAndSettle();

    // Keadaan awal: form login tampil.
    expect(find.text('Masuk'), findsOneWidget);

    // Isi kredensial demo.
    await tester.enterText(
      find.byType(TextFormField).first,
      AuthApi.emailDemo,
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      AuthApi.sandiDemo,
    );

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    // Sesudah login: beranda tampil.
    expect(find.text('Beranda'), findsOneWidget);
  });
}
