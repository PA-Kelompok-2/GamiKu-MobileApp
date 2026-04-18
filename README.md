# 📝 Deskripsi Aplikasi

Aplikasi ini merupakan aplikasi mobile berbasis Flutter yang dirancang untuk mempermudah proses pemesanan menu makanan dan minuman secara digital. Sistem ini terintegrasi dengan backend Supabase yang berfungsi untuk menangani autentikasi pengguna serta penyimpanan dan pengelolaan data secara real-time. Dengan adanya integrasi ini, pengguna dapat mengakses data secara cepat dan aman melalui perangkat mobile.

Aplikasi ini dikembangkan dengan pendekatan arsitektur modular yang memisahkan antara tampilan (UI), logika aplikasi (controller), dan layanan backend (service). Pendekatan ini bertujuan untuk meningkatkan keterbacaan kode, memudahkan proses pengembangan, serta memungkinkan aplikasi untuk dikembangkan lebih lanjut di masa depan.

# 🎯 Tujuan Pengembangan

Tujuan utama dari pengembangan aplikasi ini adalah untuk mendigitalisasi proses pemesanan menu agar menjadi lebih efisien dan praktis. Selain itu, aplikasi ini juga bertujuan untuk memberikan pengalaman pengguna yang responsif dan mudah digunakan. Dari sisi pengembangan, aplikasi ini menjadi sarana implementasi teknologi Flutter dengan integrasi backend modern menggunakan Supabase serta penerapan state management menggunakan GetX.

# ✨ Fitur Aplikasi

## 🔐 1. Authentication (Autentikasi)
<img width="328" height="698" alt="image" src="https://github.com/user-attachments/assets/697cf090-4dca-48a4-897c-471e7eb3cac6" />

Fitur autentikasi berfungsi sebagai sistem keamanan utama dalam aplikasi yang memastikan bahwa hanya pengguna yang terdaftar yang dapat mengakses fitur-fitur di dalamnya.

### Fungsi:
- Login pengguna menggunakan email & password
- Registrasi akun baru
- Menyimpan sesi login
- Splash screen sebagai loading awal

## 🏠 2. Home / Beranda
<img width="326" height="702" alt="image" src="https://github.com/user-attachments/assets/d186434b-9c14-4d09-812f-f6f34141cd94" />
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
<img width="325" height="698" alt="image" src="https://github.com/user-attachments/assets/700bdafd-fad9-4128-8563-6a121656b41b" />

Fitur cart digunakan untuk menampung dan mengelola item yang dipilih oleh pengguna sebelum dilakukan proses pemesanan. Fitur ini memungkinkan pengguna untuk melihat daftar item yang telah dipilih beserta jumlah dan total harga.

### Fungsi:
- Menambahkan item ke keranjang
- Menghapus item
- Menampilkan total pesanan

## 👤 5. Profile (Profil Pengguna)
<img width="325" height="703" alt="image" src="https://github.com/user-attachments/assets/970a7a41-3db2-4580-acdf-b888ab6919aa" />

Fitur profil digunakan untuk menampilkan dan mengelola informasi pribadi pengguna yang telah terdaftar dalam sistem. Pengguna dapat melihat data seperti nama, email, atau informasi lain yang tersimpan, serta melakukan perubahan jika diperlukan.

### Fungsi:
- Menampilkan informasi user
- Edit profil
- Menyimpan perubahan data
  
## ⚙️ 6. Settings & Informasi
<img width="323" height="704" alt="image" src="https://github.com/user-attachments/assets/059ec1b6-4f24-4d3c-9b17-5e6762817f79" />

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
<img width="326" height="702" alt="image" src="https://github.com/user-attachments/assets/d186434b-9c14-4d09-812f-f6f34141cd94" />

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
<img width="328" height="702" alt="image" src="https://github.com/user-attachments/assets/980637e2-8e70-4974-bc2f-10a0f35ca0b5" />

Owner merupakan role dengan hak akses tertinggi dalam aplikasi yang bertanggung jawab atas pengelolaan keseluruhan sistem. Owner memiliki kontrol penuh terhadap data dan operasional aplikasi, termasuk pengelolaan menu, karyawan, serta pemantauan performa bisnis.

Dalam implementasinya, owner biasanya memiliki akses ke fitur tambahan seperti dashboard statistik, manajemen data karyawan, serta laporan keuangan atau transaksi.

### Hak Akses:
- Mengelola data menu (tambah, edit, hapus)
- Melihat dan mengelola data pesanan
- Mengelola data karyawan
- Melihat statistik penjualan atau performa harian
- Mengakses seluruh fitur dalam aplikasi

## 👨‍🍳 3. Karyawan
<img width="327" height="705" alt="image" src="https://github.com/user-attachments/assets/ea219e61-1d60-4414-8e62-88924c6c25b9" />

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

# SOURCE CODE
<img width="332" height="203" alt="image" src="https://github.com/user-attachments/assets/27e28faf-9e2c-48cd-bbcd-c48499aefe12" />

## 📁 controllers
<img width="235" height="139" alt="image" src="https://github.com/user-attachments/assets/4226ccfb-ca7f-4c65-8f5e-b58cc9ea8628" />

Folder ini berisi logic atau otak aplikasi yang mengatur alur data dan state. Controller bertugas menghubungkan antara UI dengan data, misalnya mengelola menu, cart, profil, dan proses lainnya menggunakan GetX.

## 📁 core
<img width="126" height="110" alt="image" src="https://github.com/user-attachments/assets/0f3c690a-41d0-4c59-8464-77d70afd6b84" />

Folder ini berisi konfigurasi utama aplikasi yang bersifat global. Biasanya mencakup:
- Konstanta (seperti warna, tema)
- Service (seperti koneksi ke Supabase)
- Util (seperti app snackbar)
Folder ini menjadi pusat pengaturan yang bisa digunakan di seluruh aplikasi.

## 📁 features
<img width="158" height="165" alt="image" src="https://github.com/user-attachments/assets/f5d400fa-928f-4bb5-89b3-d47cf96c1ab2" />

Folder ini berisi fitur-fitur utama aplikasi yang dipisahkan berdasarkan fungsi. Tujuannya agar struktur kode lebih rapi dan modular.

##  📁 routes
<img width="249" height="114" alt="image" src="https://github.com/user-attachments/assets/cb32302d-93ae-4f01-b9bf-675ca0d1ec3a" />

Folder ini digunakan untuk mengatur navigasi antar halaman dalam aplikasi. Biasanya berisi definisi route atau nama-nama halaman yang digunakan untuk berpindah screen menggunakan GetX.

## 📁 shared/widgets
<img width="208" height="218" alt="image" src="https://github.com/user-attachments/assets/6558278d-b270-4b5f-b23f-87255abb2252" />

Folder ini berisi widget yang bisa digunakan ulang (reusable components) di berbagai halaman. Tujuannya agar tidak perlu menulis ulang kode yang sama.

## 📄 main.dart
File ini merupakan entry point aplikasi, yaitu file pertama yang dijalankan saat aplikasi dibuka. Di sini biasanya terdapat inisialisasi aplikasi.
