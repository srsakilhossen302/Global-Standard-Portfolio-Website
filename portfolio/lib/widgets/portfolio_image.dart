import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/portfolio_theme.dart';

class PortfolioImage extends StatelessWidget {
  final String imageSource;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;

  const PortfolioImage({
    super.key,
    required this.imageSource,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_rounded,
  });

  @override
  Widget build(BuildContext context) {
    if (imageSource.trim().isEmpty) {
      return _buildFallback();
    }

    // 1. Check if the image is a base64 string
    if (imageSource.startsWith('data:image') || _isBase64(imageSource)) {
      try {
        final cleanBase64 = _getCleanBase64(imageSource);
        final bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } catch (e) {
        print('Error decoding base64 image: $e');
        return _buildFallback();
      }
    }

    // 2. Check if the image is a web URL
    if (imageSource.startsWith('http://') || imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.black.withOpacity(0.04),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(PortfolioTheme.primary),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // 3. Fallback to Asset Image
    return Image.asset(
      imageSource,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: PortfolioTheme.primaryGradient,
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          color: Colors.white70,
          size: width != null ? width! * 0.25 : 32,
        ),
      ),
    );
  }

  bool _isBase64(String str) {
    if (str.length % 4 != 0) return false;
    final regex = RegExp(r'^[a-zA-Z0-9+/]*={0,2}$');
    return regex.hasMatch(str);
  }

  String _getCleanBase64(String str) {
    if (str.contains(',')) {
      return str.split(',')[1];
    }
    return str;
  }
}
