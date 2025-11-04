import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-widgets/widgets/custom_icon_widget.dart';
import '../../../../services/theme_service.dart';

class GalleryAccessWidget extends StatefulWidget {
  final VoidCallback onTap;

  const GalleryAccessWidget({
    super.key,
    required this.onTap,
  });

  @override
  State<GalleryAccessWidget> createState() => _GalleryAccessWidgetState();
}

class _GalleryAccessWidgetState extends State<GalleryAccessWidget> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        child: CustomIconWidget(
          iconName: 'photo_library',
          color: Colors.white,
          size: 6.w,
        ),
      ),
    );
  }
}
