import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-core/core/app_export.dart';
import '../../../patient-widgets/widgets/custom_icon_widget.dart';
import '../../../../services/theme_service.dart';

class ReferenceValuesWidget extends StatefulWidget {
  final List<Map<String, dynamic>> referenceData;

  const ReferenceValuesWidget({
    super.key,
    required this.referenceData,
  });

  @override
  State<ReferenceValuesWidget> createState() => _ReferenceValuesWidgetState();
}

class _ReferenceValuesWidgetState extends State<ReferenceValuesWidget> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: _themeService.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Valeurs de référence et explications',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Les valeurs de référence peuvent varier selon l\'âge, le sexe, et d\'autres facteurs. Consultez votre médecin pour une interprétation personnalisée.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 2.h),
          ...widget.referenceData
              .map((reference) => _buildReferenceItem(context, reference)),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(
      BuildContext context, Map<String, dynamic> reference) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final testName = (reference['testName'] as String?) ?? 'Test non spécifié';
    final normalRange = (reference['normalRange'] as String?) ?? 'N/A';
    final explanation = (reference['explanation'] as String?) ?? '';
    final ageGroup = (reference['ageGroup'] as String?) ?? '';
    final gender = (reference['gender'] as String?) ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF374151) : Color(0xFF3B82F6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: _themeService.isDarkMode ? Color(0xFF4B5563) : Color(0xFF3B82F6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            testName,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'straighten',
                color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Plage normale: $normalRange',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (ageGroup.isNotEmpty || gender.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                if (ageGroup.isNotEmpty) ...[
                  CustomIconWidget(
                    iconName: 'person',
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 4.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    ageGroup,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                    ),
                  ),
                ],
                if (ageGroup.isNotEmpty && gender.isNotEmpty) ...[
                  SizedBox(width: 3.w),
                  Text(
                    '•',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 3.w),
                ],
                if (gender.isNotEmpty) ...[
                  CustomIconWidget(
                    iconName:
                        gender.toLowerCase() == 'homme' ? 'male' : 'female',
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 4.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    gender,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (explanation.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(1.w),
              ),
              child: Text(
                explanation,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}