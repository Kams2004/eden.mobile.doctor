import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-core/core/app_export.dart';
import '../../../patient-widgets/widgets/custom_icon_widget.dart';

class AnalysisCategoryWidget extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> analyses;
  final bool initiallyExpanded;

  const AnalysisCategoryWidget({
    super.key,
    required this.categoryName,
    required this.analyses,
    this.initiallyExpanded = true,
  });

  @override
  State<AnalysisCategoryWidget> createState() => _AnalysisCategoryWidgetState();
}

class _AnalysisCategoryWidgetState extends State<AnalysisCategoryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.vertical(top: Radius.circular(3.w)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: _isExpanded
                    ? BorderRadius.vertical(top: Radius.circular(3.w))
                    : BorderRadius.circular(3.w),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.categoryName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: colorScheme.primary,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: widget.analyses.map((analysis) {
                  return _buildAnalysisItem(context, analysis);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(
      BuildContext context, Map<String, dynamic> analysis) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final testName = (analysis['testName'] as String?) ?? 'Test non spécifié';
    final result = (analysis['result'] as String?) ?? 'N/A';
    final unit = (analysis['unit'] as String?) ?? '';
    final referenceRange = (analysis['referenceRange'] as String?) ?? 'N/A';
    final status = (analysis['status'] as String?)?.toLowerCase() ?? 'normal';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(status, colorScheme),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: _getStatusBorderColor(status, colorScheme),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  testName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(status, colorScheme),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: _getStatusIcon(status),
                      color: Colors.white,
                      size: 3.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _getStatusText(status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résultat',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '$result ${unit.isNotEmpty ? unit : ''}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getResultTextColor(status, colorScheme),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valeurs de référence',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      referenceRange,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'high':
        return Colors.red;
      case 'low':
        return Colors.orange;
      case 'critical':
        return Colors.red.shade700;
      default:
        return Colors.green;
    }
  }

  Color _getStatusBackgroundColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'high':
        return Colors.red.withValues(alpha: 0.05);
      case 'low':
        return Colors.orange.withValues(alpha: 0.05);
      case 'critical':
        return Colors.red.withValues(alpha: 0.1);
      default:
        return Colors.green.withValues(alpha: 0.05);
    }
  }

  Color _getStatusBorderColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'high':
        return Colors.red.withValues(alpha: 0.2);
      case 'low':
        return Colors.orange.withValues(alpha: 0.2);
      case 'critical':
        return Colors.red.withValues(alpha: 0.3);
      default:
        return Colors.green.withValues(alpha: 0.2);
    }
  }

  Color _getResultTextColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'high':
      case 'critical':
        return Colors.red.shade700;
      case 'low':
        return Colors.orange.shade700;
      default:
        return colorScheme.onSurface;
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'high':
        return 'trending_up';
      case 'low':
        return 'trending_down';
      case 'critical':
        return 'warning';
      default:
        return 'check_circle';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'high':
        return 'Élevé';
      case 'low':
        return 'Bas';
      case 'critical':
        return 'Critique';
      default:
        return 'Normal';
    }
  }
}
