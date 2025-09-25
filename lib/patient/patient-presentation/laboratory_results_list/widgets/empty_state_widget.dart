import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-core/core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback? onActionPressed;
  final bool isSearchResult;

  const EmptyStateWidget({
    super.key,
    this.title = 'Aucun résultat disponible',
    this.subtitle =
        'Il n\'y a pas de résultats de laboratoire à afficher pour le moment.',
    this.actionText = 'Actualiser',
    this.onActionPressed,
    this.isSearchResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: isSearchResult ? 'search_off' : 'science',
                  color: colorScheme.primary.withValues(alpha: 0.6),
                  size: 20.w,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null) ...[
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: CustomIconWidget(
                  iconName: isSearchResult ? 'refresh' : 'refresh',
                  color: colorScheme.onPrimary,
                  size: 5.w,
                ),
                label: Text(actionText),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 2.h,
                  ),
                ),
              ),
            ],
            if (isSearchResult) ...[
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'lightbulb_outline',
                          color: AppTheme.warningLight,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Conseils de recherche:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warningLight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    _buildSearchTip(
                        'Vérifiez l\'orthographe des mots-clés', theme),
                    _buildSearchTip('Utilisez des termes plus généraux', theme),
                    _buildSearchTip('Essayez différentes catégories', theme),
                    _buildSearchTip('Supprimez les filtres actifs', theme),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTip(String tip, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 1.w,
            height: 1.w,
            margin: EdgeInsets.only(top: 1.h, right: 2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
