import 'package:flutter/material.dart';

class IdCardImageViewer extends StatelessWidget {
  final String imageUrl;
  final String cardHolderName;

  const IdCardImageViewer({
    super.key,
    required this.imageUrl,
    required this.cardHolderName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ID Card Image: $cardHolderName'),
      ),
      body: Center(
        child: imageUrl.isNotEmpty
            ? InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 2.5,
          child: Image.network(
            imageUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                    value: loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
            const Text('Failed to load image'),
          ),
        )
            : const Text('No ID card image available.'),
      ),
    );
  }
}