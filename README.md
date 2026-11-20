# KosFinder

Aplikasi pencarian dan pengelolaan tempat kos berbasis Android dan Web yang dibangun menggunakan **Flutter**, **Provider**, dan **Supabase**.

---

## Identitas Pengembang
* **NIM**  : `2415051085`
* **Nama** : `I Komang Candra Aryadinata`

---

## Fitur Utama (Versi 0.1.0)
1. **Eksplorasi Publik (Tanpa Login)**: Menjelajah daftar kos, melihat informasi detail, dan memeriksa sisa kamar / badge status "Penuh".
2. **Pencarian & Filter**: Mencari kos berdasarkan nama atau area, serta menyaring rentang harga sewa per bulan.
3. **Autentikasi Pemilik**: Masuk (login) dan pendaftaran akun baru bagi pemilik kos melalui Supabase Auth.
4. **Dashboard Pemilik**: Area khusus pengelolaan properti kos bagi pemilik yang telah terautentikasi.

---

## Cara Menjalankan

Aplikasi ini menggunakan parameter `--dart-define` untuk menghubungkan proyek ke Supabase secara dinamis dan aman tanpa menyimpan *credentials* di kode sumber.

### 1. Menjalankan di Emulator / Perangkat Default
Gantilah nilai `SUPABASE_URL` dan `SUPABASE_ANON_KEY` dengan kredensial proyek Supabase Anda:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummyanonkey12345
```

### 2. Menjalankan di Google Chrome (Web)
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummyanonkey12345
```

### 3. Menjalankan Tanpa Kredensial (Mode Pratinjau Lokal)
Jika dijalankan tanpa argumen `--dart-define`, aplikasi tetap dapat berjalan secara aman menampilkan status offline/pesan koneksi tanpa mengalami *crash*:
```bash
flutter run
```

---

## Cara Build APK (Release)

Untuk menghasilkan berkas APK rilis mandiri:
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummyanonkey12345
```
Berkas APK akan berada di: `build/app/outputs/flutter-apk/app-release.apk`.
