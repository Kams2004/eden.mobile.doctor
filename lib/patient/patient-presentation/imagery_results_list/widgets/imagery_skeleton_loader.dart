import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Skeleton loader widget for imagery results loading state
class ImagerySkeletonLoader extends StatefulWidget {
  final int itemCount;

  const ImagerySkeletonLoader({
    super.key,
    this.itemCount = 5,
  });

  @override
  State<ImagerySkeletonLoader> createState() => _ImagerySkeletonLoaderState();
}

class _ImagerySkeletonLoaderState extends State<ImagerySkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => _buildSkeletonCard(colorScheme),
      ),
    );
  }

  Widget _buildSkeletonCard(ColorScheme colorScheme) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSkeletonHeader(colorScheme),
            SizedBox(height: 2.h),
            _buildSkeletonContent(colorScheme),
            SizedBox(height: 2.h),
            _buildSkeletonFooter(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        // Thumbnail skeleton
        _buildSkeletonBox(
          width: 15.w,
          height: 15.w,
          borderRadius: 8,
          colorScheme: colorScheme,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSkeletonBox(
                      width: double.infinity,
                      height: 2.h,
                      borderRadius: 4,
                      colorScheme: colorScheme,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  _buildSkeletonBox(
                    width: 15.w,
                    height: 2.h,
                    borderRadius: 12,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              _buildSkeletonBox(
                width: 70.w,
                height: 1.5.h,
                borderRadius: 4,
                colorScheme: colorScheme,
              ),
              SizedBox(height: 0.5.h),
              _buildSkeletonBox(
                width: 50.w,
                height: 1.5.h,
                borderRadius: 4,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonContent(ColorScheme colorScheme) {
    return Column(
      children: List.generate(
          3,
          (index) => Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonBox(
                      width: 25.w,
                      height: 1.5.h,
                      borderRadius: 4,
                      colorScheme: colorScheme,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildSkeletonBox(
                        width: double.infinity,
                        height: 1.5.h,
                        borderRadius: 4,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),
              )),
    );
  }

  Widget _buildSkeletonFooter(ColorScheme colorScheme) {
    return Row(
      children: [
        _buildSkeletonBox(
          width: 20.w,
          height: 3.h,
          borderRadius: 8,
          colorScheme: colorScheme,
        ),
        Spacer(),
        _buildSkeletonBox(
          width: 6.w,
          height: 6.w,
          borderRadius: 3.w,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    required double borderRadius,
    required ColorScheme colorScheme,
  }) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
