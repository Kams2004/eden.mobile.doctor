import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../services/theme_service.dart';

class SkeletonLoadingCard extends StatefulWidget {
  const SkeletonLoadingCard({super.key});

  @override
  State<SkeletonLoadingCard> createState() => _SkeletonLoadingCardState();
}

class _SkeletonLoadingCardState extends State<SkeletonLoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
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
    _themeService.removeListener(_onThemeChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Material(
        elevation: 2,
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        shadowColor: _themeService.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonHeader(),
                  SizedBox(height: 2.h),
                  _buildSkeletonContent(),
                  SizedBox(height: 1.5.h),
                  _buildSkeletonDateRow(),
                  SizedBox(height: 1.5.h),
                  _buildSkeletonFooter(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonHeader() {
    return Row(
      children: [
        _buildSkeletonBox(
          width: 20.w,
          height: 4.h,
        ),
        Spacer(),
        _buildSkeletonBox(
          width: 15.w,
          height: 3.h,
        ),
      ],
    );
  }

  Widget _buildSkeletonContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSkeletonBox(
          width: 70.w,
          height: 2.5.h,
        ),
        SizedBox(height: 1.h),
        _buildSkeletonBox(
          width: 40.w,
          height: 2.h,
        ),
      ],
    );
  }

  Widget _buildSkeletonDateRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSkeletonBox(
            width: double.infinity,
            height: 8.h,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildSkeletonBox(
            width: double.infinity,
            height: 8.h,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonFooter() {
    return Row(
      children: [
        _buildSkeletonBox(
          width: 25.w,
          height: 2.h,
        ),
        Spacer(),
        _buildSkeletonBox(
          width: 20.w,
          height: 3.h,
        ),
      ],
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
  }) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[300],
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
