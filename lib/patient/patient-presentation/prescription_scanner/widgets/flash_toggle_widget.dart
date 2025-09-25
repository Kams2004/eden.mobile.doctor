import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-widgets/widgets/custom_icon_widget.dart';

class FlashToggleWidget extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const FlashToggleWidget({
    super.key,
    required this.isEnabled,
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
          color: isEnabled ? Colors.yellow[600] : Colors.white24,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        child: CustomIconWidget(
          iconName: isEnabled ? 'flash_on' : 'flash_off',
          color: isEnabled ? Colors.black87 : Colors.white70,
          size: 6.w,
        ),
      ),
    );
  }
}
