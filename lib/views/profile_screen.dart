import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? Colors.black : Colors.grey[100];

    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Scaffold(
        backgroundColor: background,
        resizeToAvoidBottomInset: true,
        body: Consumer<ProfileViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = vm.profile!;
            nameController.text = profile.displayName ?? "";
            phoneController.text = profile.phoneNumber ?? "";

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        vm.profile?.localProfileImagePath = picked.path;
                        vm.notifyListeners();
                      }
                    },
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: profile.localProfileImagePath != null
                          ? FileImage(File(profile.localProfileImagePath!))
                          : null,
                      child: profile.localProfileImagePath == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.displayName ?? "Sin nombre",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(profile.email, style: TextStyle(color: Colors.grey[600])),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Información", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: nameController,
                              onChanged: (value) => vm.profile?.displayName = value,
                              decoration: const InputDecoration(
                                labelText: "Nombre",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              onChanged: (value) => vm.profile?.phoneNumber = value,
                              decoration: const InputDecoration(
                                labelText: "Teléfono",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.amber.shade100.withOpacity(0.1) : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Text("Puntos acumulados: ${profile.earnedPoints}",
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await vm.saveProfileChanges();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Cambios guardados")),
                                );
                              },
                              icon: const Icon(Icons.save),
                              label: const Text("Guardar cambios"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // o logout
                        },
                        icon: const Icon(Icons.logout, color: Colors.black),
                        label: const Text(
                          "Salir",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
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
