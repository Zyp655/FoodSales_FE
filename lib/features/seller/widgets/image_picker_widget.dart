import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef ImagePickCallback = void Function(XFile? image);

class ImagePickerWidget extends StatefulWidget {
  final String? initialImageUrl;
  final ImagePickCallback onImagePicked;

  const ImagePickerWidget({
    super.key,
    this.initialImageUrl,
    required this.onImagePicked,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      widget.onImagePicked(_selectedImage);
    }
  }

  ImageProvider? _buildImageProvider() {
    if (_selectedImage != null) {
      return FileImage(File(_selectedImage!.path));
    }
    if (widget.initialImageUrl != null) {
      return NetworkImage('http://10.0.2.2:8000/storage/${widget.initialImageUrl!}');
    }
    return null;
  }

  Widget? _buildImageOverlay() {
    if (_selectedImage == null && widget.initialImageUrl == null) {
      return const Icon(Icons.camera_alt, color: Colors.grey);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? imageProvider = _buildImageProvider();

    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        backgroundImage: imageProvider,

        onBackgroundImageError: imageProvider != null
            ? (e, s) {
          print("Error loading initial image: $e");
        }
            : null,

        child: _buildImageOverlay(),
      ),
    );
  }
}