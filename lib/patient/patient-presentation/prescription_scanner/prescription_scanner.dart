import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../patient-core/core/app_export.dart';
import './widgets/capture_button_widget.dart';
import './widgets/flash_toggle_widget.dart';
import './widgets/gallery_access_widget.dart';
import './widgets/scanning_overlay_widget.dart';

class PrescriptionScanner extends StatefulWidget {
  const PrescriptionScanner({super.key});

  @override
  State<PrescriptionScanner> createState() => _PrescriptionScannerState();
}

class _PrescriptionScannerState extends State<PrescriptionScanner>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _flashEnabled = false;
  XFile? _capturedImage;
  final ImagePicker _imagePicker = ImagePicker();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Request camera permission
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
          _errorMessage =
              'Permission caméra requise pour scanner les prescriptions';
        });
        return;
      }

      // Step 2: Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Aucune caméra disponible sur cet appareil';
        });
        return;
      }

      // Step 3: Initialize camera controller
      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Step 4: Apply platform-specific settings
      await _applySettings();

      setState(() {
        _isInitialized = true;
        _hasPermission = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Erreur d\'initialisation de la caméra: ${e.toString()}';
      });
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true; // Browser handles permissions

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      debugPrint('Focus mode not supported: $e');
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        debugPrint('Flash mode not supported: $e');
      }
    }
  }

  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    setState(() {
      _isInitialized = false;
    });
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
      });

      // Simulate OCR processing
      await _processImage(photo);
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la capture: ${e.toString()}');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        await _processImage(image);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sélection: ${e.toString()}');
    }
  }

  Future<void> _processImage(XFile image) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate OCR processing delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      // Navigate to results with image path as argument
      Navigator.pushNamed(
        context,
        AppRoutes.prescriptionResults,
        arguments: image.path,
      );
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || kIsWeb) return;

    try {
      final newFlashMode = _flashEnabled ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newFlashMode);
      setState(() {
        _flashEnabled = !_flashEnabled;
      });
    } catch (e) {
      debugPrint('Flash toggle failed: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scanner Prescription',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            margin: EdgeInsets.only(right: 4.w),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'EDEN',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : !_hasPermission
              ? _buildPermissionDenied()
              : _errorMessage != null
                  ? _buildErrorState()
                  : _capturedImage != null
                      ? _buildPreviewState()
                      : _buildCameraState(),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'camera_alt',
              color: Colors.white54,
              size: 15.w,
            ),
            SizedBox(height: 3.h),
            Text(
              'Permission Caméra Requise',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Veuillez autoriser l\'accès à la caméra pour scanner vos prescriptions.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: Colors.red,
              size: 15.w,
            ),
            SizedBox(height: 3.h),
            Text(
              'Erreur Caméra',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _initializeCamera,
                  child: const Text('Réessayer'),
                ),
                SizedBox(width: 2.w),
                ElevatedButton(
                  onPressed: _selectFromGallery,
                  child: const Text('Galerie'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraState() {
    if (!_isInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        CameraPreview(_cameraController!),

        // Scanning Overlay
        const ScanningOverlayWidget(),

        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery Access
                GalleryAccessWidget(onTap: _selectFromGallery),

                // Capture Button
                CaptureButtonWidget(
                  onTap: _capturePhoto,
                  isEnabled: _isInitialized,
                ),

                // Flash Toggle (mobile only)
                if (!kIsWeb)
                  FlashToggleWidget(
                    isEnabled: _flashEnabled,
                    onTap: _toggleFlash,
                  )
                else
                  SizedBox(width: 15.w), // Placeholder for web
              ],
            ),
          ),
        ),

        // Instructions
        Positioned(
          top: 10.h,
          left: 4.w,
          right: 4.w,
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Positionnez votre prescription dans le cadre et assurez-vous que le texte est lisible',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewState() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image Preview
        if (kIsWeb)
          Image.network(
            _capturedImage!.path,
            fit: BoxFit.contain,
          )
        else
          Image.file(
            File(_capturedImage!.path),
            fit: BoxFit.contain,
          ),

        // Bottom Actions
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _retakePhoto,
                  icon: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: Colors.white,
                    size: 5.w,
                  ),
                  label: const Text('Reprendre'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _processImage(_capturedImage!),
                  icon: CustomIconWidget(
                    iconName: 'check',
                    color: Colors.white,
                    size: 5.w,
                  ),
                  label: const Text('Analyser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
