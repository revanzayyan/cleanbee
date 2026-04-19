class UserModel {
  final String uid;
  final String email;
  final String nama;
  final String? nomorKamar;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    this.nomorKamar,
    this.role = 'penghuni',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nama: map['nama'] ?? '',
      nomorKamar: map['nomor_kamar'],
      role: map['role'] ?? 'penghuni',
      createdAt: map['created_at']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nama': nama,
      'nomor_kamar': nomorKamar,
      'role': role,
      'created_at': createdAt,
    };
  }
}