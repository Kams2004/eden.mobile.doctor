import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-widgets/widgets/custom_icon_widget.dart';
import '../../../../services/theme_service.dart';

class FlashToggleWidget extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const FlashToggleWidget({
    super.key,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  State<FlashToggleWidget> createState() => _FlashToggleWidgetState();
}

class _FlashToggleWidgetState extends State<FlashToggleWidget> {
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
          color: widget.isEnabled ? Colors.yellow[600] : Colors.white24,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        child: CustomIconWidget(
          iconName: widget.isEnabled ? 'flash_on' : 'flash_off',
          color: widget.isEnabled ? Colors.black87 : Colors.white70,
          size: 6.w,
        ),
      ),
    );
  }
}
