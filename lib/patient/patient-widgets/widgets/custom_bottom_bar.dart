import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom BottomNavigationBar widget for healthcare mobile application
/// Implements adaptive navigation with Medical Serenity color palette
class CustomBottomBar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final BottomBarVariant variant;
  final bool showLabels;
  final double? elevation;

  const CustomBottomBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.variant = BottomBarVariant.standard,
    this.showLabels = true,
    this.elevation,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(CustomBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _currentIndex = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.variant == BottomBarVariant.floating) {
      return _buildFloatingBottomBar(context, colorScheme);
    }

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _handleTap,
      type: _getBottomNavigationBarType(),
      backgroundColor: _getBackgroundColor(colorScheme),
      selectedItemColor: _getSelectedItemColor(colorScheme),
      unselectedItemColor: _getUnselectedItemColor(colorScheme),
      elevation: widget.elevation ?? _getElevation(),
      showSelectedLabels: widget.showLabels,
      showUnselectedLabels: widget.showLabels,
      selectedLabelStyle: _getSelectedLabelStyle(),
      unselectedLabelStyle: _getUnselectedLabelStyle(),
      items: _buildBottomNavigationBarItems(),
    );
  }

  Widget _buildFloatingBottomBar(
      BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _handleTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
          elevation: 0,
          showSelectedLabels: widget.showLabels,
          showUnselectedLabels: widget.showLabels,
          selectedLabelStyle: _getSelectedLabelStyle(),
          unselectedLabelStyle: _getUnselectedLabelStyle(),
          items: _buildBottomNavigationBarItems(),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavigationBarItems() {
    return [
      BottomNavigationBarItem(
        icon: _buildIcon(Icons.dashboard_outlined, Icons.dashboard, 0),
        label: 'Dashboard',
        tooltip: 'Patient Dashboard',
      ),
      BottomNavigationBarItem(
        icon: _buildIcon(Icons.science_outlined, Icons.science, 1),
        label: 'Lab Results',
        tooltip: 'Laboratory Results',
      ),
      BottomNavigationBarItem(
        icon: _buildIcon(
            Icons.medical_services_outlined, Icons.medical_services, 2),
        label: 'Imaging',
        tooltip: 'Medical Imaging Results',
      ),
      BottomNavigationBarItem(
        icon: _buildIcon(Icons.person_outline, Icons.person, 3),
        label: 'Profile',
        tooltip: 'Patient Profile',
      ),
    ];
  }

  Widget _buildIcon(IconData outlinedIcon, IconData filledIcon, int index) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.variant == BottomBarVariant.animated) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? 8.0 : 4.0),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Icon(
          isSelected ? filledIcon : outlinedIcon,
          size: isSelected ? 26 : 24,
        ),
      );
    }

    return Icon(
      isSelected ? filledIcon : outlinedIcon,
      size: 24,
    );
  }

  void _handleTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    widget.onTap?.call(index);

    // Navigate to appropriate route based on index
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/patient-dashboard',
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/laboratory-results-list',
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/imagery-results-list',
          (route) => false,
        );
        break;
      case 3:
        // Profile navigation - could be a modal or separate screen
        _showProfileOptions(context);
        break;
    }
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile screen
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to help
              },
            ),
            ListTile(
              leading: Icon(Icons.logout_outlined),
              title: Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                // Handle sign out
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/splash-screen',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarType _getBottomNavigationBarType() {
    switch (widget.variant) {
      case BottomBarVariant.shifting:
        return BottomNavigationBarType.shifting;
      default:
        return BottomNavigationBarType.fixed;
    }
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (widget.variant) {
      case BottomBarVariant.transparent:
        return Colors.transparent;
      case BottomBarVariant.primary:
        return colorScheme.primary;
      default:
        return colorScheme.surface;
    }
  }

  Color _getSelectedItemColor(ColorScheme colorScheme) {
    switch (widget.variant) {
      case BottomBarVariant.primary:
        return colorScheme.onPrimary;
      default:
        return colorScheme.primary;
    }
  }

  Color _getUnselectedItemColor(ColorScheme colorScheme) {
    switch (widget.variant) {
      case BottomBarVariant.primary:
        return colorScheme.onPrimary.withValues(alpha: 0.6);
      default:
        return colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  double _getElevation() {
    switch (widget.variant) {
      case BottomBarVariant.flat:
        return 0.0;
      case BottomBarVariant.elevated:
        return 16.0;
      case BottomBarVariant.floating:
        return 8.0;
      default:
        return 8.0;
    }
  }

  TextStyle _getSelectedLabelStyle() {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
    );
  }

  TextStyle _getUnselectedLabelStyle() {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    );
  }
}

/// Enum defining different BottomBar variants for healthcare application
enum BottomBarVariant {
  standard, // Default bottom navigation
  primary, // Primary color background
  flat, // No elevation
  elevated, // High elevation
  floating, // Floating with rounded corners
  transparent, // Transparent background
  shifting, // Shifting type navigation
  animated, // Animated icons and containers
}
