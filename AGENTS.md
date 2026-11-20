# AGENTS.md — Aturan Kerja Agen AI (KosFinder)

Dokumen ini memuat panduan, standar teknis, dan etika kerja yang wajib dipatuhi oleh setiap Agen AI saat berkontribusi pada pengembangan repositori **KosFinder**.

---

## 1. Konteks Proyek & Dokumen Acuan

KosFinder adalah aplikasi pencarian dan pengelolaan kos berbasis Android yang dibangun menggunakan Flutter, Provider, dan Supabase.

Setiap pekerjaan wajib mengacu pada dokumen spesifikasi dan perencanaan berikut:
1. `docs/PRD.md`: Memuat kebutuhan produk, ruang lingkup (in-scope & out-of-scope), user stories, dan kriteria penerimaan (acceptance criteria).
2. `docs/ARCHITECTURE.md`: Memuat arsitektur sistem, struktur folder, skema database Supabase, dan tata kelola state Provider.
3. `docs/TASKS.md`: Memuat daftar rincian tugas/task terstruktur beserta ID unik task.

---

## 2. Cara Kerja Agen

* **Satu Task per Permintaan**: Kerjakan hanya satu task spesifik pada satu waktu sesuai instruksi yang diberikan.
* **Fokus & Pembatasan File**: Jangan mengubah atau membuat file di luar cakupan task yang sedang dikerjakan.
* **Perencanaan Sebelum Eksekusi Besar**: Untuk perubahan besar (arsitektur baru, refactoring masif, atau perubahan skema data), buat rencana kerja dan konfirmasi terlebih dahulu sebelum melakukan penulisan kode.
* **Prinsip Kesederhanaan (KISS)**: Pilih solusi implementasi yang paling sederhana, mudah dibaca, dan tidak berlebihan (*avoid overengineering*).
* **Manajemen Dependensi**: **DILARANG** menambahkan dependensi/package baru ke `pubspec.yaml` tanpa persetujuan eksplisit dari pengguna.

---

## 3. Standar Teknologi

* **Frontend**: Flutter (Target Android & Web).
* **State Management**: `Provider` (mengikuti pola MVVM/Clean Architecture sederhana).
* **Backend & Autentikasi**: Supabase (Database PostgreSQL & Supabase Auth).
* **Identitas Pengembang (Wajib)**:
  * Pada halaman **About / Profil Aplikasi**, wajib menampilkan identitas pengembang:
    ```
    NIM  : 2415051085
    Nama : I Komang Candra Aryadinata
    ```

---

## 4. Keamanan & Kebijakan Data

* **Anti Hardcoded Credentials**: Tidak boleh ada API Key rahasia, token, password, atau credential sensitif yang ditulis langsung di dalam kode sumber (*source code*). Simpan konfigurasi lingkungan melalui file `.env` (yang diabaikan oleh Git).
* **Larangan Penggunaan `service_role`**: Kunci privat `service_role` Supabase **TIDAK PERNAH** boleh dimasukkan atau digunakan dalam aplikasi klien. Aplikasi klien hanya boleh menggunakan `anon key`.
* **Penegakan Hak Akses (RLS)**: Seluruh kontrol akses data (insert, update, delete) wajib ditegakkan di level database melalui **Row Level Security (RLS)** Supabase, bukan hanya mengandalkan logika di sisi klien.

---

## 5. Tata Kelola Git & Version Control

* **Aturan Commit**: Satu task yang selesai dikerjakan = satu commit Git.
* **Format Pesan Commit**: Pesan commit wajib secara eksplisit mencantumkan ID task yang dikerjakan.
  * *Contoh*: `feat(T01): inisialisasi arsitektur folder dan provider`
  * *Contoh*: `fix(T05): perbaiki validasi nomor kontak pemilik kos`

---

## 6. Definition of Done (DoD)

Sebuah task dianggap selesai (*done*) hanya jika memenuhi seluruh kriteria berikut:
1. **Analisis Kode Bersih**: Menjalankan `flutter analyze` dan tidak menghasilkan error maupun warning baru.
2. **Pengujian Lulus**: Seluruh unit test atau widget test terkait lulus (`flutter test`).
3. **Verifikasi Aplikasi**: Aplikasi dapat berjalan tanpa kendala di perangkat/emulator yang tersedia.
4. **Laporan Pengujian**: Agen wajib melaporkan secara transparan apa saja yang telah berhasil diuji dan **bagian apa yang belum sempat diuji** kepada pengguna.
