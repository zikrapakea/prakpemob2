import 'package:flutter/material.dart';

const noteCategories = ['Pribadi', 'Kuliah', 'Kerja', 'Ide'];

const noteColors = [
  Color(0xFFFFFFFF), // putih
  Color(0xFFFFF3B0), // kuning
  Color(0xFFFFD6D6), // merah muda
  Color(0xFFD6EBFF), // biru
  Color(0xFFD8F5D0), // hijau
  Color(0xFFE8DAFF), // ungu
];

Color noteColor(int index) =>
    noteColors[index.clamp(0, noteColors.length - 1)];

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Mengubah teks ISO-8601 menjadi "22 Okt 2026, 14:05".
String formatTanggal(String? iso) {
  if (iso == null) return '-';
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return '-';
  final jam = d.hour.toString().padLeft(2, '0');
  final menit = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${_bulan[d.month - 1]} ${d.year}, $jam:$menit';
}
