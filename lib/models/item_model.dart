import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String kodeBarang;
  final String namaBarang;
  final String kategori;
  final int jumlahStok;
  final DateTime tanggalMasuk;
  final String? deskripsi;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemModel({
    required this.id,
    required this.kodeBarang,
    required this.namaBarang,
    required this.kategori,
    required this.jumlahStok,
    required this.tanggalMasuk,
    this.deskripsi,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemModel.fromMap(Map<String, dynamic> data, String id) {
    return ItemModel(
      id: id,
      kodeBarang: data['kodeBarang'] ?? '',
      namaBarang: data['namaBarang'] ?? '',
      kategori: data['kategori'] ?? '',
      jumlahStok: data['jumlahStok'] ?? 0,
      tanggalMasuk: (data['tanggalMasuk'] as Timestamp).toDate(),
      deskripsi: data['deskripsi'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kodeBarang': kodeBarang,
      'namaBarang': namaBarang,
      'kategori': kategori,
      'jumlahStok': jumlahStok,
      'tanggalMasuk': tanggalMasuk,
      'deskripsi': deskripsi,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
