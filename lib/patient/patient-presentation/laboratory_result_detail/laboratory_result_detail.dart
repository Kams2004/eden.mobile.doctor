import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-core/core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/analysis_category_widget.dart';
import './widgets/reference_values_widget.dart';
import './widgets/result_header_widget.dart';

class LaboratoryResultDetail extends StatefulWidget {
  const LaboratoryResultDetail({super.key});

  @override
  State<LaboratoryResultDetail> createState() => _LaboratoryResultDetailState();
}

class _LaboratoryResultDetailState extends State<LaboratoryResultDetail> {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;

  // Mock data for laboratory result detail
  final Map<String, dynamic> mockResultData = {
    "id": "LAB_2025_001",
    "testName": "Bilan sanguin complet avec formule",
    "orderNumber": "ORD-2025-08-001",
    "emissionDate": "26/08/2025",
    "resultDate": "28/08/2025",
    "duration": "2 jours",
    "examinationActs":
        "Analyses sanguines complètes, numération formule sanguine, biochimie",
    "status": "completed",
    "categories": [
      {
        "categoryName": "BIOCHIMIE",
        "analyses": [
          {
            "testName": "Glucose",
            "result": "5.2",
            "unit": "mmol/L",
            "referenceRange": "3.9 - 6.1 mmol/L",
            "status": "normal"
          },
          {
            "testName": "Créatinine",
            "result": "95",
            "unit": "μmol/L",
            "referenceRange": "62 - 106 μmol/L",
            "status": "normal"
          },
          {
            "testName": "Urée",
            "result": "7.8",
            "unit": "mmol/L",
            "referenceRange": "2.5 - 7.5 mmol/L",
            "status": "high"
          }
        ]
      },
      {
        "categoryName": "TRANSAMINASES",
        "analyses": [
          {
            "testName": "ALAT (GPT)",
            "result": "28",
            "unit": "UI/L",
            "referenceRange": "< 35 UI/L",
            "status": "normal"
          },
          {
            "testName": "ASAT (GOT)",
            "result": "32",
            "unit": "UI/L",
            "referenceRange": "< 35 UI/L",
            "status": "normal"
          }
        ]
      },
      {
        "categoryName": "LIPIDES",
        "analyses": [
          {
            "testName": "Cholestérol total",
            "result": "6.2",
            "unit": "mmol/L",
            "referenceRange": "< 5.2 mmol/L",
            "status": "high"
          },
          {
            "testName": "HDL Cholestérol",
            "result": "1.1",
            "unit": "mmol/L",
            "referenceRange": "> 1.0 mmol/L",
            "status": "normal"
          },
          {
            "testName": "LDL Cholestérol",
            "result": "4.8",
            "unit": "mmol/L",
            "referenceRange": "< 3.4 mmol/L",
            "status": "high"
          },
          {
            "testName": "Triglycérides",
            "result": "1.8",
            "unit": "mmol/L",
            "referenceRange": "< 1.7 mmol/L",
            "status": "high"
          }
        ]
      },
      {
        "categoryName": "HÉMATOLOGIE",
        "analyses": [
          {
            "testName": "Hémoglobine",
            "result": "14.2",
            "unit": "g/dL",
            "referenceRange": "12.0 - 16.0 g/dL",
            "status": "normal"
          },
          {
            "testName": "Hématocrite",
            "result": "42.5",
            "unit": "%",
            "referenceRange": "36.0 - 48.0 %",
            "status": "normal"
          },
          {
            "testName": "Leucocytes",
            "result": "6.8",
            "unit": "10³/μL",
            "referenceRange": "4.0 - 10.0 10³/μL",
            "status": "normal"
          },
          {
            "testName": "Plaquettes",
            "result": "285",
            "unit": "10³/μL",
            "referenceRange": "150 - 450 10³/μL",
            "status": "normal"
          }
        ]
      }
    ]
  };

  final List<Map<String, dynamic>> mockReferenceData = [
    {
      "testName": "Glucose",
      "normalRange": "3.9 - 6.1 mmol/L",
      "ageGroup": "Adulte",
      "gender": "Tous",
      "explanation":
          "Le glucose sanguin mesure le taux de sucre dans le sang. Des valeurs élevées peuvent indiquer un diabète ou un prédiabète."
    },
    {
      "testName": "Cholestérol total",
      "normalRange": "< 5.2 mmol/L",
      "ageGroup": "Adulte",
      "gender": "Tous",
      "explanation":
          "Le cholestérol total comprend le bon (HDL) et le mauvais (LDL) cholestérol. Un taux élevé augmente le risque cardiovasculaire."
    },
    {
      "testName": "Créatinine",
      "normalRange": "62 - 106 μmol/L (Homme), 53 - 97 μmol/L (Femme)",
      "ageGroup": "Adulte",
      "gender": "Variable",
      "explanation":
          "La créatinine est un marqueur de la fonction rénale. Des valeurs élevées peuvent indiquer une insuffisance rénale."
    },
    {
      "testName": "Hémoglobine",
      "normalRange": "13.0 - 17.0 g/dL (Homme), 12.0 - 16.0 g/dL (Femme)",
      "ageGroup": "Adulte",
      "gender": "Variable",
      "explanation":
          "L'hémoglobine transporte l'oxygène dans le sang. Des valeurs basses peuvent indiquer une anémie."
    }
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showFloatingButton) {
      setState(() {
        _showFloatingButton = true;
      });
    } else if (_scrollController.offset <= 200 && _showFloatingButton) {
      setState(() {
        _showFloatingButton = false;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        title: Text(
          'Détail du résultat',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showOptionsMenu(context),
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background watermark
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomImageWidget(
                imageUrl:
                    "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Result header
                ResultHeaderWidget(resultData: mockResultData),

                SizedBox(height: 3.h),

                // Section title
                Text(
                  'Résultats d\'analyses',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 2.h),

                // Analysis categories
                ...(mockResultData['categories'] as List<Map<String, dynamic>>)
                    .map((category) {
                  return AnalysisCategoryWidget(
                    categoryName: category['categoryName'] as String,
                    analyses: (category['analyses'] as List)
                        .cast<Map<String, dynamic>>(),
                    initiallyExpanded: true,
                  );
                }),

                SizedBox(height: 3.h),

                // Reference values section
                Text(
                  'Informations de référence',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 2.h),

                ReferenceValuesWidget(referenceData: mockReferenceData),

                SizedBox(height: 3.h),

                // Action buttons
                ActionButtonsWidget(
                  resultData: mockResultData,
                  onShare: () => _handleShare(context),
                  onPrint: () => _handlePrint(context),
                  onExport: () => _handleExport(context),
                ),

                SizedBox(height: 2.h),

                // Medical disclaimer
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'medical_services',
                            color: colorScheme.primary,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Avis médical important',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Ces résultats doivent être interprétés par un professionnel de santé. En cas de questions ou de préoccupations, consultez votre médecin traitant.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h), // Extra space for bottom navigation
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showFloatingButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: colorScheme.primary,
              child: CustomIconWidget(
                iconName: 'keyboard_arrow_up',
                color: colorScheme.onPrimary,
                size: 6.w,
              ),
            )
          : null,
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(0.25.h),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Options du rapport',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            _buildMenuOption(
              context,
              'Télécharger PDF',
              'file_download',
              () {
                Navigator.pop(context);
                _showSnackBar(context, 'Téléchargement du PDF en cours...');
              },
            ),
            _buildMenuOption(
              context,
              'Ajouter aux favoris',
              'favorite_border',
              () {
                Navigator.pop(context);
                _showSnackBar(context, 'Ajouté aux favoris');
              },
            ),
            _buildMenuOption(
              context,
              'Programmer un rappel',
              'schedule',
              () {
                Navigator.pop(context);
                _showSnackBar(context, 'Rappel programmé');
              },
            ),
            _buildMenuOption(
              context,
              'Contacter le laboratoire',
              'phone',
              () {
                Navigator.pop(context);
                _showSnackBar(context, 'Ouverture des contacts...');
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: colorScheme.primary,
        size: 5.w,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.w),
      ),
    );
  }

  void _handleShare(BuildContext context) {
    _showSnackBar(context, 'Partage du rapport médical...');
  }

  void _handlePrint(BuildContext context) {
    _showSnackBar(context, 'Préparation de l\'impression...');
  }

  void _handleExport(BuildContext context) {
    _showSnackBar(context, 'Export vers l\'application Santé...');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }
}
