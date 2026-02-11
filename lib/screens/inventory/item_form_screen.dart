import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date picking usage if needed, but we use strict parsing
import '../../models/item_model.dart';
import '../../providers/inventory_provider.dart';

class ItemFormScreen extends StatefulWidget {
  final ItemModel? item;

  const ItemFormScreen({super.key, this.item});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _kodeController;
  late TextEditingController _namaController;
  late TextEditingController _kategoriController;
  late TextEditingController _stokController;
  late TextEditingController _deskripsiController;
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _kodeController = TextEditingController(
      text: widget.item?.kodeBarang ?? '',
    );
    _namaController = TextEditingController(
      text: widget.item?.namaBarang ?? '',
    );
    _kategoriController = TextEditingController(
      text: widget.item?.kategori ?? '',
    );
    _stokController = TextEditingController(
      text: widget.item?.jumlahStok.toString() ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.item?.deskripsi ?? '',
    );
    if (widget.item != null) {
      _selectedDate = widget.item!.tanggalMasuk;
    }
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    _kategoriController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final newItem = ItemModel(
          id:
              widget.item?.id ??
              '', // ID handled by service/model logic usually
          kodeBarang: _kodeController.text.trim(),
          namaBarang: _namaController.text.trim(),
          kategori: _kategoriController.text.trim(),
          jumlahStok: int.parse(_stokController.text.trim()),
          tanggalMasuk: _selectedDate,
          deskripsi: _deskripsiController.text.trim(),
          createdAt: widget.item?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final provider = Provider.of<InventoryProvider>(context, listen: false);

        if (widget.item != null) {
          await provider.updateItem(newItem);
        } else {
          await provider.addItem(newItem);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Barang' : 'Tambah Barang')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _kodeController,
                decoration: const InputDecoration(labelText: 'Kode Barang'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kategoriController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stokController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Stok',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Tanggal Masuk'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? 'Simpan Perubahan' : 'Tambah Barang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
