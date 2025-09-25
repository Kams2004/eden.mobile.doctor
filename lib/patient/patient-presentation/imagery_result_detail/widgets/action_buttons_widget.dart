import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onShareImages;
  final VoidCallback? onDownloadReport;
  final VoidCallback? onPrintResults;
  final VoidCallback? onAddToHealthRecords;

  const ActionButtonsWidget({
    super.key,
    this.onShareImages,
    this.onDownloadReport,
    this.onPrintResults,
    this.onAddToHealthRecords,
  });

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Actions disponibles',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            _buildActionTile(
              context,
              icon: 'share',
              title: 'Partager les images',
              subtitle: 'Partager les images médicales',
              onTap: () {
                Navigator.pop(context);
                onShareImages?.call();
              },
            ),
            _buildActionTile(
              context,
              icon: 'download',
              title: 'Télécharger le rapport',
              subtitle: 'Télécharger le rapport complet',
              onTap: () {
                Navigator.pop(context);
                onDownloadReport?.call();
              },
            ),
            _buildActionTile(
              context,
              icon: 'print',
              title: 'Imprimer les résultats',
              subtitle: 'Imprimer le rapport médical',
              onTap: () {
                Navigator.pop(context);
                onPrintResults?.call();
              },
            ),
            _buildActionTile(
              context,
              icon: 'favorite',
              title: 'Ajouter au dossier médical',
              subtitle: 'Sauvegarder dans votre dossier',
              onTap: () {
                Navigator.pop(context);
                onAddToHealthRecords?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color:
              AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showActionSheet(context),
                icon: CustomIconWidget(
                  iconName: 'more_horiz',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 20,
                ),
                label: Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: IconButton(
                onPressed: onDownloadReport,
                icon: CustomIconWidget(
                  iconName: 'download',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                padding: EdgeInsets.all(2.w),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
