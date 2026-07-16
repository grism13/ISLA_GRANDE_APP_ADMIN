import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';

class InventaryProvider extends ChangeNotifier {
  final String _baseUrl = 'https://catalogo-25a73-default-rtdb.firebaseio.com';

  List<Product> products = [];
  List<Order> orders = [];
  bool isLoading = false;
  bool tiendaAbierta = false;

  List<Product> get lowStockProducts =>
      products.where((p) => p.stock < 5).toList();

  double get dailyIncome => orders
      .where((o) => o.estado == 'concretado')
      .fold(0.0, (sum, o) => sum + o.total);

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    try {
      final productsRes = await http.get(Uri.parse('$_baseUrl/productos.json'));
      final ordersRes = await http.get(Uri.parse('$_baseUrl/pedidos.json'));
      final statusRes = await http.get(Uri.parse('$_baseUrl/configuracion.json'));

      if (productsRes.statusCode == 200 && productsRes.body != 'null') {
        final Map<String, dynamic> pData = json.decode(productsRes.body);
        products = pData.entries
            .map((e) => Product.fromMap(e.key, e.value))
            .toList();
            
        if (kDebugMode) {
          print("¡Conexión Exitosa! Productos cargados: ${products.length}");
        }
      }

      if (ordersRes.statusCode == 200 && ordersRes.body != 'null') {
        final Map<String, dynamic> oData = json.decode(ordersRes.body);
        orders = oData.entries
            .map((e) => Order.fromMap(e.key, e.value))
            .toList();
      }

      if (statusRes.statusCode == 200 && statusRes.body != 'null') {
        final Map<String, dynamic> sData = json.decode(statusRes.body);
        tiendaAbierta = sData['tiendaAbierta'] ?? false;
      }
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTienda(bool estado) async {
    try {
      final res = await http.patch(
        Uri.parse('$_baseUrl/configuracion.json'),
        body: json.encode({'tiendaAbierta': estado}),
      );

      if (res.statusCode == 200) {
        tiendaAbierta = estado;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> rechazarPedido(Order pedido) async {
    try {
      final res = await http.patch(
        Uri.parse('$_baseUrl/pedidos/${pedido.id}.json'),
        body: json.encode({'estado': 'rechazado'}),
      );

      if (res.statusCode == 200) {
        final index = orders.indexWhere((o) => o.id == pedido.id);
        if (index != -1) {
          orders[index].estado = 'rechazado';
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> concretarPedido(Order pedido) async {
    try {
      final res = await http.patch(
        Uri.parse('$_baseUrl/pedidos/${pedido.id}.json'),
        body: json.encode({'estado': 'concretado'}),
      );

      if (res.statusCode == 200) {
        final index = orders.indexWhere((o) => o.id == pedido.id);
        if (index != -1) {
          orders[index].estado = 'concretado';

          for (final entry in pedido.articulos.entries) {
            final productId = entry.key;
            final quantity = entry.value;

            final pIndex = products.indexWhere((p) => p.id == productId);
            if (pIndex != -1) {
              final newStock = products[pIndex].stock - quantity;
              
              final stockRes = await http.patch(
                Uri.parse('$_baseUrl/productos/$productId.json'),
                body: json.encode({'stock': newStock}),
              );

              if (stockRes.statusCode == 200) {
                products[pIndex].stock = newStock;
              }
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/productos.json'),
        body: product.toJson(),
      );
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(res.body);
        final newProduct = Product.fromMap(data['name'], product.toMap());
        products.add(newProduct);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final res = await http.patch(
        Uri.parse('$_baseUrl/productos/${product.id}.json'),
        body: product.toJson(),
      );
      if (res.statusCode == 200) {
        final index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          products[index] = product;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/productos/$id.json'),
      );
      if (res.statusCode == 200) {
        products.removeWhere((p) => p.id == id);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }
}
