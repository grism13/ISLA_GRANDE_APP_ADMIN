import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventary_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventaryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('${order.turistaNombre} - \$${order.total}'),
                    subtitle: Text('Estado: ${order.estado}\nArtículos: ${order.articulos.length}'),
                    trailing: order.estado == 'pendiente'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => provider.concretarPedido(order),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => provider.rechazarPedido(order),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
