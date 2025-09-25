import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-widgets/widgets/custom_icon_widget.dart';

class GalleryAccessWidget extends StatelessWidget {
  final VoidCallback onTap;

  const GalleryAccessWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
