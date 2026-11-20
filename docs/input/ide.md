# Ide: KosFinder

## 1. Pengguna

- Mahasiswa atau masyarakat umum yang sedang mencari tempat kos, khususnya di sekitar kampus. Pencari kos dapat menggunakan aplikasi tanpa harus login.
- Pemilik kos yang ingin mempublikasikan dan mengelola informasi tempat kos miliknya. Pemilik harus melakukan registrasi dan login untuk mengelola data kos.

## 2. Masalah

Informasi mengenai tempat kos masih tersebar di berbagai sumber, seperti media sosial, grup WhatsApp, dan informasi dari mulut ke mulut.

Pencari kos mengalami kesulitan dalam menemukan informasi serta membandingkan harga dan fasilitas tempat kos.

Di sisi lain, pemilik kos membutuhkan sarana untuk mempublikasikan dan memperbarui informasi tempat kos yang dimiliki.

## 3. Hal yang Diharapkan Bisa Dilakukan

- Pencari dapat melihat daftar tempat kos tanpa login.
- Pencari dapat mencari tempat kos berdasarkan nama atau area.
- Pencari dapat menyaring tempat kos berdasarkan harga.
- Pencari dapat melihat informasi detail tempat kos.
- Pemilik dapat melakukan registrasi, login, dan logout.
- Pemilik dapat menambahkan informasi tempat kos.
- Pemilik dapat mengubah informasi tempat kos miliknya sendiri.
- Pemilik dapat menghapus informasi tempat kos miliknya sendiri.

## 4. Batasan

- Aplikasi dikembangkan untuk perangkat Android menggunakan Flutter.
- Supabase digunakan sebagai backend untuk database dan Authentication.
- Provider digunakan untuk pengelolaan state aplikasi.
- Pencari kos tidak diwajibkan login.
- Pemilik kos wajib login untuk menambahkan, mengubah, dan menghapus data kos.
- Hak akses pengelolaan data harus diterapkan menggunakan Row Level Security (RLS) di Supabase.
- Versi pertama tidak mencakup pembayaran online, fitur chat, ulasan dan rating, rekomendasi AI, verifikasi identitas pemilik, upload foto, dan peta digital.
- Pengembangan dilakukan secara bertahap menggunakan Antigravity dengan pendekatan Vibe Coding.
