import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  ImagePickerService(this._picker);

  final ImagePicker _picker;

  Future<File?> pickFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (image == null) return null;
    return File(image.path);
  }

  Future<File?> pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (image == null) return null;
    return File(image.path);
  }

  Future<File?> pickImage(BuildContext context) async {
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => const _ImageSourceSheet(),
    );
    if (result == null) return null;
    final image = await _picker.pickImage(
      source: result,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (image == null) return null;
    return File(image.path);
  }
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: scheme.primary.withValues(alpha: 0.12),
              foregroundColor: scheme.primary,
              child: const Icon(Icons.photo_camera_rounded),
            ),
            title: const Text('Ambil Foto'),
            subtitle: const Text('Ambil foto struk langsung'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: scheme.primary.withValues(alpha: 0.12),
              foregroundColor: scheme.primary,
              child: const Icon(Icons.photo_library_rounded),
            ),
            title: const Text('Pilih dari Galeri'),
            subtitle: const Text('Pilih foto dari album'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
