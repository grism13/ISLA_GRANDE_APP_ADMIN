import 'dart:convert';

class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  int stock;
  final String categoria;
  final bool disponible;
  final String imagen;

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.categoria,
    required this.disponible,
    required this.imagen,
  });

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0.0).toDouble(),
      stock: map['stock']?.toInt() ?? 0,
      categoria: map['categoria'] ?? '',
      disponible: map['disponible'] ?? false,
      imagen: map['imagen'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'categoria': categoria,
      'disponible': disponible,
      'imagen': imagen,
    };
  }

  factory Product.fromJson(String id, String source) =>
      Product.fromMap(id, json.decode(source));

  String toJson() => json.encode(toMap());
}
