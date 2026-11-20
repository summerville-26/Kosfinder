# Product Requirement Document (PRD) — KosFinder (Versi 1)

---

## 1. Masalah dan Tujuan yang Bisa Diukur

### 1.1 Masalah
1. **Informasi Tersebar**: Informasi seputar kos mahasiswa/masyarakat umum masih tersebar tidak terstruktur di media sosial, grup WhatsApp, dan info mulut ke mulut.
2. **Sulit Membandingkan**: Pencari kos kesulitan mencari, membandingkan harga, dan memeriksa fasilitas tempat kos secara cepat dan terpusat.
3. **Pengelolaan Manual**: Pemilik kos belum memiliki wadah praktis yang mudah diakses untuk mempublikasikan dan memperbarui ketersediaan kamar secara *real-time*.

### 1.2 Tujuan yang Bisa Diukur (Measurable Goals)
1. **Kecepatan Akses Informasi**: Pencari kos dapat menemukan daftar kos dan membuka rincian kos dalam waktu kurang dari 3 interaksi/klik dari beranda tanpa login.
2. **Performa Pemuatan Data**: Daftar kos di beranda termuat dalam waktu < 2 detik pada koneksi internet seluler standar (4G/WiFi).
3. **Efisiensi Publikasi**: Pemilik kos dapat mempublikasikan data kos baru dalam waktu < 2 menit melalui formulir terpandu.
4. **Integritas & Keamanan Akses**: 100% operasi modifikasi/hapus data kos dilindungi oleh Supabase Row Level Security (RLS) sehingga 0 insiden kebocoran perubahan data antar-pemilik.

---

## 2. Pengguna

1. **Pencari Kos**:
   * Mahasiswa atau masyarakat umum yang mencari tempat kos di sekitar kampus/area tertentu.
   * Dapat langsung mencari dan melihat rincian kos tanpa harus login (*guest mode*).
   * Disediakan opsi untuk login/registrasi akun jika diinginkan.
2. **Pemilik Kos**:
   * Pengelola atau pemilik tempat kos yang ingin memasarkan dan mengelola kos miliknya.
   * Wajib melakukan registrasi dan login untuk menambah, mengubah, dan menghapus kos.

---

## 3. Scope Versi 1

### 3.1 Yang Masuk (In-Scope)
* **Autentikasi (Supabase Auth)**: Registrasi akun (Email & Password), Login, dan Logout.
* **Eksplorasi Kos (Pencari Kos)**:
  * Menjelajah daftar kos secara publik tanpa login.
  * Pencarian berbasis teks berdasarkan nama kos atau area/kampus.
  * Penyaringan (*filter*) berdasarkan kategori tipe kos (**Semua**, **Putra**, **Putri**, **Campur**).
  * Penyaringan (*filter*) berdasarkan harga (urutan harga / rentang harga).
  * Halaman detail kos: foto (via URL/placeholder), nama, area, harga bulanan, tipe kos, fasilitas, stok kamar (`total_kamar` & `kamar_tersedia`), dan nomor kontak pemilik.
  * Badge status **"Penuh"** tetap tampil jika `kamar_tersedia = 0`.
* **Manajemen Kos (Pemilik Kos)**:
  * Melihat daftar kos yang dimiliki sendiri (*My Kos*).
  * Formulir Tambah Kos: nama, area, alamat, tipe kos, harga bulanan, fasilitas, `total_kamar`, `kamar_tersedia`, URL gambar, nomor kontak.
  * Formulir Ubah Kos milik sendiri.
  * Hapus Kos milik sendiri secara permanen (*hard delete*).
* **Backend & Arsitektur**:
  * Database & Auth: Supabase dengan integrasi Row Level Security (RLS).
  * State Management: Provider (Flutter).

### 3.2 Yang TIDAK Masuk (Out-of-Scope)
* Pembayaran sewa online / integrasi *payment gateway*.
* Fitur *in-app chat* / pesan instan di dalam aplikasi.
* Sistem ulasan (*review*) dan penilaian (*rating* bintang).
* Rekomendasi pintar / kecerdasan buatan (AI).
* Verifikasi identitas / KTP pemilik kos.
* Fitur *upload* berkas foto langsung ke Cloud Storage (menggunakan URL gambar / *placeholder*).
* Peta digital interaktif (*Google Maps / GPS navigation*).
* Manajemen tagihan sewa, laporan finansial kos, dan pencatatan penghuni kos.

---

## 4. Non-Functional Requirements (NFR)

* **Keamanan**: Operasi mutasi data (`INSERT`, `UPDATE`, `DELETE`) pada tabel kos di Supabase wajib divalidasi via RLS (`auth.uid() = owner_id`). Kunci privat *service_role* tidak boleh disertakan di aplikasi klien.
  * *Uji*: Simulasi request update data kos ID milik user A menggunakan token autentikasi user B harus menghasilkan penolakan akses (HTTP 403 / 0 row updated).
* **Keandalan**: Aplikasi tidak boleh *crash* saat terjadi kegagalan jaringan atau server tidak merespons; antarmuka wajib menampilkan *error state* informatif dan tombol muat ulang (*retry*).
  * *Uji*: Putuskan koneksi internet pada perangkat, lalu buka aplikasi; layar harus menampilkan pesan error koneksi dan tombol "Coba Lagi" tanpa *unhandled exception*.
* **Kemudahan Pakai (Usability)**: Validasi formulir dijalankan di sisi klien sebelum data dikirim (misal: harga > 0, kamar >= 0, field wajib tidak kosong). Layar pencarian wajib menyediakan tampilan *empty state* yang jelas.
  * *Uji*: Submit form kosong; pesan error validasi wajib muncul di bawah masing-masing input terkait.
* **Performa**: Waktu muat awal daftar kos maksimal 2 detik pada koneksi internet normal (4G/WiFi kecepatan stabil >= 5 Mbps). Transisi antar-halaman berjalan lancar (minimal 60 fps).
  * *Uji*: Pantau *Flutter DevTools Performance Profiler* untuk memastikan tidak ada *frame drop* berat saat proses *scrolling* list.
* **Privasi**: Informasi autentikasi (password) dienkripsi oleh Supabase Auth. Data nomor kontak pemilik hanya ditampilkan untuk keperluan komunikasi langsung pencari kos.
  * *Uji*: Periksa database Supabase; kolom password tidak tersimpan sebagai teks biasa (*plain text*).

---

## 5. User Stories

* **US01**: Sebagai **Pencari Kos**, saya ingin melihat daftar kos dan detailnya tanpa harus login, agar saya dapat menemukan informasi kos dengan cepat dan tanpa hambatan.
* **US02**: Sebagai **Pencari Kos**, saya ingin mencari kos berdasarkan nama/area serta memfilter berdasarkan jenis dan harga, agar saya dapat menemukan kos yang sesuai kriteria dan anggaran saya.
* **US03**: Sebagai **Pencari Kos**, saya ingin melihat tanda "Penuh" pada kos yang tidak memiliki kamar tersisa, agar saya tidak menghabiskan waktu menanyakan kos yang sudah tidak tersedia.
* **US04**: Sebagai **Pemilik Kos**, saya ingin mendaftar dan masuk ke akun saya, agar saya memiliki hak akses yang aman untuk mengelola data kos milik saya.
* **US05**: Sebagai **Pemilik Kos**, saya ingin menambahkan data kos baru dengan nomor kontak dan informasi kamar, agar kos saya dapat dilihat dan dihubungi oleh pencari kos.
* **US06**: Sebagai **Pemilik Kos**, saya ingin mengubah informasi kos milik saya sendiri, agar informasi ketersediaan kamar, harga, dan fasilitas selalu akurat.
* **US07**: Sebagai **Pemilik Kos**, saya ingin menghapus kos milik saya secara permanen, agar data kos yang sudah tidak dikelola tidak lagi muncul di aplikasi.

---

## 6. Acceptance Criteria

### US01: Melihat Daftar & Detail Kos Tanpa Login
* **US01-AC1 (Alur Normal Beranda)**:
  * **Given** Pengguna membuka aplikasi tanpa login (*guest*),
  * **When** Beranda berhasil memuat data dari Supabase,
  * **Then** Ditampilkan daftar kartu kos publik berisi gambar/placeholder, nama kos, area, tipe (Putra/Putri/Campur), harga, dan sisa kamar.
* **US01-AC2 (Kasus Koneksi Gagal)**:
  * **Given** Pengguna berada pada kondisi tanpa koneksi internet atau server backend bermasalah,
  * **When** Aplikasi berupaya memuat daftar kos,
  * **Then** Aplikasi tidak *force close*, menampilkan pesan "Gagal memuat data. Periksa koneksi internet Anda", dan menyediakan tombol "Coba Lagi".
* **US01-AC3 (Alur Detail Kos)**:
  * **Given** Pengguna melihat daftar kos di beranda,
  * **When** Pengguna mengetuk salah satu kartu kos,
  * **Then** Halaman detail terbuka menampilkan informasi lengkap (deskripsi, daftar fasilitas, total kamar, sisa kamar, dan tombol untuk menghubungi nomor kontak pemilik).

### US02: Pencarian & Penyaringan Kos
* **US02-AC1 (Pencarian & Filter Berhasil)**:
  * **Given** Pengguna berada di layar pencarian,
  * **When** Pengguna mengetik nama/area "Dago" dan memilih chip filter "Putri",
  * **Then** Daftar langsung diperbarui hanya menampilkan kos yang cocok dengan kata kunci "Dago" dan bertipe "Putri".
* **US02-AC2 (Kasus Data Kosong / Empty State)**:
  * **Given** Pengguna memasukkan kata kunci pencarian yang tidak cocok dengan data apa pun (misal: "AreaTidakAda999"),
  * **When** Proses pencarian selesai,
  * **Then** Layar menampilkan pesan *empty state*: "Kos tidak ditemukan. Coba gunakan kata kunci atau filter lain".

### US03: Indikator Kos Penuh
* **US03-AC1 (Kondisi Kamar Habis)**:
  * **Given** Terdapat data kos dengan nilai `kamar_tersedia = 0`,
  * **When** Kos tersebut ditampilkan di beranda atau halaman detail,
  * **Then** Kos tetap muncul di hasil pencarian dengan badge/label jelas bertuliskan "Penuh".
* **US03-AC2 (Kondisi Kamar Masih Ada)**:
  * **Given** Terdapat data kos dengan nilai `kamar_tersedia > 0` (misal 3),
  * **When** Kos tersebut ditampilkan pada kartu kos,
  * **Then** Ditampilkan teks status ketersediaan "Sisa 3 kamar".

### US04: Autentikasi Pengguna
* **US04-AC1 (Login Berhasil)**:
  * **Given** Pengguna berada di form login dan memasukkan email serta password terdaftar yang valid,
  * **When** Menekan tombol "Masuk",
  * **Then** Autentikasi Supabase berhasil, sesi login tersimpan lokal, dan pengguna diarahkan ke antarmuka akun/dashboard pemilik.
* **US04-AC2 (Login Gagal / Validasi Form Kosong)**:
  * **Given** Pengguna memasukkan format email tidak valid atau password salah,
  * **When** Menekan tombol "Masuk",
  * **Then** Tampil pesan kesalahan yang jelas (misal: "Email atau kata sandi tidak sesuai") dan pengguna tetap di halaman login.

### US05: Tambah Kos Baru
* **US05-AC1 (Tambah Data Berhasil)**:
  * **Given** Pemilik kos telah login dan berada di formulir "Tambah Kos",
  * **When** Mengisi seluruh field wajib (nama, area, alamat, tipe, harga, total kamar, kamar tersedia, kontak) lalu menekan tombol "Simpan",
  * **Then** Data tersimpan di tabel `kos` Supabase dengan `owner_id` sesuai UID pengguna, dan muncul di daftar "Kos Saya".
* **US05-AC2 (Validasi Field Kosong & Angka Negatif)**:
  * **Given** Pemilik kos mengisi form dengan mengosongkan nama kos atau memasukkan nilai `kamar_tersedia` lebih besar dari `total_kamar`,
  * **When** Menekan tombol "Simpan",
  * **Then** Data tidak dikirim ke Supabase dan sistem menampilkan peringatan validasi pada kolom yang tidak valid.

### US06: Ubah Informasi Kos
* **US06-AC1 (Ubah Kos Milik Sendiri)**:
  * **Given** Pemilik kos telah login dan membuka form edit pada salah satu kos miliknya,
  * **When** Mengubah nilai harga atau ketersediaan kamar lalu menekan "Simpan Perubahan",
  * **Then** Data di Supabase terbarui dan halaman detail memperlihatkan data yang baru.
* **US06-AC2 (Pencegahan Modifikasi Kos Milik Orang Lain / RLS Check)**:
  * **Given** Pengguna login sebagai Pemilik A,
  * **When** Mengirim instruksi pembaruan data terhadap kos dengan `owner_id` milik Pemilik B (misal melalui manipulasi ID request),
  * **Then** Kebijakan RLS Supabase menolak operasi tersebut dan aplikasi menampilkan pesan kesalahan "Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini".

### US07: Hapus Kos
* **US07-AC1 (Hard Delete Berhasil)**:
  * **Given** Pemilik kos melihat rincian kos miliknya dan memilih opsi "Hapus Kos",
  * **When** Mengonfirmasi pop-up dialog konfirmasi penghapusan,
  * **Then** Baris data kos tersebut terhapus permanen dari Supabase, dan tidak lagi ditemukan di pencarian publik maupun daftar pemilik.
* **US07-AC2 (Kasus Koneksi Gagal Saat Hapus)**:
  * **Given** Terjadi kegagalan jaringan saat konfirmasi hapus dikirim ke server,
  * **When** Operasi penghapusan gagal di Supabase,
  * **Then** Tampil pesan "Gagal menghapus data kos. Silakan coba beberapa saat lagi", dan data kos tetap aman tersimpan.

---

## 7. Hal yang Masih Ambigu (Daftar Pertanyaan)

1. **Format Kontak Pemilik**: Apakah format nomor kontak pemilik diwajibkan menggunakan format telepon seluler/WhatsApp Indonesia tertentu (misal: diawali `08` atau `+62`), dan apakah saat tombol kontak ditekan di halaman detail, aplikasi langsung memicu *URL launcher* membuka aplikasi Telepon/WhatsApp?
2. **Kategori Penentuan Harga (*Filter Price Range*)**: Pada filter harga pencari kos, apakah menggunakan rentang tetap (*fixed chips* seperti `< Rp1 Juta`, `Rp1 - 2 Juta`, `> Rp2 Juta`) atau input rentang angka fleksibel (minimal dan maksimal)?
3. **Pembedaan Peran Akun Supabase**: Karena pencari kos juga bisa login, apakah peran (*role*) pengguna (`pencari` vs `pemilik`) ditentukan melalui kolom `role` pada tabel profil publik atau melalui metadata autentikasi (`raw_user_meta_data`) saat registrasi?
