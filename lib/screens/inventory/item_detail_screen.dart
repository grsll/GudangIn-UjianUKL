import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/item_model.dart'; // Add this import

class ItemDetailScreen extends StatelessWidget {
  final ItemModel item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
    );
    final dateFormatter = DateFormat('dd MMMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Barang')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 80,
                      color: Colors.blueAccent.withAlpha(200),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.namaBarang,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kode: ${item.kodeBarang}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              title: 'Informasi Utama',
              children: [
                _buildDetailRow('Kategori', item.kategori),
                _buildDetailRow('Harga', currencyFormatter.format(item.harga)),
                _buildDetailRow('Stok', '${item.jumlahStok} unit'),
                _buildDetailRow(
                  'Tanggal Masuk',
                  dateFormatter.format(item.tanggalMasuk),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (item.deskripsi != null && item.deskripsi!.isNotEmpty)
              _buildDetailCard(
                title: 'Deskripsi',
                children: [
                  Text(item.deskripsi!, style: const TextStyle(height: 1.5)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
