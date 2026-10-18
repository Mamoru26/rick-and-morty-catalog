import 'package:flutter/material.dart';

class CharacterImage extends StatelessWidget {
  const CharacterImage({super.key, required this.url, this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context)
        .colorScheme
        .surfaceContainerHighest;
    Widget placeholder(Widget child) => Container(
      width: width,
      height: height,
      color: placeholderColor,
      alignment: Alignment.center,
      child: child,
    );

    if (url.isEmpty) {
      return placeholder(const Icon(Icons.person_outline));
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder(const SizedBox.shrink()),
      errorBuilder: (context, error, stackTrace) =>
          placeholder(const Icon(Icons.broken_image_outlined)),
    );
  }
}
