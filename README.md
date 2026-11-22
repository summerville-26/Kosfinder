# KosFinder

Aplikasi pencarian dan pengelolaan tempat kos modern berbasis mobile (Android) dan Web yang dibangun menggunakan **Flutter**, **Provider** (pola MVVM / Clean Architecture), dan **Supabase** (PostgreSQL & Supabase Auth dengan Row Level Security).

---

## Identitas Pengembang
* **NIM**  : `2415051085`
* **Nama** : `I Komang Candra Aryadinata`

---

## Deskripsi Aplikasi
**KosFinder** dirancang untuk mengatasi permasalahan informasi kos yang tersebar tidak terstruktur serta sulitnya membandingkan harga dan ketersediaan kamar. Aplikasi menyediakan pengalaman pencarian hunian kos yang cepat, transparan, dan terpercaya bagi mahasiswa maupun masyarakat umum, sekaligus memberikan alat manajemen properti yang praktis dan terlindungi secara aman bagi pemilik kos.

---

## Fitur Utama (Versi 0.1.0)

### 1. Eksplorasi Publik (Tanpa Login / Guest Mode)
* Menjelajah katalog kos di halaman beranda tanpa hambatan login.
* Membuka rincian detail kos lengkap: nama kos, area, alamat lengkap, harga sewa per bulan, total kamar, sisa kamar tersedia, daftar fasilitas pendukung berikon, dan nomor kontak pemilik.
* Gambar visual hunian berdesain gradien modern lokal bawaan aplikasi.

### 2. Pencarian Cepat & Filter Fleksibel
* Pencarian teks *real-time* berdasarkan nama kos maupun nama area/kampus terdekat (misal: "Dago").
* Penyaringan harga melalui filter chip kategori cepat (`< 1 Juta`, `1 - 2 Juta`, `> 2 Juta`) serta bottom sheet rentang harga sewa per bulan.
* Tampilan status kosong (*Empty State*) informatif dengan tombol reset pencarian (*"Hapus Filter"*).

### 3. Indikator Ketersediaan Kamar & Status "Penuh"
* Badge status ketersediaan kamar adaptif:
  * Menampilkan **"Sisa X kamar"** berwarna hijau jika kamar masih tersedia.
  * Menampilkan label/badge tegas berwarna merah bertuliskan **"Penuh"** jika sisa kamar = 0.
* Kos yang berstatus penuh tetap dapat ditemukan dan dilihat di pencarian publik (tidak disembunyikan).

### 4. Autentikasi Pemilik Kos yang Aman
* Registrasi akun pemilik baru dan login menggunakan email & kata sandi terenkripsi melalui Supabase Auth.
* Sesi login tersimpan secara lokal dan otomatis memvalidasi hak akses pengelolaan.

### 5. Dashboard Pengelolaan Kos (Owner Dashboard)
* Ringkasan statistik 3 metrik properti: **Total Kos**, **Kamar Sisa**, dan **Kos Penuh**.
* Daftar kos milik sendiri (*"Kos Saya"*) dalam bentuk kartu modern.
* Formulir **Tambah Kos Baru** terstruktur (Informasi Properti, Lokasi, Tarif & Kamar, Fasilitas, Kontak).
* Fitur **Ubah Data Kos** untuk memperbarui tarif, fasilitas, maupun alamat.
* Fitur **Hapus Kos Permanen** (*hard delete*) terlindungi dialog konfirmasi untuk mencegah ketidaksengajaan.

### 6. Pembaruan Cepat Sisa Kamar (Quick Room Update)
* Stepper kontrol langsung (`[-]` dan `[+]`) serta tombol aksi cepat **"Set Penuh"** dan **"Buka 1 Kamar"** pada dashboard pemilik tanpa harus membuka form edit penuh.

### 7. Tema & Desain Modern Green & White
* Palet warna konsisten: Hijau Emerald (`#059669`), Putih, dan Latar Off-White lembut (`#F8FAFC`).
* Komponen kartu bersudut membulat (16–20px) dengan bayangan lembut (*soft elevation*) dan tipografi hierarkis yang mudah dibaca.

---

## Batasan Versi 1 (Out-of-Scope)

Sesuai dokumen spesifikasi kebutuhan produk (PRD), fitur-fitur berikut **tidak termasuk** dalam ruang lingkup rilis Versi 1:
1. **Pembayaran Sewa Online**: Tidak menyediakan integrasi *payment gateway* (transaksi sewa dilakukan langsung antara pencari dan pemilik kos).
2. **Chat / Pesan Instan di Aplikasi**: Komunikasi dilakukan via kontak telepon/WhatsApp pemilik yang tertera di halaman detail.
3. **Ulasan & Penilaian (*Review & Rating*)**: Belum menyediakan sistem pemberian bintang atau komentar publik.
4. **Unggah Foto Berkas ke Cloud Storage**: Murni menggunakan aset visual placeholder lokal yang ringan dan konsisten (bebas dari dependensi API pihak ketiga).
5. **Peta Digital Interaktif (Google Maps API)**: Alamat kos disajikan dalam format teks lengkap terstruktur.
6. **Manajemen Tagihan Finansial**: Tidak mencatat pembukuan keuangan bulanan atau daftar nama penghuni kos.

---

## Arsitektur & Keamanan

* **Pola Arsitektur**: `Screen (UI) → Provider (State Management) → Repository (Akses Data) → Supabase (Backend)`.
* **Row Level Security (RLS)**: 100% operasi modifikasi data (`INSERT`, `UPDATE`, `DELETE`) dilindungi oleh kebijakan RLS database PostgreSQL Supabase (`auth.uid() = owner_id`). Pengguna lain tidak dapat memanipulasi data kos milik pemilik lain.
* **Bebas Kredensial Hardcoded**: Kunci rahasia atau privat (*service_role*) **tidak pernah** dimasukkan ke kode sumber aplikasi klien. Konfigurasi kredensial ditangani secara dinamis melalui argumen `--dart-define`.

---

## Cara Menjalankan Aplikasi

Aplikasi ini membaca kredensial Supabase menggunakan parameter `--dart-define` saat dijalankan:

### 1. Menjalankan di Emulator / Perangkat Fisik Android
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://proyekanda.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=kuncianonpublikanda
```

Untuk memilih emulator Android tertentu secara spesifik:
```bash
flutter run -d emulator-5554 \
  --dart-define=SUPABASE_URL=https://proyekanda.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=kuncianonpublikanda
```

### 2. Menjalankan di Browser (Google Chrome / Edge)
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://proyekanda.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=kuncianonpublikanda
```

### 3. Menjalankan Tanpa Kredensial (Mode Pratinjau Bersih)
Jika dijalankan tanpa argumen `--dart-define`, aplikasi tetap dapat berjalan secara aman menampilkan status offline/pesan koneksi tanpa mengalami *crash*:
```bash
flutter run
```

---

## Menjalankan Pengujian (Testing) & Analisis Kode

* **Menjalankan Analisis Statis Kode**:
  ```bash
  flutter analyze
  ```
  *(Memastikan kode bersih tanpa error maupun warning).*

* **Menjalankan Seluruh Unit Test & Widget Test**:
  ```bash
  flutter test
  ```
  *(Memverifikasi seluruh 72 skenario pengujian lulus 100%).*

---

## Cara Build APK (Release / Debug)

Untuk mengompilasi berkas APK mandiri:

* **Build APK Release**:
  ```bash
  flutter build apk --release \
    --dart-define=SUPABASE_URL=https://proyekanda.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=kuncianonpublikanda
  ```
  Berkas hasil kompilasi akan tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`.

* **Build APK Debug** *(jika signing release belum dikonfigurasi pada perangkat target)*:
  ```bash
  flutter build apk --debug \
    --dart-define=SUPABASE_URL=https://proyekanda.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=kuncianonpublikanda
  ```
  Berkas hasil kompilasi akan tersimpan di: `build/app/outputs/flutter-apk/app-debug.apk`.
