import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:mobile_onboarding/widgets/circularAvatar/imageProvide.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Provider.of<ImageProviderNotifier>(context, listen: false)
          .setImagePath(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageProviderNotifier>(
      builder: (context, imageProviderNotifier, child) {
        String? imagePath = imageProviderNotifier.imagePath;
        return GestureDetector(
          onTap: () => _pickImage(context),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: imagePath != null
                ? FileImage(File(imagePath))
                : NetworkImage(
                    'https://st3.depositphotos.com/15648834/17930/v/450/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg',
                  ) as ImageProvider,
          ),
        );
      },
    );
  }
}
