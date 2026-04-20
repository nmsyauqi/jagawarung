/// Model data pegawai warung.
class Pegawai {
  final String id;
  final String nama;
  final String peran; // 'pemilik' atau 'kasir'
  final String inisial;

  const Pegawai({
    required this.id,
    required this.nama,
    required this.peran,
    required this.inisial,
  });

  bool get isPemilik => peran == 'pemilik';
}
