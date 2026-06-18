class Item {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String brand;
  final String description;
  final String? imageUrl;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.brand,
    required this.description,
    this.imageUrl,
  });

  Item copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? unit,
    String? brand,
    String? description,
    String? imageUrl,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name.toLowerCase(),
      'categoryId': category,
      'price': price,
      'unit': unit,
      'brand': brand,
      'description': description,
      'imageUrl': imageUrl ?? '',
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    // Handle price as both string and double
    double price = 0.0;
    if (map['price'] is String) {
      price = double.tryParse(map['price']) ?? 0.0;
    } else if (map['price'] is num) {
      price = (map['price'] as num).toDouble();
    }
    
    return Item(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['categoryId'] ?? '',
      price: price,
      unit: map['unit'] ?? '',
      brand: map['brand'] ?? '',
      description: map['description'] ?? '',
      imageUrl: (map['imageUrl'] is String && (map['imageUrl'] as String).isNotEmpty)
          ? map['imageUrl'] as String
          : null,
    );
  }
}

class Category {
  final String id;
  final String name;
  final String icon;
  final String hexColor;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.hexColor,
  });

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? hexColor,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      hexColor: hexColor ?? this.hexColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name.toLowerCase(),
      'icon': icon,
      'hexColor': hexColor,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      hexColor: map['hexColor'] ?? map['color'] ?? '#6B8E6F',
    );
  }
}
