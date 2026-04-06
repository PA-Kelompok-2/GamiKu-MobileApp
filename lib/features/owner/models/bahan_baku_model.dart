class BahanBaku {
  final String id;
  String name;
  int stock;
  String unit;
  int price;
  DateTime createdAt;

  BahanBaku({
    required this.id,
    required this.name,
    required this.stock,
    required this.unit,
    required this.price,
    required this.createdAt,
  });

  factory BahanBaku.fromJson(Map<String, dynamic> json) {
    return BahanBaku(
      id: json['id'],
      name: json['name'],
      stock: json['stock'] ?? 0,
      unit: json['unit'] ?? '',
      price: json['price'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stock': stock,
      'unit': unit,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
