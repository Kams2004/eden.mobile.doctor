import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../patient-core/core/app_export.dart';
import '../../../../patient-widgets/widgets/custom_icon_widget.dart';

class ReferenceValuesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> referenceData;

  const ReferenceValuesWidget({
    super.key,
    required this.referenceData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Valeurs de référence et explications',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Les valeurs de référence peuvent varier selon l\'âge, le sexe, et d\'autres facteurs. Consultez votre médecin pour une interprétation personnalisée.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 2.h),
          ...referenceData
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
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
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
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'straighten',
                color: colorScheme.primary,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Plage normale: $normalRange',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
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
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                if (ageGroup.isNotEmpty && gender.isNotEmpty) ...[
                  SizedBox(width: 3.w),
                  Text(
                    '•',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(1.w),
              ),
              child: Text(
                explanation,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
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
