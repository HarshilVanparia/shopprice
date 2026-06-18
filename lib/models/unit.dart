class Unit {
  final String id;
  final String name;

  Unit({
    required this.id,
    required this.name,
  });

  Unit copyWith({
    String? id,
    String? name,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name.toLowerCase(),
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }
}
