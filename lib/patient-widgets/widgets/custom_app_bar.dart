import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget for healthcare mobile application
/// Implements Clinical Minimalism design with Medical Serenity color palette
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final AppBarVariant variant;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.variant = AppBarVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: _getTitleStyle(theme, variant),
      ),
      actions: _buildActions(context),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      elevation: elevation ?? _getElevation(variant),
      backgroundColor:
          backgroundColor ?? _getBackgroundColor(colorScheme, variant),
      foregroundColor:
          foregroundColor ?? _getForegroundColor(colorScheme, variant),
      bottom: bottom,
      shape: variant == AppBarVariant.elevated
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16.0),
              ),
            )
          : null,
      flexibleSpace: variant == AppBarVariant.gradient
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions != null) return actions;

    // Default actions for healthcare app
    return [
      IconButton(
        icon: Icon(Icons.notifications_outlined),
        onPressed: () {
          // Navigate to notifications or show notification panel
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notifications feature coming soon'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        tooltip: 'Notifications',
      ),
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert),
        onSelected: (value) => _handleMenuSelection(context, value),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person_outline, size: 20),
                SizedBox(width: 12),
                Text('Profile'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings_outlined, size: 20),
                SizedBox(width: 12),
                Text('Settings'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'help',
            child: Row(
              children: [
                Icon(Icons.help_outline, size: 20),
                SizedBox(width: 12),
                Text('Help & Support'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        // Navigate to profile or show profile options
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile feature coming soon')),
        );
        break;
      case 'settings':
        // Navigate to settings
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Settings feature coming soon')),
        );
        break;
      case 'help':
        // Navigate to help & support
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Help & Support feature coming soon')),
        );
        break;
    }
  }

  TextStyle _getTitleStyle(ThemeData theme, AppBarVariant variant) {
    final baseStyle = GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    );

    switch (variant) {
      case AppBarVariant.large:
        return baseStyle.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        );
      case AppBarVariant.compact:
        return baseStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        );
      default:
        return baseStyle;
    }
  }

  double _getElevation(AppBarVariant variant) {
    switch (variant) {
      case AppBarVariant.flat:
        return 0.0;
      case AppBarVariant.elevated:
        return 8.0;
      case AppBarVariant.large:
        return 4.0;
      default:
        return 2.0;
    }
  }

  Color _getBackgroundColor(ColorScheme colorScheme, AppBarVariant variant) {
    switch (variant) {
      case AppBarVariant.primary:
        return colorScheme.primary;
      case AppBarVariant.surface:
        return colorScheme.surface;
      case AppBarVariant.transparent:
        return Colors.transparent;
      default:
        return colorScheme.surface;
    }
  }

  Color _getForegroundColor(ColorScheme colorScheme, AppBarVariant variant) {
    switch (variant) {
      case AppBarVariant.primary:
        return colorScheme.onPrimary;
      case AppBarVariant.surface:
        return colorScheme.onSurface;
      case AppBarVariant.transparent:
        return colorScheme.onSurface;
      default:
        return colorScheme.onSurface;
    }
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    if (variant == AppBarVariant.large) {
      height += 20; // Additional height for large variant
    }
    return Size.fromHeight(height);
  }
}

/// Enum defining different AppBar variants for healthcare application
enum AppBarVariant {
  standard, // Default medical app bar
  primary, // Primary color background
  surface, // Surface color background
  flat, // No elevation
  elevated, // High elevation with rounded bottom
  large, // Larger height and text
  compact, // Smaller height and text
  transparent, // Transparent background
  gradient, // Gradient background
}
