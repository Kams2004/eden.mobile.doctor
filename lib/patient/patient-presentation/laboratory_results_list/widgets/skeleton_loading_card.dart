import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SkeletonLoadingCard extends StatefulWidget {
  const SkeletonLoadingCard({super.key});

  @override
  State<SkeletonLoadingCard> createState() => _SkeletonLoadingCardState();
}

class _SkeletonLoadingCardState extends State<SkeletonLoadingCard>
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
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonHeader(colorScheme),
                  SizedBox(height: 2.h),
                  _buildSkeletonContent(colorScheme),
                  SizedBox(height: 1.5.h),
                  _buildSkeletonDateRow(colorScheme),
                  SizedBox(height: 1.5.h),
                  _buildSkeletonFooter(colorScheme),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        _buildSkeletonBox(
          width: 20.w,
          height: 4.h,
          colorScheme: colorScheme,
        ),
        Spacer(),
        _buildSkeletonBox(
          width: 15.w,
          height: 3.h,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildSkeletonContent(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSkeletonBox(
          width: 70.w,
          height: 2.5.h,
          colorScheme: colorScheme,
        ),
        SizedBox(height: 1.h),
        _buildSkeletonBox(
          width: 40.w,
          height: 2.h,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildSkeletonDateRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildSkeletonBox(
            width: double.infinity,
            height: 8.h,
            colorScheme: colorScheme,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildSkeletonBox(
            width: double.infinity,
            height: 8.h,
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonFooter(ColorScheme colorScheme) {
    return Row(
      children: [
        _buildSkeletonBox(
          width: 25.w,
          height: 2.h,
          colorScheme: colorScheme,
        ),
        Spacer(),
        _buildSkeletonBox(
          width: 20.w,
          height: 3.h,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    required ColorScheme colorScheme,
  }) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
