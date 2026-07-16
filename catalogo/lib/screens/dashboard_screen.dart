import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventary_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventaryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Estado de la Tienda'),
                    subtitle: Text(provider.tiendaAbierta ? 'Abierta' : 'Cerrada'),
                    value: provider.tiendaAbierta,
                    onChanged: (val) {
                      provider.toggleTienda(val);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Ingresos del Día'),
                    trailing: Text('\$${provider.dailyIncome.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(),
                  const Text('Alertas de Stock (< 5)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.lowStockProducts.length,
                      itemBuilder: (context, index) {
                        final product = provider.lowStockProducts[index];
                        return ListTile(
                          title: Text(product.nombre),
                          subtitle: Text('Stock actual: ${product.stock}'),
                          trailing: const Icon(Icons.warning, color: Colors.red),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
