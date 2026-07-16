import 'dart:convert';

class Order {
  final String id;
  final String turistaNombre;
  String estado;
  final DateTime fecha;
  final Map<String, int> articulos;
  final double total;

  Order({
    required this.id,
    required this.turistaNombre,
    required this.estado,
    required this.fecha,
    required this.articulos,
    required this.total,
  });

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    return Order(
      id: id,
      turistaNombre: map['turistaNombre'] ?? '',
      estado: map['estado'] ?? 'pendiente',
      fecha: map['fecha'] != null ? DateTime.parse(map['fecha']) : DateTime.now(),
      articulos: Map<String, int>.from(map['articulos'] ?? {}),
      total: (map['total'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'turistaNombre': turistaNombre,
      'estado': estado,
      'fecha': fecha.toIso8601String(),
      'articulos': articulos,
      'total': total,
    };
  }

  factory Order.fromJson(String id, String source) =>
      Order.fromMap(id, json.decode(source));

  String toJson() => json.encode(toMap());
}
