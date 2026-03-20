class MenuData {
  static const List<String> categories = [
    'Semua',
    'Gami',
    'Sambal Bakar',
    'Asam Manis',
    'Tambahan',
    'Geprek',
    'Mie Geprek',
    'Cemilan',
    'Minuman',
  ];

  static const List<Map<String, dynamic>> items = [
    // ===== GAMI =====
    {'name': 'Gami Bebek',          'price': 55000, 'cat': 'Gami',        'emoji': '🦆'},
    {'name': 'Gami Nila',           'price': 45000, 'cat': 'Gami',        'emoji': '🐟'},
    {'name': 'Gami Patin',          'price': 45000, 'cat': 'Gami',        'emoji': '🐠'},
    {'name': 'Gami Udang',          'price': 45000, 'cat': 'Gami',        'emoji': '🦐'},
    {'name': 'Gami Cumi',           'price': 45000, 'cat': 'Gami',        'emoji': '🦑'},
    {'name': 'Gami Ayam',           'price': 45000, 'cat': 'Gami',        'emoji': '🍗'},
    {'name': 'Gami Ati Ampela',     'price': 40000, 'cat': 'Gami',        'emoji': '🍖'},
    {'name': 'Gami Kerang',         'price': 40000, 'cat': 'Gami',        'emoji': '🐚'},
    {'name': 'Gami Lele',           'price': 40000, 'cat': 'Gami',        'emoji': '🐡'},
    {'name': 'Gami Telur',          'price': 35000, 'cat': 'Gami',        'emoji': '🥚'},
    {'name': 'Gami Ceker',          'price': 35000, 'cat': 'Gami',        'emoji': '🍗'},
    {'name': 'Gami Pete Ikan Asin', 'price': 35000, 'cat': 'Gami',        'emoji': '🐟'},
    {'name': 'Mie Gami',            'price': 25000, 'cat': 'Gami',        'emoji': '🍜'},
    {'name': 'Gami Ikan Trakulu',   'price': 50000, 'cat': 'Gami',        'emoji': '🐡'},
    {'name': 'Gami Ikan Bawal',     'price': 50000, 'cat': 'Gami',        'emoji': '🐡'},

    // ===== SAMBAL BAKAR =====
    {'name': 'Sambal Bakar Iga',        'price': 60000, 'cat': 'Sambal Bakar', 'emoji': '🥩'},
    {'name': 'Sambal Bakar Nila',       'price': 45000, 'cat': 'Sambal Bakar', 'emoji': '🐟'},
    {'name': 'Sambal Bakar Lele',       'price': 40000, 'cat': 'Sambal Bakar', 'emoji': '🐡'},
    {'name': 'Sambal Bakar Patin',      'price': 45000, 'cat': 'Sambal Bakar', 'emoji': '🐠'},
    {'name': 'Sambal Bakar Bebek',      'price': 55000, 'cat': 'Sambal Bakar', 'emoji': '🦆'},
    {'name': 'Sambal Bakar Ati Ampela', 'price': 40000, 'cat': 'Sambal Bakar', 'emoji': '🍖'},
    {'name': 'Sambal Bakar Ayam',       'price': 45000, 'cat': 'Sambal Bakar', 'emoji': '🍗'},

    // ===== ASAM MANIS =====
    {'name': 'Nila Asam Manis',  'price': 45000, 'cat': 'Asam Manis', 'emoji': '🐟'},
    {'name': 'Udang Asam Manis', 'price': 45000, 'cat': 'Asam Manis', 'emoji': '🦐'},
    {'name': 'Cumi Asam Manis',  'price': 45000, 'cat': 'Asam Manis', 'emoji': '🦑'},

    // ===== TAMBAHAN =====
    {'name': 'Sop Daging',      'price': 45000, 'cat': 'Tambahan', 'emoji': '🍲'},
    {'name': 'Rawon Komplit',   'price': 45000, 'cat': 'Tambahan', 'emoji': '🥣'},
    {'name': 'Tumis Kangkung',  'price': 20000, 'cat': 'Tambahan', 'emoji': '🥬'},
    {'name': 'Tumis Toge',      'price': 20000, 'cat': 'Tambahan', 'emoji': '🌱'},
    {'name': 'Kol Goreng',      'price': 15000, 'cat': 'Tambahan', 'emoji': '🥦'},
    {'name': 'Kangkung Goreng', 'price': 15000, 'cat': 'Tambahan', 'emoji': '🥬'},
    {'name': 'Pete Goreng',     'price': 15000, 'cat': 'Tambahan', 'emoji': '🫘'},
    {'name': 'Tempe Penyet',    'price': 25000, 'cat': 'Tambahan', 'emoji': '🫘'},
    {'name': 'Nasi Gila',       'price': 35000, 'cat': 'Tambahan', 'emoji': '🍚'},
    {'name': 'Telur Crispy',    'price': 25000, 'cat': 'Tambahan', 'emoji': '🥚'},

    // ===== GEPREK =====
    {'name': 'Geprek Manja',      'price': 35000, 'cat': 'Geprek', 'emoji': '🌶️'},
    {'name': 'Geprek Kemangi',    'price': 35000, 'cat': 'Geprek', 'emoji': '🍃'},
    {'name': 'Geprek Mozzarella', 'price': 35000, 'cat': 'Geprek', 'emoji': '🧀'},
    {'name': 'Geprek Mangga',     'price': 35000, 'cat': 'Geprek', 'emoji': '🥭'},
    {'name': 'Geprek Pete',       'price': 35000, 'cat': 'Geprek', 'emoji': '🫘'},
    {'name': 'Geprek Terasi',     'price': 35000, 'cat': 'Geprek', 'emoji': '🦐'},

    // ===== MIE GEPREK =====
    {'name': 'Mie Geprek Ganj',       'price': 35000, 'cat': 'Mie Geprek', 'emoji': '🍜'},
    {'name': 'Mie Geprek Kemangi',    'price': 35000, 'cat': 'Mie Geprek', 'emoji': '🍜'},
    {'name': 'Mie Geprek Mozzarella', 'price': 35000, 'cat': 'Mie Geprek', 'emoji': '🍜'},
    {'name': 'Mie Geprek Mangga',     'price': 35000, 'cat': 'Mie Geprek', 'emoji': '🍜'},
    {'name': 'Mie Geprek Pete',       'price': 35000, 'cat': 'Mie Geprek', 'emoji': '🍜'},
    {'name': 'Mie Geprek Terasi',     'price': 35000, 'cat': 'Mie Geprek', 'emoji': '🍜'},

    // ===== CEMILAN =====
    {'name': 'Pisang Keju',     'price': 25000, 'cat': 'Cemilan', 'emoji': '🍌'},
    {'name': 'Tahu Cabe',       'price': 25000, 'cat': 'Cemilan', 'emoji': '🧈'},
    {'name': 'Singkong Goreng', 'price': 20000, 'cat': 'Cemilan', 'emoji': '🍠'},
    {'name': 'Cireng',          'price': 15000, 'cat': 'Cemilan', 'emoji': '🥟'},
    {'name': 'Mendoan',         'price': 15000, 'cat': 'Cemilan', 'emoji': '🫔'},
    {'name': 'Kentang Goreng',  'price': 25000, 'cat': 'Cemilan', 'emoji': '🍟'},

    // ===== MINUMAN =====
    {'name': 'Es Teh',      'price': 7000,  'cat': 'Minuman', 'emoji': '🧊'},
    {'name': 'Teh Hangat',  'price': 7000,  'cat': 'Minuman', 'emoji': '🍵'},
    {'name': 'Es Jeruk',    'price': 13000, 'cat': 'Minuman', 'emoji': '🍊'},
    {'name': 'Kopi Hitam',  'price': 15000, 'cat': 'Minuman', 'emoji': '☕'},
    {'name': 'Kopi Susu',   'price': 15000, 'cat': 'Minuman', 'emoji': '☕'},
    {'name': 'Cappucino',   'price': 15000, 'cat': 'Minuman', 'emoji': '☕'},
    {'name': 'Milo',        'price': 15000, 'cat': 'Minuman', 'emoji': '🍫'},
    {'name': 'Teh Tarik',   'price': 15000, 'cat': 'Minuman', 'emoji': '🧋'},
  ];

  static String formatPrice(int price) {
    final s = price.toString();
    if (s.length <= 3) return 'Rp $s';
    return 'Rp ${s.substring(0, s.length - 3)}.${s.substring(s.length - 3)}';
  }
}