# Architecture Document — KosFinder (Versi 1)

---

## 1. Komponen Aplikasi & Pola Arsitektur

Aplikasi KosFinder menerapkan pola berlapis terstruktur dan minimalis: **Screen – Provider – Repository – Supabase**. Setiap komponen memiliki pemisahan tanggung jawab yang tegas:

```
┌────────────────────────────────────────────────────────┐
│                  Screen (UI Layer)                     │
│  (Widget tampilan, form input, respons pengguna)       │
└───────────────────────────▲────────────────────────────┘
                            │ Membaca state & memicu aksi
┌───────────────────────────▼────────────────────────────┐
│                Provider (State Layer)                  │
│  (Pengelolaan state, filtering, notifikasi UI)         │
└───────────────────────────▲────────────────────────────┘
                            │ Memanggil fungsi data
┌───────────────────────────▼────────────────────────────┐
│              Repository (Data Access Layer)            │
│  (Abstraksi Supabase Client & mapping Model Dart)      │
└───────────────────────────▲────────────────────────────┘
                            │ Query network & PostgREST
┌───────────────────────────▼────────────────────────────┐
│              Supabase (Backend Service)                │
│  (Database PostgreSQL, Auth, Row Level Security)       │
└────────────────────────────────────────────────────────┘
```

### Rincian Komponen dan Pemetaan User Story

| Komponen | Tanggung Jawab | User Story Terkait |
| :--- | :--- | :--- |
| **Screens** | Menampilkan antarmuka pengguna, menerima input/filter harga, dan menampilkan pesan data/error. | **US01 s/d US07** |
| **KosProvider** | Mengelola state daftar kos, kueri pencarian nama/area, filter harga, status loading/error, dan aksi CRUD kos. | **US01, US02, US03, US05, US06, US07** |
| **AuthProvider** | Mengelola state sesi autentikasi, status login/logout pemilik kos, dan penanganan error autentikasi. | **US04** |
| **KosRepository** | Berinteraksi dengan tabel `public.kos` di Supabase untuk query publik, pencarian, filter harga, insert, update, dan delete. | **US01, US02, US03, US05, US06, US07** |
| **AuthRepository**| Menghubungkan aplikasi ke Supabase Auth (`signInWithPassword`, `signUp`, `signOut`, `currentSession`). | **US04** |
| **Supabase** | Penyedia database cloud PostgreSQL, penyimpanan akun, dan penegak keamanan data (RLS). | **US01 s/d US07** |

---

## 2. Daftar Layar dan Alur Navigasi

### 2.1 Daftar Layar
1. **HomeScreen (`/`)**: Menampilkan bilah pencarian nama/area, filter harga, daftar kartu kos dengan gambar *placeholder* bawaan aplikasi, serta status ketersediaan kamar/badge penuh. *(US01, US02, US03)*
2. **KosDetailScreen (`/detail`)**: Menampilkan gambar *placeholder*, nama kos, area, alamat lengkap, harga sewa, fasilitas, sisa kamar/badge penuh, dan teks nomor kontak pemilik kos. *(US01, US03)*
3. **AuthScreen (`/auth`)**: Formulir masuk (login) dan pendaftaran (register) bagi pemilik kos menggunakan email dan password. *(US04)*
4. **OwnerDashboardScreen (`/owner/dashboard`)**: Menampilkan daftar kos milik pemilik yang sedang login (*Kos Saya*), tombol aksi Tambah Kos, Ubah, Hapus, dan Logout. *(US04, US05, US06, US07)*
5. **KosFormScreen (`/owner/kos-form`)**: Formulir untuk menambah (*create*) atau memperbarui (*edit*) data kos. *(US05, US06)*
6. **AboutScreen (`/about`)**: Halaman informasi aplikasi yang menampilkan profil pengembang wajib: **NIM: 2415051085** dan **Nama: I Komang Candra Aryadinata**.

### 2.2 Alur Navigasi
```
[Buka Aplikasi] ──► HomeScreen (Publik/Guest)
                         │
                         ├──► [Tap Kartu Kos] ──► KosDetailScreen (Info Teks Kontak)
                         │
                         ├──► [Tap Menu Profil / Info] ──► AboutScreen
                         │
                         └──► [Tap Menu Masuk Pemilik]
                                     │
                        ┌────────────┴────────────┐
                        ▼                         ▼
                  (Belum Login)             (Sudah Login)
                        │                         │
                        ▼                         ▼
                    AuthScreen ──(Sukses)──► OwnerDashboardScreen
                                                  │
                                                  ├──► [Tambah Kos] ──► KosFormScreen(mode: create)
                                                  ├──► [Edit Kos]   ──► KosFormScreen(mode: edit)
                                                  └──► [Logout]     ──► HomeScreen
```

---

## 3. Rencana Database & Hak Akses

### 3.1 Skema Tabel `public.kos`
Kolom harga disimpan dengan tipe angka `BIGINT` untuk mencegah masalah pembulatan nilai mata uang Rupiah. Tidak ada kolom foto/gambar; tampilan kartu dan detail menggunakan aset *placeholder* lokal bawaan aplikasi.

| Kolom | Tipe Data | Keterangan & Validasi |
| :--- | :--- | :--- |
| `id` | `UUID` | Primary Key, default `gen_random_uuid()` |
| `owner_id` | `UUID` | Foreign Key ke `auth.users(id)` ON DELETE CASCADE, NOT NULL |
| `name` | `TEXT` | Nama kos, NOT NULL |
| `area` | `TEXT` | Nama area / sekitar kampus (misal: "Coblong", "Dago"), NOT NULL |
| `address` | `TEXT` | Alamat lengkap kos, NOT NULL |
| `price` | `BIGINT` | Harga sewa per bulan (Rupiah), CHECK (`price > 0`), NOT NULL |
| `total_rooms` | `INTEGER` | Total kapasitas kamar, CHECK (`total_rooms > 0`), NOT NULL |
| `available_rooms` | `INTEGER` | Sisa kamar tersedia, CHECK (`available_rooms >= 0` AND `available_rooms <= total_rooms`), NOT NULL |
| `facilities` | `TEXT[]` | Daftar fasilitas (contoh: `{'Wi-Fi', 'AC', 'KM Dalam'}`), NOT NULL |
| `contact_number`| `TEXT` | Teks nomor telepon/kontak pemilik kos, NOT NULL |
| `created_at` | `TIMESTAMPTZ` | Waktu dibuat, default `NOW()` |
| `updated_at` | `TIMESTAMPTZ` | Waktu pembaruan terakhir, default `NOW()` |

### 3.2 Matriks Hak Akses (Row Level Security)

| Operasi | Hak Akses | Aturan RLS Supabase | Story |
| :--- | :--- | :--- | :--- |
| **SELECT** | Publik (Anon & Authenticated) | Semua orang dapat melihat semua baris data (`true`) | **US01, US02, US03** |
| **INSERT** | Authenticated (Pemilik Kos) | Pengguna wajib login dan `owner_id = auth.uid()` | **US05** |
| **UPDATE** | Authenticated (Pemilik Kos) | Hanya pemilik baris yang boleh mengubah (`owner_id = auth.uid()`) | **US06** |
| **DELETE** | Authenticated (Pemilik Kos) | Hanya pemilik baris yang boleh menghapus (`owner_id = auth.uid()`) | **US07** |

---

## 4. Cara Konfigurasi (`--dart-define`)

Untuk menjamin keamanan dan mencegah kebocoran kredensial (sesuai `AGENTS.md`), URL Supabase dan Public Anon Key **tidak ditulis di dalam kode sumber**. Nilai dibaca saat kompilasi/eksekusi menggunakan `String.fromEnvironment`:

```dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

* **Menjalankan di Mode Pengembangan (Development)**:
  ```bash
  flutter run --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
  ```

---

## 5. Cara Rilis (Build APK & GitHub Release)

### 5.1 Build APK Release
Proses kompilasi APK mandiri dilakukan dengan menyertakan environment variables:
```bash
flutter build apk --release --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```
*Berkas APK hasil build berada di: `build/app/outputs/flutter-apk/app-release.apk`.*

### 5.2 GitHub Release (Versi v0.1.0)
1. Buat Git tag versi `v0.1.0`:
   ```bash
   git tag -a v0.1.0 -m "Release v0.1.0 - Inisialisasi awal KosFinder"
   git push origin v0.1.0
   ```
2. Buka repository GitHub di bagian Releases.
3. Buat Release baru dengan target tag `v0.1.0`, tuliskan catatan rilis fitur v0.1.0, lalu unggah file `app-release.apk` sebagai aset rilis.

---

## 6. Daftar Package yang Dibutuhkan

Sesuai prinsip kesederhanaan (*KISS*) dan kepatuhan aturan `AGENTS.md`, aplikasi hanya menggunakan 3 package esensial:

| Nama Package | Versi Rekomendasi | Alasan Penggunaan | User Story Terkait |
| :--- | :--- | :--- | :--- |
| **`provider`** | `^6.1.2` | State management resmi dan reaktif untuk mengelola state data kos dan sesi autentikasi. | **US01 s/d US07** |
| **`supabase_flutter`** | `^2.8.0` | SDK resmi Supabase untuk menangani Autentikasi dan operasi PostgREST Database dengan dukungan RLS. | **US01 s/d US07** |
| **`intl`** | `^0.20.2` | Memformat angka harga sewa menjadi format mata uang Rupiah (`NumberFormat.currency`). | **US01, US02, US05, US06** |
