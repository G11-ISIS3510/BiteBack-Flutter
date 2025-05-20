import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mystery_box_viewmodel.dart';

class MysteryBoxView extends StatelessWidget {
  const MysteryBoxView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MysteryBoxViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Caja Misteriosa')),
        body: Consumer<MysteryBoxViewModel>(
          builder: (context, viewModel, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Crear caja misteriosa",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Image.asset("assets/MysteryBox.png", height: 180),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Cantidad de productos (max 5):", style: TextStyle(fontSize: 16)),
                      DropdownButton<int>(
                        value: viewModel.selectedCount,
                        items: List.generate(5, (i) => i + 1)
                            .map((count) => DropdownMenuItem(
                                  value: count,
                                  child: Text(count.toString()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) viewModel.setSelectedCount(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            await viewModel.generateMysteryBox();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Caja misteriosa añadida al carrito"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pushNamed(context, '/cart');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Generar", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
