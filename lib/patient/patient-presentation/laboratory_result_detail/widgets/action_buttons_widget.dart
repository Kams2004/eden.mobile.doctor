import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-core/core/app_export.dart';
import '../../../patient-widgets/widgets/custom_icon_widget.dart';

class ActionButtonsWidget extends StatelessWidget {
  final Map<String, dynamic> resultData;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;
  final VoidCallback? onExport;

  const ActionButtonsWidget({
    super.key,
    required this.resultData,
    this.onShare,
    this.onPrint,
    this.onExport,
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
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Partager',
                  'share',
                  colorScheme.primary,
                  () => _handleShare(context),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Imprimer',
                  'print',
                  colorScheme.secondary,
                  () => _handlePrint(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              context,
              'Exporter vers l\'app Santé',
              'health_and_safety',
              Colors.green,
              () => _handleExport(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    String iconName,
    Color color,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: Colors.white,
            size: 5.w,
          ),
          SizedBox(width: 2.w),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleShare(BuildContext context) {
    if (onShare != null) {
      onShare!();
    } else {
      _showActionDialog(
        context,
        'Partager le rapport',
        'Choisissez comment partager ce rapport médical avec votre professionnel de santé.',
        [
          _DialogAction('Email sécurisé', Icons.email, () {
            Navigator.pop(context);
            _showSnackBar(context, 'Envoi par email sécurisé en cours...');
          }),
          _DialogAction('Application médicale', Icons.medical_services, () {
            Navigator.pop(context);
            _showSnackBar(context, 'Partage vers l\'application médicale...');
          }),
          _DialogAction('Copier le lien', Icons.link, () {
            Navigator.pop(context);
            _showSnackBar(
                context, 'Lien sécurisé copié dans le presse-papiers');
          }),
        ],
      );
    }
  }

  void _handlePrint(BuildContext context) {
    if (onPrint != null) {
      onPrint!();
    } else {
      _showActionDialog(
        context,
        'Imprimer le rapport',
        'Sélectionnez les options d\'impression pour votre rapport médical.',
        [
          _DialogAction('Impression complète', Icons.print, () {
            Navigator.pop(context);
            _showSnackBar(context, 'Préparation de l\'impression complète...');
          }),
          _DialogAction('Résumé seulement', Icons.summarize, () {
            Navigator.pop(context);
            _showSnackBar(context, 'Préparation du résumé pour impression...');
          }),
          _DialogAction('Enregistrer en PDF', Icons.picture_as_pdf, () {
            Navigator.pop(context);
            _showSnackBar(context, 'Génération du PDF en cours...');
          }),
        ],
      );
    }
  }

  void _handleExport(BuildContext context) {
    if (onExport != null) {
      onExport!();
    } else {
      _showActionDialog(
        context,
        'Exporter vers l\'app Santé',
        'Ajoutez ces résultats à votre dossier de santé personnel pour un suivi continu.',
        [
          _DialogAction('Apple Health (iOS)', Icons.favorite, () {
            Navigator.pop(context);
            _showSnackBar(context, 'Export vers Apple Health en cours...');
          }),
          _DialogAction('Google Fit (Android)', Icons.fitness_center, () {
            Navigator.pop(context);
            _showSnackBar(context, 'Export vers Google Fit en cours...');
          }),
          _DialogAction('Dossier médical local', Icons.folder_special, () {
            Navigator.pop(context);
            _showSnackBar(
                context, 'Sauvegarde dans le dossier médical local...');
          }),
        ],
      );
    }
  }

  void _showActionDialog(
    BuildContext context,
    String title,
    String description,
    List<_DialogAction> actions,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 2.h),
            ...actions.map((action) => Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: ListTile(
                    leading: CustomIconWidget(
                      iconName: action.icon.toString().split('.').last,
                      color: colorScheme.primary,
                      size: 5.w,
                    ),
                    title: Text(
                      action.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: action.onTap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    tileColor: colorScheme.primary.withValues(alpha: 0.05),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }
}

class _DialogAction {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _DialogAction(this.title, this.icon, this.onTap);
}
