import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom TabBar widget for healthcare mobile application
/// Implements medical data categorization with Clinical Minimalism design
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController? controller;
  final Function(int)? onTap;
  final TabBarVariant variant;
  final bool isScrollable;
  final EdgeInsetsGeometry? labelPadding;
  final Color? indicatorColor;
  final double? indicatorWeight;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.variant = TabBarVariant.standard,
    this.isScrollable = false,
    this.labelPadding,
    this.indicatorColor,
    this.indicatorWeight,
  });

  /// Factory constructor for medical result categories
  factory CustomTabBar.medicalResults({
    Key? key,
    TabController? controller,
    Function(int)? onTap,
    TabBarVariant variant = TabBarVariant.standard,
  }) {
    return CustomTabBar(
      key: key,
      tabs: ['All Results', 'Lab Tests', 'Imaging', 'Reports'],
      controller: controller,
      onTap: onTap,
      variant: variant,
      isScrollable: true,
    );
  }

  /// Factory constructor for laboratory test categories
  factory CustomTabBar.laboratoryCategories({
    Key? key,
    TabController? controller,
    Function(int)? onTap,
    TabBarVariant variant = TabBarVariant.standard,
  }) {
    return CustomTabBar(
      key: key,
      tabs: ['Blood Work', 'Urine Tests', 'Cultures', 'Chemistry'],
      controller: controller,
      onTap: onTap,
      variant: variant,
      isScrollable: true,
    );
  }

  /// Factory constructor for imaging categories
  factory CustomTabBar.imagingCategories({
    Key? key,
    TabController? controller,
    Function(int)? onTap,
    TabBarVariant variant = TabBarVariant.standard,
  }) {
    return CustomTabBar(
      key: key,
      tabs: ['X-Ray', 'MRI', 'CT Scan', 'Ultrasound'],
      controller: controller,
      onTap: onTap,
      variant: variant,
      isScrollable: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (variant == TabBarVariant.segmented) {
      return _buildSegmentedTabBar(context, colorScheme);
    }

    if (variant == TabBarVariant.pills) {
      return _buildPillTabBar(context, colorScheme);
    }

    return TabBar(
      controller: controller,
      onTap: onTap,
      tabs: _buildTabs(),
      isScrollable: isScrollable,
      labelPadding: labelPadding ?? _getLabelPadding(),
      labelColor: _getLabelColor(colorScheme),
      unselectedLabelColor: _getUnselectedLabelColor(colorScheme),
      labelStyle: _getLabelStyle(),
      unselectedLabelStyle: _getUnselectedLabelStyle(),
      indicator: _buildIndicator(colorScheme),
      indicatorColor: indicatorColor ?? _getIndicatorColor(colorScheme),
      indicatorWeight: indicatorWeight ?? _getIndicatorWeight(),
      indicatorSize: _getIndicatorSize(),
      dividerColor: _getDividerColor(colorScheme),
      overlayColor: _getOverlayColor(colorScheme),
      splashFactory: variant == TabBarVariant.minimal
          ? NoSplash.splashFactory
          : InkRipple.splashFactory,
    );
  }

  Widget _buildSegmentedTabBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        tabs: _buildTabs(),
        isScrollable: isScrollable,
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurface,
        labelStyle: _getLabelStyle(),
        unselectedLabelStyle: _getUnselectedLabelStyle(),
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(8.0),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
      ),
    );
  }

  Widget _buildPillTabBar(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = controller?.index == index;
          return Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                controller?.animateTo(index);
                onTap?.call(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildTabs() {
    return tabs
        .map((tab) => Tab(
              text: tab,
              height: _getTabHeight(),
            ))
        .toList();
  }

  EdgeInsetsGeometry _getLabelPadding() {
    switch (variant) {
      case TabBarVariant.compact:
        return const EdgeInsets.symmetric(horizontal: 8.0);
      case TabBarVariant.spacious:
        return const EdgeInsets.symmetric(horizontal: 24.0);
      default:
        return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  Color _getLabelColor(ColorScheme colorScheme) {
    switch (variant) {
      case TabBarVariant.primary:
        return colorScheme.primary;
      case TabBarVariant.surface:
        return colorScheme.onSurface;
      default:
        return colorScheme.primary;
    }
  }

  Color _getUnselectedLabelColor(ColorScheme colorScheme) {
    return colorScheme.onSurface.withValues(alpha: 0.6);
  }

  TextStyle _getLabelStyle() {
    final fontSize = variant == TabBarVariant.compact ? 12.0 : 14.0;
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    );
  }

  TextStyle _getUnselectedLabelStyle() {
    final fontSize = variant == TabBarVariant.compact ? 12.0 : 14.0;
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
    );
  }

  Decoration? _buildIndicator(ColorScheme colorScheme) {
    switch (variant) {
      case TabBarVariant.rounded:
        return BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(4.0),
        );
      case TabBarVariant.minimal:
        return BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2.0),
        );
      default:
        return null; // Use default indicator
    }
  }

  Color _getIndicatorColor(ColorScheme colorScheme) {
    switch (variant) {
      case TabBarVariant.accent:
        return colorScheme.secondary;
      default:
        return colorScheme.primary;
    }
  }

  double _getIndicatorWeight() {
    switch (variant) {
      case TabBarVariant.thick:
        return 4.0;
      case TabBarVariant.minimal:
        return 1.0;
      default:
        return 2.0;
    }
  }

  TabBarIndicatorSize _getIndicatorSize() {
    switch (variant) {
      case TabBarVariant.fullWidth:
        return TabBarIndicatorSize.tab;
      default:
        return TabBarIndicatorSize.label;
    }
  }

  Color _getDividerColor(ColorScheme colorScheme) {
    switch (variant) {
      case TabBarVariant.minimal:
        return Colors.transparent;
      default:
        return colorScheme.outline.withValues(alpha: 0.2);
    }
  }

  WidgetStateProperty<Color?> _getOverlayColor(ColorScheme colorScheme) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return colorScheme.primary.withValues(alpha: 0.1);
      }
      if (states.contains(WidgetState.hovered)) {
        return colorScheme.primary.withValues(alpha: 0.05);
      }
      return null;
    });
  }

  double _getTabHeight() {
    switch (variant) {
      case TabBarVariant.compact:
        return 40.0;
      case TabBarVariant.spacious:
        return 56.0;
      default:
        return 48.0;
    }
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(_getTabHeight());
  }
}

/// Enum defining different TabBar variants for healthcare application
enum TabBarVariant {
  standard, // Default medical tab bar
  primary, // Primary color labels
  surface, // Surface color labels
  accent, // Accent color indicator
  compact, // Smaller padding and height
  spacious, // Larger padding and height
  minimal, // Minimal styling with thin indicator
  thick, // Thick indicator
  rounded, // Rounded indicator
  fullWidth, // Full width indicator
  segmented, // Segmented control style
  pills, // Pill-shaped tabs
}
