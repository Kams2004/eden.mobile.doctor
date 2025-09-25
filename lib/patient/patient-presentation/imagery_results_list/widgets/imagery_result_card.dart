import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../patient-core/core/app_export.dart';

/// Individual imagery result card widget displaying medical imaging examination details
class ImageryResultCard extends StatelessWidget {
  final Map<String, dynamic> imageryResult;
  final VoidCallback? onTap;
  final VoidCallback? onViewImages;
  final VoidCallback? onShareWithDoctor;
  final VoidCallback? onAddToFavorites;
  final VoidCallback? onDownloadReport;

  const ImageryResultCard({
    super.key,
    required this.imageryResult,
    this.onTap,
    this.onViewImages,
    this.onShareWithDoctor,
    this.onAddToFavorites,
    this.onDownloadReport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key('imagery_${imageryResult["id"]}'),
      background: _buildSwipeRightBackground(colorScheme),
      secondaryBackground: _buildSwipeLeftBackground(colorScheme),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onViewImages?.call();
        } else if (direction == DismissDirection.endToStart) {
          onAddToFavorites?.call();
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(colorScheme),
                SizedBox(height: 2.h),
                _buildContent(theme),
                SizedBox(height: 2.h),
                _buildFooter(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeRightBackground(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'visibility',
            color: colorScheme.primary,
            size: 6.w,
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Voir Images',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeLeftBackground(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.successLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'favorite_border',
            color: AppTheme.successLight,
            size: 6.w,
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Favoris',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.successLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    final hasImages = (imageryResult["imageCount"] as int? ?? 0) > 0;

    return Row(
      children: [
        // Thumbnail preview
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: hasImages
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImageWidget(
                    imageUrl: imageryResult["thumbnailUrl"] as String? ??
                        "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
                    width: 15.w,
                    height: 15.w,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: CustomIconWidget(
                    iconName: 'medical_services',
                    color: colorScheme.primary.withValues(alpha: 0.6),
                    size: 6.w,
                  ),
                ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      imageryResult["examinationType"] as String? ??
                          "Examen d'imagerie",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasImages)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${imageryResult["imageCount"]} images',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Text(
                imageryResult["indication"] as String? ??
                    "Indication non spécifiée",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'Technique',
          imageryResult["technique"] as String? ?? "Non spécifiée",
          theme.colorScheme,
        ),
        SizedBox(height: 1.h),
        _buildInfoRow(
          'Date d\'examen',
          imageryResult["examinationDate"] as String? ?? "Non spécifiée",
          theme.colorScheme,
        ),
        if (imageryResult["bodyRegion"] != null) ...[
          SizedBox(height: 1.h),
          _buildInfoRow(
            'Région corporelle',
            imageryResult["bodyRegion"] as String,
            theme.colorScheme,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25.w,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    final status = imageryResult["status"] as String? ?? "completed";
    final statusColor = _getStatusColor(status, colorScheme);
    final statusText = _getStatusText(status);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                statusText,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        PopupMenuButton<String>(
          icon: CustomIconWidget(
            iconName: 'more_vert',
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 5.w,
          ),
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view_images',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'visibility',
                    color: colorScheme.primary,
                    size: 4.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Voir les images',
                    style: GoogleFonts.inter(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'share',
                    color: colorScheme.primary,
                    size: 4.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Partager avec médecin',
                    style: GoogleFonts.inter(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'download',
                    color: colorScheme.primary,
                    size: 4.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Télécharger rapport',
                    style: GoogleFonts.inter(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'favorite',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'favorite_border',
                    color: AppTheme.successLight,
                    size: 4.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Ajouter aux favoris',
                    style: GoogleFonts.inter(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successLight;
      case 'pending':
        return AppTheme.warningLight;
      case 'in_progress':
        return colorScheme.primary;
      default:
        return colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Terminé';
      case 'pending':
        return 'En attente';
      case 'in_progress':
        return 'En cours';
      default:
        return 'Statut inconnu';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'view_images':
        onViewImages?.call();
        break;
      case 'share':
        onShareWithDoctor?.call();
        break;
      case 'download':
        onDownloadReport?.call();
        break;
      case 'favorite':
        onAddToFavorites?.call();
        break;
    }
  }
}