import 'dart:io';
import 'package:biteback/core/local_user_db.dart';
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
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Perfil")),
        body: Consumer<ProfileViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = vm.profile!;
            nameController.text = profile.displayName ?? "";
            phoneController.text = profile.phoneNumber ?? "";

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: profile.email),
                    readOnly: true,
                    decoration: const InputDecoration(labelText: "Correo"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    onChanged: (value) {
                      vm.profile?.displayName = value;
                    },
                    decoration: const InputDecoration(labelText: "Nombre"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      vm.profile?.phoneNumber = value;
                    },
                    decoration: const InputDecoration(labelText: "Teléfono"),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text("Puntos: ${profile.earnedPoints}"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await vm.saveProfileChanges();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cambios guardados")),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar cambios"),
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
