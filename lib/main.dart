import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Akademik Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const DashboardPage(),
    );
  }
}

// ===================== 1. HALAMAN DASHBOARD (STATEFUL) =====================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Daftar disimpan di State (bukan const) agar bisa ditambah dari form
  final List<Map<String, String>> _daftarMahasiswa = [
    {
      'nama': 'Rina Amelia',
      'nim': '2023001',
      'prodi': 'Sistem Informasi',
      'semester': '5',
      'email': 'rina@contoh.ac.id',
    },
    {
      'nama': 'Budi Santoso',
      'nim': '2023002',
      'prodi': 'Sistem Informasi',
      'semester': '5',
      'email': 'budi@contoh.ac.id',
    },
  ];

  Future<void> _bukaFormTambah() async {
    final mahasiswaBaru = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const TambahMahasiswaPage()),
    );

    if (mahasiswaBaru != null) {
      setState(() {
        _daftarMahasiswa.add(mahasiswaBaru);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data ${mahasiswaBaru['nama']} berhasil ditambahkan.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Akademik'),
        backgroundColor: warna.primaryContainer,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormTambah,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil Saya'),
              subtitle: const Text('Identitas dan keahlian'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Daftar Mahasiswa (${_daftarMahasiswa.length} orang)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final mhs in _daftarMahasiswa)
            KartuMahasiswa(
              mahasiswa: mhs,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailMahasiswaPage(mahasiswa: mhs),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ===================== 2. ATURAN VALIDASI & FORM INPUT =====================
String? validasiNama(String? nilai) {
  final teks = nilai?.trim() ?? '';
  if (teks.isEmpty) return 'Nama wajib diisi';
  if (teks.length < 3) return 'Nama minimal 3 huruf';
  return null;
}

String? validasiNim(String? nilai) {
  final teks = nilai?.trim() ?? '';
  if (teks.isEmpty) return 'NIM wajib diisi';
  if (!RegExp(r'^[0-9]+$').hasMatch(teks)) {
    return 'NIM hanya boleh berisi angka';
  }
  if (teks.length < 7) return 'NIM minimal 7 digit';
  return null;
}

String? validasiEmail(String? nilai) {
  final teks = nilai?.trim() ?? '';
  if (teks.isEmpty) return 'Email wajib diisi';
  final pola = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  if (!pola.hasMatch(teks)) {
    return 'Format email tidak valid (contoh: nama@kampus.ac.id)';
  }
  return null;
}

String? validasiSemester(String? nilai) {
  final teks = nilai?.trim() ?? '';
  if (teks.isEmpty) return 'Semester wajib diisi';
  final angka = int.tryParse(teks);
  if (angka == null) return 'Semester harus berupa angka';
  if (angka < 1 || angka > 14) return 'Semester harus antara 1 dan 14';
  return null;
}

class TambahMahasiswaPage extends StatefulWidget {
  const TambahMahasiswaPage({super.key});

  @override
  State<TambahMahasiswaPage> createState() => _TambahMahasiswaPageState();
}

class _TambahMahasiswaPageState extends State<TambahMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _semesterController = TextEditingController();
  final _namaFocus = FocusNode();

  AutovalidateMode _modeValidasi = AutovalidateMode.disabled;

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _semesterController.dispose();
    _namaFocus.dispose();
    super.dispose();
  }

  void _simpan() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final dataBaru = <String, String>{
        'nama': _namaController.text.trim(),
        'nim': _nimController.text.trim(),
        'prodi': 'Sistem Informasi',
        'semester': _semesterController.text.trim(),
        'email': _emailController.text.trim(),
      };
      Navigator.pop(context, dataBaru);
    } else {
      setState(() {
        _modeValidasi = AutovalidateMode.onUserInteraction;
      });
    }
  }

  void _kosongkan() {
    _formKey.currentState!.reset();
    _namaController.clear();
    _nimController.clear();
    _emailController.clear();
    _semesterController.clear();
    setState(() {
      _modeValidasi = AutovalidateMode.disabled;
    });
    _namaFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Mahasiswa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: _modeValidasi,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                focusNode: _namaFocus,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: validasiNama,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nimController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 12,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: validasiNim,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: validasiEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _semesterController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 2,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                validator: validasiSemester,
                onFieldSubmitted: (_) => _simpan(),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _kosongkan,
                icon: const Icon(Icons.refresh),
                label: const Text('Kosongkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== 3. HALAMAN DETAIL & PROFIL =====================
class DetailMahasiswaPage extends StatelessWidget {
  const DetailMahasiswaPage({super.key, required this.mahasiswa});

  final Map<String, String> mahasiswa;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BarisInfo(label: 'Nama', nilai: mahasiswa['nama'] ?? '-'),
            BarisInfo(label: 'NIM', nilai: mahasiswa['nim'] ?? '-'),
            BarisInfo(label: 'Program Studi', nilai: mahasiswa['prodi'] ?? '-'),
            BarisInfo(label: 'Semester', nilai: mahasiswa['semester'] ?? '-'),
            BarisInfo(label: 'Email', nilai: mahasiswa['email'] ?? '-'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali ke Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BarisInfo(label: 'Nama', nilai: 'Rina Amelia'),
            BarisInfo(label: 'NIM', nilai: '2023001'),
            BarisInfo(label: 'Program Studi', nilai: 'Sistem Informasi'),
          ],
        ),
      ),
    );
  }
}

// ===================== 4. WIDGET TERPISAH (REFACTORING) =====================
class KartuMahasiswa extends StatelessWidget {
  const KartuMahasiswa({
    super.key,
    required this.mahasiswa,
    required this.onTap,
  });

  final Map<String, String> mahasiswa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nama = mahasiswa['nama'] ?? '?';
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(nama[0].toUpperCase())),
        title: Text(nama),
        subtitle: Text('NIM ${mahasiswa['nim']} · Semester ${mahasiswa['semester']}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class BarisInfo extends StatelessWidget {
  const BarisInfo({super.key, required this.label, required this.nilai});

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Text(': '),
          Expanded(child: Text(nilai)),
        ],
      ),
    );
  }
}