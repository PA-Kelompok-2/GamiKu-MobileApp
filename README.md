# 📝 Deskripsi Aplikasi

Aplikasi ini merupakan aplikasi mobile berbasis Flutter yang dirancang untuk mempermudah proses pemesanan menu makanan dan minuman secara digital. Sistem ini terintegrasi dengan backend Supabase yang berfungsi untuk menangani autentikasi pengguna serta penyimpanan dan pengelolaan data secara real-time. Dengan adanya integrasi ini, pengguna dapat mengakses data secara cepat dan aman melalui perangkat mobile.

Aplikasi ini dikembangkan dengan pendekatan arsitektur modular yang memisahkan antara tampilan (UI), logika aplikasi (controller), dan layanan backend (service). Pendekatan ini bertujuan untuk meningkatkan keterbacaan kode, memudahkan proses pengembangan, serta memungkinkan aplikasi untuk dikembangkan lebih lanjut di masa depan.

# 🎯 Tujuan Pengembangan

Tujuan utama dari pengembangan aplikasi ini adalah untuk mendigitalisasi proses pemesanan menu agar menjadi lebih efisien dan praktis. Selain itu, aplikasi ini juga bertujuan untuk memberikan pengalaman pengguna yang responsif dan mudah digunakan. Dari sisi pengembangan, aplikasi ini menjadi sarana implementasi teknologi Flutter dengan integrasi backend modern menggunakan Supabase serta penerapan state management menggunakan GetX.

# ✨ Fitur Aplikasi

## 🔐 1. Authentication (Autentikasi)
Fitur autentikasi berfungsi sebagai sistem keamanan utama dalam aplikasi yang memastikan bahwa hanya pengguna yang terdaftar yang dapat mengakses fitur-fitur di dalamnya. Proses autentikasi dilakukan menggunakan email dan password yang terintegrasi langsung dengan layanan Supabase Authentication.

Pada fitur ini, pengguna dapat melakukan registrasi akun baru dengan mengisi data yang diperlukan, kemudian melakukan login untuk masuk ke dalam sistem. Setelah berhasil login, sesi pengguna akan disimpan sehingga pengguna tidak perlu melakukan login ulang setiap kali membuka aplikasi. Selain itu, terdapat splash screen yang berfungsi sebagai tampilan awal sekaligus melakukan pengecekan status login pengguna secara otomatis.

### Fungsi:
- Login pengguna menggunakan email & password
- Registrasi akun baru
- Menyimpan sesi login
- Splash screen sebagai loading awal

### File terkait:
- login_screen.dart
- register_screen.dart
- splash_screen.dart
- auth_controller.dart

## 🏠 2. Home / Beranda
Halaman beranda merupakan halaman utama yang pertama kali diakses setelah pengguna berhasil login. Halaman ini berfungsi sebagai pusat navigasi yang menghubungkan pengguna ke seluruh fitur yang tersedia dalam aplikasi.

Pada halaman ini, pengguna dapat melihat tampilan ringkasan aplikasi serta mengakses menu utama seperti daftar menu, profil, dan pengaturan. Desain halaman dibuat sederhana dan intuitif agar memudahkan pengguna dalam berpindah antar fitur tanpa kebingungan.

### Fungsi:
- Menampilkan menu utama aplikasi
- Akses cepat ke fitur lain (menu, profil, settings)
- Menampilkan informasi umum

### File terkait:
- home_screen.dart

## 🍽️ 3. Menu (Daftar Produk)
Fitur menu merupakan fitur inti dalam aplikasi yang digunakan untuk menampilkan daftar makanan atau minuman yang tersedia. Data menu diambil langsung dari database Supabase sehingga informasi yang ditampilkan bersifat dinamis dan dapat diperbarui secara real-time.

Setiap item menu ditampilkan dalam bentuk list yang berisi informasi seperti nama produk, harga, dan kemungkinan deskripsi tambahan. Pengguna dapat memilih item yang diinginkan untuk kemudian ditambahkan ke dalam keranjang.

### Fungsi:
- Menampilkan list menu dari database
- Menampilkan detail item (nama, harga, dll)
- Integrasi langsung dengan Supabase

### File terakit:
- menu_controller.dart
- menu_screen.dart
  
## 🛒 4. Cart (Keranjang)
Fitur cart digunakan untuk menampung dan mengelola item yang dipilih oleh pengguna sebelum dilakukan proses pemesanan. Fitur ini memungkinkan pengguna untuk melihat daftar item yang telah dipilih beserta jumlah dan total harga.

Pengguna dapat menambahkan item dari menu ke dalam keranjang, menghapus item yang tidak diinginkan, serta melihat total keseluruhan pesanan secara otomatis. Fitur ini sangat penting dalam mendukung alur pemesanan yang terstruktur.

### Fungsi:
- Menambahkan item ke keranjang
- Menghapus item
- Menampilkan total pesanan

### Controller:
- cart_controller.dart

## 👤 5. Profile (Profil Pengguna)
Fitur profil digunakan untuk menampilkan dan mengelola informasi pribadi pengguna yang telah terdaftar dalam sistem. Pengguna dapat melihat data seperti nama, email, atau informasi lain yang tersimpan, serta melakukan perubahan jika diperlukan.

Perubahan data profil akan disimpan kembali ke database sehingga informasi tetap terbarui. Fitur ini memberikan kontrol kepada pengguna terhadap data pribadi mereka di dalam aplikasi.

### Fungsi:
- Menampilkan informasi user
- Edit profil
- Menyimpan perubahan data

### File terkait:
- profile_controller.dart
- profile_screen.dart
- my_profile_screen.dart
  
## ⚙️ 6. Settings & Informasi
Fitur settings dan informasi berfungsi untuk memberikan akses kepada pengguna terhadap pengaturan aplikasi serta informasi tambahan yang berkaitan dengan penggunaan aplikasi.

Di dalam fitur ini, pengguna dapat menemukan berbagai halaman seperti tentang aplikasi, pusat bantuan, kebijakan privasi, serta syarat dan ketentuan penggunaan. Fitur ini bertujuan untuk meningkatkan transparansi dan memberikan panduan kepada pengguna dalam menggunakan aplikasi.

### Menu yang tersedia:
- Settings
- About
- Help Center
- Privacy Policy
- Terms of Service

### File terkait:
- settings_screen.dart
- about_screen.dart
- help_center_screen.dart
- privacy_policy_screen.dart
- terms_of_services_screen.dart
  
## 🔄 7. Integrasi Backend (Supabase)
Aplikasi ini menggunakan Supabase sebagai backend utama yang berperan dalam pengelolaan autentikasi dan database. Supabase dipilih karena kemudahan integrasi dengan Flutter serta kemampuannya dalam menyediakan layanan backend secara real-time.

Melalui Supabase, aplikasi dapat melakukan proses login dan registrasi pengguna, serta mengambil dan menyimpan data seperti menu dan informasi pengguna. Seluruh komunikasi dengan backend dikelola melalui service yang telah dibuat agar kode lebih terstruktur dan mudah dipelihara.

### Fungsi Supabase:
- Authentication (login & register)
- Database (data menu & user)

### Service:
- supabase_services.dart

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
