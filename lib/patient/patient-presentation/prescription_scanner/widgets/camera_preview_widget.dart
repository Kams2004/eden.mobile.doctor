import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../services/theme_service.dart';

class CameraPreviewWidget extends StatefulWidget {
  final CameraController cameraController;

  const CameraPreviewWidget({
    super.key,
    required this.cameraController,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    if (!widget.cameraController.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6)),
      );
    }

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width /
                widget.cameraController.value.aspectRatio,
            child: CameraPreview(widget.cameraController),
          ),
        ),
      ),
    );
  }
}
