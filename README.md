# CleanBee

CleanBee adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu mahasiswa dalam mengelola layanan kebersihan di lingkungan asrama. Aplikasi ini memanfaatkan Firebase sebagai Backend-as-a-Service untuk menyediakan fitur real-time, autentikasi, dan penyimpanan data secara efisien.

## Fitur Utama

- **Autentikasi Pengguna**
  - Registrasi dan login menggunakan Firebase Authentication
  - Manajemen sesi pengguna
 
- **Pemesanan Layanan**
  - Pemesanan layanan kebersihan (kamar / kamar mandi)
  - Penjadwalan layanan
  - Status pemesanan (pending, proses, selesai)

- **Chat dan Customer Service**
  - Komunikasi real-time antara mahasiswa dan petugas
  - Layanan bantuan untuk menangani kendala pengguna

- **Notifikasi**
  - Notifikasi otomatis untuk konfirmasi pesanan
  - Pengingat jadwal
  - Pembaruan status layanan

- **Ulasan Pengguna**
  - Pemberian rating (1–5)
  - Penulisan komentar
  - Evaluasi kualitas layanan

- **Manajemen Role**
  - Mahasiswa
  - Petugas
  - Admin

 ## Arsitektur Sistem

CleanBee menggunakan arsitektur berbasis Backend-as-a-Service:

```plaintext
Flutter App → Firebase
```

## Teknologi yang Digunakan

### Komponen - Teknologi
- Mobile App -	Flutter (Dart)
- Backend Service -	Firebase
- Database	- Cloud Firestore
- Authentication	- Firebase Authentication
- Notifikasi	- Firebase Cloud Messaging
- Storage	- Firebase Storage


## Persyaratan Sistem

  - Flutter SDK versi 3.x atau lebih baru
  - Dart versi 3.x atau lebih baru
  - Android Studio atau Visual Studio Code
  - Akun Firebase

## Instalasi
### 1. Clone Repository
```bash
git clone https://github.com/revanzayyan/cleanbee.git
cd cleanbee
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Firebase
Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```
Login ke Firebase:
```bash
firebase login
```
Konfigurasi project:
```bash
flutterfire configure
```

### 4. Jalankan Aplikasi
```bash
flutter run
```

## Struktur Project
```
lib/
├── models/
├── services/
├── screens/
├── widgets/
├── utils/
└── main.dart
```

## Database Schema (Firestore)
  ### Collection: users
    userId
    - name
    - email
    - role (mahasiswa / petugas / admin)
    
  ### Collection: orders
    orderId
    - userId
    - type
    - schedule
    - status

  ### Collection: reviews
      reviewId
      - userId
      - rating
      - comment
      - createdAt

## User Flow
  1. Pengguna melakukan login atau registrasi
  2. Pengguna memilih layanan kebersihan
  3. Pengguna menentukan jadwal layanan
  4. Sistem menyimpan data ke Firestore
  5. Petugas menerima tugas
  6. Pengguna memberikan ulasan setelah layanan selesai
  7. Notifikasi

## Menggunakan Firebase Cloud Messaging untuk:
  - Pengingat jadwal
  - Pembaruan status pesanan
  - Informasi layanan
  - Testing
  - flutter test
  - Development
  - flutter run
