import 'package:flutter/material.dart';

// Kelas Nota untuk menyimpan data nota
class Nota {
  String id; // ID unik untuk setiap nota
  DateTime tanggal; // Tanggal nota
  String nama; // Nama pemilik nota
  String typeHp; // Tipe HP
  String kerusakan; // Deskripsi kerusakan
  String kelengkapan; // Kelengkapan yang disertakan
  String noHp; // Nomor HP pemilik
  double harga; // Harga perbaikan

  // Konstruktor untuk inisialisasi objek Nota
  Nota({
    required this.id,
    required this.tanggal,
    required this.nama,
    required this.typeHp,
    required this.kerusakan,
    required this.kelengkapan,
    required this.noHp,
    required this.harga,
  });
}

// Kelas utama untuk menampilkan daftar nota
class NoteCount extends StatefulWidget {
  const NoteCount({super.key});

  @override
  State<NoteCount> createState() => NoteCountState();
}

// State untuk NoteCount
class NoteCountState extends State<NoteCount> {
  List<Nota> notas = []; // Daftar nota yang akan ditampilkan

  // Fungsi untuk menambah atau mengedit nota
  void _addOrEditNote({Nota? nota}) async {
    // Navigasi ke halaman NoteCountPage untuk menambah atau mengedit nota
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteCountPage(nota: nota),
      ),
    );

    // Jika hasil bukan null dan merupakan objek Nota
    if (result != null && result is Nota) {
      setState(() {
        if (nota != null) {
          // Jika nota sudah ada, edit nota yang ada
          final index = notas.indexWhere((n) => n.id == nota.id);
          if (index != -1) {
            notas[index] = result; // Update nota yang ada
          }
        } else {
          // Jika nota baru, tambahkan ke daftar
          notas.add(result);
        }
      });
    } else if (result != null && result == 'delete' && nota != null) {
      // Jika hasil adalah 'delete', hapus nota dari daftar
      setState(() {
        notas.removeWhere((n) => n.id == nota.id);
      });
    }
  }

  // Fungsi untuk memformat tanggal menjadi string
  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota Konter'),
        centerTitle: true,
      ),
      body: notas.isEmpty
          ? const Center(
              child: Text(
                'Belum ada catatan',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notas.length,
              itemBuilder: (context, index) {
                final n = notas[index]; // Ambil nota berdasarkan index
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Text(n.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal: ${formatDate(n.tanggal)}'), // Tampilkan tanggal yang diformat
                        Text('Type HP: ${n.typeHp}'),
                        Text('Kerusakan: ${n.kerusakan}'),
                        Text('Kelengkapan: ${n.kelengkapan}'),
                        Text('No HP: ${n.noHp}'),
                        Text('Harga: Rp ${n.harga.toStringAsFixed(0)}'),
                      ],
                    ),
                    onTap: () => _addOrEditNote(nota: n), // Aksi saat nota ditekan
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(), // Aksi untuk menambah nota baru
        tooltip: 'Tambah Nota',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Kelas untuk halaman tambah/edit nota
class NoteCountPage extends StatefulWidget {
  const NoteCountPage({
    super.key,
    this.nota,
  });

  final Nota? nota; // Jika ada, ini nota yang akan diedit

  @override
  State<NoteCountPage> createState() => _NoteCountPageState();
}

class _NoteCountPageState extends State<NoteCountPage> {
  final _formKey = GlobalKey<FormState>(); // Key untuk form validasi

  late DateTime tanggal; // Variabel tanggal nota
  // Controller untuk setiap input form agar mudah akses dan kontrol
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _typeHpController = TextEditingController();
  final TextEditingController _kerusakanController = TextEditingController();
  final TextEditingController _kelengkapanController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  bool _isEditing = false; // Menandakan apakah sedang edit atau tambah baru

  @override
  void initState() {
    super.initState();
    if (widget.nota != null) {
      // Jika ada nota, artinya form untuk edit
      _isEditing = true;
      tanggal = widget.nota!.tanggal; // Set tanggal dari nota
      _namaController.text = widget.nota!.nama; // Set input dengan data nota
      _typeHpController.text = widget.nota!.typeHp;
      _kerusakanController.text = widget.nota!.kerusakan;
      _kelengkapanController.text = widget.nota!.kelengkapan;
      _noHpController.text = widget.nota!.noHp;
      _hargaController.text = widget.nota!.harga.toStringAsFixed(0);
    } else {
      // Jika tambah nota baru, tanggal default hari ini
      tanggal = DateTime.now();
    }
  }

  @override
  void dispose() {
    // Membersihkan controller ketika widget dibuang
    _namaController.dispose();
    _typeHpController.dispose();
    _kerusakanController.dispose();
    _kelengkapanController.dispose();
    _noHpController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih tanggal menggunakan DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tanggal,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != tanggal) {
      setState(() {
        tanggal = picked; // Update tanggal setelah dipilih
      });
    }
  }

  // Fungsi untuk menyimpan data yang diinputkan
  void _save() {
    if (_formKey.currentState!.validate()) {
      // Jika data valid, buat objek Nota baru
      final newNote = Nota(
        id: _isEditing ? widget.nota!.id : UniqueKey().toString(), // Gunakan id lama jika edit, id baru jika tambah
        tanggal: tanggal,
        nama: _namaController.text.trim(),
        typeHp: _typeHpController.text.trim(),
        kerusakan: _kerusakanController.text.trim(),
        kelengkapan: _kelengkapanController.text.trim(),
        noHp: _noHpController.text.trim(),
        harga: double.tryParse(_hargaController.text.trim()) ?? 0, // parsing harga ke double
      );
      Navigator.of(context).pop(newNote); // Kembali ke halaman sebelumnya bersama data baru
    }
  }

  // Fungsi menampilkan dialog konfirmasi hapus nota
  void _delete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Nota'),
        content: const Text('Apakah Anda yakin ingin menghapus nota ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Batal hapus
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Tutup dialog
              Navigator.of(context).pop('delete'); // Kembali ke halaman sebelumnya dengan sinyal hapus
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Fungsi format tanggal menjadi string DD-MM-YYYY
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Nota' : 'Tambah Nota'), // Judul sesuai mode tambah/edit
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete, // Tombol hapus nota ketika edit
              tooltip: 'Hapus Nota',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Form key untuk validasi
          child: Column(
            children: [
              InkWell(
                onTap: () => _selectDate(context), // Memanggil date picker saat diketuk
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDate(tanggal)), // Tampilkan tanggal yang dipilih
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Nama
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi'; // Validasi wajib isi nama
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Input Type HP
              TextFormField(
                controller: _typeHpController,
                decoration: const InputDecoration(
                  labelText: 'Type HP',
                  prefixIcon: Icon(Icons.phone_android),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Type HP wajib diisi'; // Validasi wajib isi type HP
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Input Kerusakan
              TextFormField(
                controller: _kerusakanController,
                decoration: const InputDecoration(
                  labelText: 'Kerusakan',
                  prefixIcon: Icon(Icons.build),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kerusakan wajib diisi'; // Validasi wajib isi kerusakan
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Input Kelengkapan
              TextFormField(
                controller: _kelengkapanController,
                decoration: const InputDecoration(
                  labelText: 'Kelengkapan',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kelengkapan wajib diisi'; // Validasi wajib isi kelengkapan
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Input No HP
              TextFormField(
                controller: _noHpController,
                keyboardType: TextInputType.phone, // Keyboard khusus input nomor telepon
                decoration: const InputDecoration(
                  labelText: 'No HP',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'No HP wajib diisi'; // Validasi wajib isi nomor HP
                  }
                  final phoneExp = RegExp(r'^\+?\d{6,15}$'); // Regex nomor HP: optional +, 6-15 digit
                  if (!phoneExp.hasMatch(value.trim())) {
                    return 'Masukkan nomor HP yang valid'; // Validasi format nomor HP
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Input Harga
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number, // Keyboard angka
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga wajib diisi'; // Validasi wajib isi harga
                  }
                  final n = double.tryParse(value.trim());
                  if (n == null || n < 0) {
                    return 'Masukkan harga yang valid'; // Validasi harga minimal 0 dan harus angka
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _save, // Panggil fungsi save ketika ditekan
                icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48), // Tombol lebar penuh
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}