# TASKS.md — Rencana Tugas Pengembangan KosFinder

Dokumen ini memuat daftar rincian tugas teknis (*tasks*) yang disusun berdasarkan pendekatan **Vertical Slice Architecture**. Setiap *slice* harus menghasilkan aplikasi yang dapat dikompilasi dan dijalankan secara mandiri (*runnable*).

---

## Slice 1: Daftar dan Detail Kos (Publik & Guest)
> **Hasil Slice 1**: Aplikasi dapat dijalankan dan menampilkan daftar kos publik di beranda, halaman detail rincian kos, serta halaman profil pengembang (*About*).

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T01** | Setup dependensi (`provider`, `supabase_flutter`, `intl`), `AppConfig` (`--dart-define`), dan inisialisasi Supabase di `main.dart` | US01 (US01-AC1) | `pubspec.yaml`, `lib/main.dart`, `lib/core/config.dart` | Jalankan `flutter analyze` dan `flutter run` untuk memastikan inisialisasi berjalan lancar tanpa error | `[x] Selesai` |
| **T02** | Buat Model data `Kos` dan `KosRepository` untuk mengambil daftar kos dari tabel `public.kos` Supabase | US01 (US01-AC1, US01-AC2) | `lib/models/kos.dart`, `lib/repositories/kos_repository.dart` | Unit test parsing model dari JSON dan verifikasi fungsi `getAllKos()` | `[x] Selesai` |
| **T03** | Buat `KosProvider`, `HomeScreen`, dan `KosCard` untuk menampilkan daftar kos dengan aset *placeholder*, status loading, dan tombol coba lagi saat error | US01 (US01-AC1, US01-AC2) | `lib/providers/kos_provider.dart`, `lib/screens/home_screen.dart`, `lib/widgets/kos_card.dart` | Buka beranda di emulator, periksa daftar kos tampil rapi, dan uji mode offline untuk melihat pesan error koneksi | `[x] Selesai` |
| **T04** | Buat `KosDetailScreen` dan `AboutScreen` (memuat NIM 2415051085 & Nama I Komang Candra Aryadinata) beserta alur navigasi dari beranda | US01 (US01-AC3) | `lib/screens/kos_detail_screen.dart`, `lib/screens/about_screen.dart`, `lib/screens/home_screen.dart` | Ketuk kartu kos di beranda untuk membuka detail, lalu buka menu About untuk memastikan identitas tampil sesuai | `[x] Selesai` |

---

## Slice 2: Pencarian dan Filter Kos
> **Hasil Slice 2**: Aplikasi dapat dijalankan dengan fitur pencarian nama/area dan penyaringan harga yang responsif serta tampilan *empty state*.

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T05** | Implementasikan kueri pencarian nama/area dan penyaringan rentang harga pada `KosRepository` dan `KosProvider` | US02 (US02-AC1, US02-AC2) | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart` | Unit test fungsi pencarian teks dan filter rentang harga minimum/maksimum | `[x] Selesai` |
| **T06** | Buat SearchBar, Dialog/Sheet Filter Harga, dan widget Empty State di `HomeScreen` | US02 (US02-AC1, US02-AC2) | `lib/screens/home_screen.dart`, `lib/widgets/search_filter_bar.dart`, `lib/widgets/empty_state.dart` | Ketik area pada bilah pencarian, ubah rentang harga, dan ketik kata acak untuk memastikan pesan "Kos tidak ditemukan" muncul | `[x] Selesai` |

---

## Slice 3: Login & Autentikasi Pemilik
> **Hasil Slice 3**: Aplikasi dapat dijalankan dengan fitur registrasi akun pemilik, login email/password, penyimpanan sesi lokal, dan logout.

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T07** | Buat `AuthRepository` dan `AuthProvider` untuk registrasi, login, logout, dan pemantauan sesi aktif menggunakan Supabase Auth | US04 (US04-AC1, US04-AC2) | `lib/repositories/auth_repository.dart`, `lib/providers/auth_provider.dart` | Unit test fungsi login, register, dan sign out terhadap skenario sukses dan gagal | `[x] Selesai` |
| **T08** | Buat `AuthScreen` (form login & register dengan validasi email/password) dan `OwnerDashboardScreen` awal serta hubungkan navigasi dari menu Akun | US04 (US04-AC1, US04-AC2) | `lib/screens/auth_screen.dart`, `lib/screens/owner_dashboard_screen.dart`, `lib/screens/home_screen.dart` | Lakukan pendaftaran akun baru di aplikasi, login dengan kredensial yang dibuat, verifikasi masuk dashboard, lalu lakukan logout | `[x] Selesai` |

---

## Slice 4: Tambah, Ubah, dan Hapus Kos Milik Sendiri
> **Hasil Slice 4**: Aplikasi dapat dijalankan dengan fitur penuh pengelolaan kos (*CRUD*) oleh pemilik kos terproteksi keamanan RLS Supabase.

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T09** | Tambahkan fungsi `createKos`, `updateKos`, dan `deleteKos` pada `KosRepository` dan integrasikan ke `KosProvider` dengan penanganan error RLS | US05, US06, US07 (US05-AC1, US06-AC1, US06-AC2, US07-AC1) | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart` | Unit test eksekusi penambahan, perubahan, dan penghapusan kos terhubung ke Supabase | `[ ] Belum Dikerjakan` |
| **T10** | Buat formulir `KosFormScreen` untuk tambah data kos baru dan tampilkan daftar "Kos Saya" di `OwnerDashboardScreen` | US05 (US05-AC1, US05-AC2) | `lib/screens/kos_form_screen.dart`, `lib/screens/owner_dashboard_screen.dart` | Login sebagai pemilik, buka form Tambah Kos, isi data lengkap, simpan, dan pastikan data muncul di daftar Kos Saya dan publik | `[ ] Belum Dikerjakan` |
| **T11** | Implementasikan mode edit pada `KosFormScreen` dan fitur Hapus Kos (dialog konfirmasi hard delete) pada `OwnerDashboardScreen` | US06, US07 (US06-AC1, US06-AC2, US07-AC1, US07-AC2) | `lib/screens/kos_form_screen.dart`, `lib/screens/owner_dashboard_screen.dart` | Ubah harga atau data kos dan periksa hasil pembaruan; lalu hapus salah satu kos dan verifikasi data hilang permanen | `[ ] Belum Dikerjakan` |

---

## Slice 5 (Bonus): Ketersediaan Kamar & Badge Status Penuh
> **Hasil Slice 5**: Aplikasi dapat dijalankan dengan penanda visual status kos "Penuh" saat kamar habis, serta validasi ketat kapasitas kamar.

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T12** | Implementasikan komponen badge ketersediaan kamar ("Sisa X kamar" vs "Penuh") pada `KosCard` dan `KosDetailScreen` jika `available_rooms = 0` | US03 (US03-AC1, US03-AC2) | `lib/widgets/kos_card.dart`, `lib/screens/kos_detail_screen.dart` | Amati kartu kos dengan sisa 0 kamar dan pastikan label "Penuh" tampil jelas di daftar dan detail tanpa menyembunyikan kos | `[ ] Belum Dikerjakan` |
| **T13** | Tambahkan validasi batas kamar (`available_rooms <= total_rooms`) pada `KosFormScreen` dan tombol pembaruan cepat sisa kamar di `OwnerDashboardScreen` | US03, US05, US06 (US03-AC1, US05-AC2, US06-AC1) | `lib/screens/kos_form_screen.dart`, `lib/screens/owner_dashboard_screen.dart` | Input sisa kamar lebih besar dari total kamar dan pastikan ditolak; ubah sisa kamar menjadi 0 lalu verifikasi status langsung "Penuh" | `[ ] Belum Dikerjakan` |
