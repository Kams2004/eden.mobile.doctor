import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../patient-core/core/app_export.dart';
import '../../../../patient-widgets/widgets/custom_icon_widget.dart';

class CategorySectionHeader extends StatefulWidget {
  final String categoryName;
  final int resultCount;
  final bool isExpanded;
  final VoidCallback onToggle;

  const CategorySectionHeader({
    super.key,
    required this.categoryName,
    required this.resultCount,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<CategorySectionHeader> createState() => _CategorySectionHeaderState();
}

class _CategorySectionHeaderState extends State<CategorySectionHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CategorySectionHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: _getCategoryIcon(widget.categoryName),
                    color: colorScheme.primary,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoryName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        "${widget.resultCount} résultat${widget.resultCount > 1 ? 's' : ''}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${widget.resultCount}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 3.14159,
                      child: CustomIconWidget(
                        iconName: 'keyboard_arrow_down',
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 6.w,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryIcon(String categoryName) {
    switch (categoryName.toUpperCase()) {
      case 'BIOCHIMIE':
        return 'biotech';
      case 'TRANSAMINASES':
        return 'local_hospital';
      case 'HÉMATOLOGIE':
        return 'water_drop';
      case 'IMMUNOLOGIE':
        return 'shield';
      case 'MICROBIOLOGIE':
        return 'coronavirus';
      case 'ENDOCRINOLOGIE':
        return 'psychology';
      case 'CARDIOLOGIE':
        return 'favorite';
      case 'NÉPHROLOGIE':
        return 'kidney';
      case 'GASTROENTÉROLOGIE':
        return 'restaurant';
      case 'NEUROLOGIE':
        return 'psychology_alt';
      default:
        return 'science';
    }
  }
}
