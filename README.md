# 📝 Deskripsi Aplikasi

Aplikasi ini merupakan aplikasi mobile berbasis Flutter yang dirancang untuk mempermudah proses pemesanan menu makanan dan minuman secara digital. Sistem ini terintegrasi dengan backend Supabase yang berfungsi untuk menangani autentikasi pengguna serta penyimpanan dan pengelolaan data secara real-time. Dengan adanya integrasi ini, pengguna dapat mengakses data secara cepat dan aman melalui perangkat mobile.

Aplikasi ini dikembangkan dengan pendekatan arsitektur modular yang memisahkan antara tampilan (UI), logika aplikasi (controller), dan layanan backend (service). Pendekatan ini bertujuan untuk meningkatkan keterbacaan kode, memudahkan proses pengembangan, serta memungkinkan aplikasi untuk dikembangkan lebih lanjut di masa depan.

# 🎯 Tujuan Pengembangan

Tujuan utama dari pengembangan aplikasi ini adalah untuk mendigitalisasi proses pemesanan menu agar menjadi lebih efisien dan praktis. Selain itu, aplikasi ini juga bertujuan untuk memberikan pengalaman pengguna yang responsif dan mudah digunakan. Dari sisi pengembangan, aplikasi ini menjadi sarana implementasi teknologi Flutter dengan integrasi backend modern menggunakan Supabase serta penerapan state management menggunakan GetX.

# ✨ Fitur Aplikasi

## 🔐 1. Authentication (Autentikasi)
Fitur autentikasi berfungsi sebagai sistem keamanan utama dalam aplikasi yang memastikan bahwa hanya pengguna yang terdaftar yang dapat mengakses fitur-fitur di dalamnya.

### Fungsi:
- Login pengguna menggunakan email & password
- Registrasi akun baru
- Menyimpan sesi login
- Splash screen sebagai loading awal

## 🏠 2. Home / Beranda
Halaman beranda merupakan halaman utama yang pertama kali diakses setelah pengguna berhasil login. Halaman ini berfungsi sebagai pusat navigasi yang menghubungkan pengguna ke seluruh fitur yang tersedia dalam aplikasi.

### Fungsi:
- Menampilkan menu utama aplikasi
- Akses cepat ke fitur lain (menu, profil, settings)
- Menampilkan informasi umum

## 🍽️ 3. Menu (Daftar Produk)
Fitur menu merupakan fitur inti dalam aplikasi yang digunakan untuk menampilkan daftar makanan atau minuman yang tersedia. Data menu diambil langsung dari database Supabase sehingga informasi yang ditampilkan bersifat dinamis dan dapat diperbarui secara real-time.

### Fungsi:
- Menampilkan list menu dari database
- Menampilkan detail item (nama, harga, dll)
- Integrasi langsung dengan Supabase

## 🛒 4. Cart (Keranjang)
Fitur cart digunakan untuk menampung dan mengelola item yang dipilih oleh pengguna sebelum dilakukan proses pemesanan. Fitur ini memungkinkan pengguna untuk melihat daftar item yang telah dipilih beserta jumlah dan total harga.

### Fungsi:
- Menambahkan item ke keranjang
- Menghapus item
- Menampilkan total pesanan

## 👤 5. Profile (Profil Pengguna)
Fitur profil digunakan untuk menampilkan dan mengelola informasi pribadi pengguna yang telah terdaftar dalam sistem. Pengguna dapat melihat data seperti nama, email, atau informasi lain yang tersimpan, serta melakukan perubahan jika diperlukan.

### Fungsi:
- Menampilkan informasi user
- Edit profil
- Menyimpan perubahan data
  
## ⚙️ 6. Settings & Informasi
Fitur settings dan informasi berfungsi untuk memberikan akses kepada pengguna terhadap pengaturan aplikasi serta informasi tambahan yang berkaitan dengan penggunaan aplikasi.

### Menu yang tersedia:
- Settings
- About
- Help Center
- Privacy Policy
- Terms of Service
  
## 🔄 7. Integrasi Backend (Supabase)
Aplikasi ini menggunakan Supabase sebagai backend utama yang berperan dalam pengelolaan autentikasi dan database. Supabase dipilih karena kemudahan integrasi dengan Flutter serta kemampuannya dalam menyediakan layanan backend secara real-time.

### Fungsi Supabase:
- Authentication (login & register)
- Database (data menu & user)

# 👥 Role Pengguna dalam Aplikasi

## 👤 1. Pengguna (Customer)
Pengguna atau customer merupakan role utama yang menggunakan aplikasi untuk melakukan pemesanan menu. Role ini berinteraksi langsung dengan fitur-fitur utama seperti melihat daftar menu, menambahkan item ke keranjang, serta mengelola profil pribadi.

Pengguna memiliki akses terbatas hanya pada fitur yang berkaitan dengan aktivitas pemesanan dan informasi akun pribadi. Mereka tidak memiliki akses untuk mengelola data sistem seperti menu atau data pengguna lain.

### Hak Akses:
- Melakukan registrasi dan login
- Melihat daftar menu
- Menambahkan dan menghapus item di keranjang
- Melihat total pesanan
- Mengelola profil pribadi
- Mengakses halaman informasi (help center, privacy policy, dll)

## 🧑‍💼 2. Owner
Owner merupakan role dengan hak akses tertinggi dalam aplikasi yang bertanggung jawab atas pengelolaan keseluruhan sistem. Owner memiliki kontrol penuh terhadap data dan operasional aplikasi, termasuk pengelolaan menu, karyawan, serta pemantauan performa bisnis.

Dalam implementasinya, owner biasanya memiliki akses ke fitur tambahan seperti dashboard statistik, manajemen data karyawan, serta laporan keuangan atau transaksi.

### Hak Akses:
- Mengelola data menu (tambah, edit, hapus)
- Melihat dan mengelola data pesanan
- Mengelola data karyawan
- Melihat statistik penjualan atau performa harian
- Mengakses seluruh fitur dalam aplikasi

## 👨‍🍳 3. Karyawan
Karyawan merupakan role yang membantu operasional sehari-hari dalam sistem. Role ini memiliki akses terbatas yang berfokus pada pengelolaan pesanan dan pelayanan kepada pengguna.

Karyawan tidak memiliki akses penuh seperti owner, namun tetap memiliki peran penting dalam memastikan pesanan diproses dengan baik.

### Hak Akses:
- Melihat daftar pesanan masuk
- Mengelola status pesanan (diproses, selesai, dll)
- Membantu operasional layanan
- Akses terbatas terhadap data tertentu sesuai kebutuhan

# 🧩 Widget yang Digunakan
## 📌 Core Layout
`MaterialApp → Root aplikasi`

`Scaffold → Struktur halaman`

`AppBar → Header`

`Container → Styling & layout`

`Column & Row → Layout vertikal & horizontal`

## 📝 Input & Interaksi
`TextField → Input user`

`ElevatedButton → Tombol aksi`

`GestureDetector → Interaksi klik`

`Icon → Ikon UI`

## 📋 Data Display
`ListView → Menampilkan list menu`

`Text → Menampilkan data`

`Card → Tampilan item menu`
