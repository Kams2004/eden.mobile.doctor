import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-widgets/widgets/custom_icon_widget.dart';
import '../../../../services/theme_service.dart';

class CaptureButtonWidget extends StatefulWidget {
  final VoidCallback onTap;
  final bool isEnabled;

  const CaptureButtonWidget({
    super.key,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  State<CaptureButtonWidget> createState() => _CaptureButtonWidgetState();
}

class _CaptureButtonWidgetState extends State<CaptureButtonWidget> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled
          ? () {
              HapticFeedback.mediumImpact();
              widget.onTap();
            }
          : null,
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isEnabled ? Colors.white : Colors.white38,
          border: Border.all(
            color: widget.isEnabled ? Colors.white : Colors.white38,
            width: 4.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isEnabled ? Colors.grey[300] : Colors.grey[500],
            ),
            child: CustomIconWidget(
              iconName: 'camera_alt',
              color: widget.isEnabled ? Colors.grey[700]! : Colors.grey[600]!,
              size: 8.w,
            ),
          ),
        ),
      ),
    );
  }
}
