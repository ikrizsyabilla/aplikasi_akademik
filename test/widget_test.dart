import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_akademik/main.dart';

void main() {
  testWidgets('Alur Input -> Daftar -> Detail berjalan utuh', (tester) async {
    await tester.pumpWidget(const MyApp());

    // 1. Pastikan awalnya ada 2 mahasiswa
    expect(find.textContaining('Daftar Mahasiswa (2 orang)'), findsOneWidget);

    // 2. Ketuk tombol Tambah untuk membuka form
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // 3. Isi 4 kolom dengan data valid
    await tester.enterText(find.byType(TextFormField).at(0), 'Citra Dewi');
    await tester.enterText(find.byType(TextFormField).at(1), '2023099');
    await tester.enterText(find.byType(TextFormField).at(2), 'citra@kampus.ac.id');
    await tester.enterText(find.byType(TextFormField).at(3), '5');

    // 4. Tekan Simpan dan tunggu kembali ke Dashboard
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // 5. Pastikan jumlah menjadi 3 orang dan Citra Dewi muncul di daftar
    expect(find.textContaining('Daftar Mahasiswa (3 orang)'), findsOneWidget);
    expect(find.text('Citra Dewi'), findsOneWidget);

    // 6. Ketuk kartu Citra Dewi dan pastikan halaman Detail menampilkan datanya
    await tester.tap(find.text('Citra Dewi'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Mahasiswa'), findsOneWidget);
    expect(find.text('2023099'), findsOneWidget);
    expect(find.text('citra@kampus.ac.id'), findsOneWidget);
  });
}