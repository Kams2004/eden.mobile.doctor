import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


import '../../../patient-theme/theme/app_theme.dart';
import '../../../patient-widgets/widgets/custom_icon_widget.dart';
import '../../../patient-widgets/widgets/custom_image_widget.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/image_gallery_widget.dart';
import './widgets/medical_image_viewer_widget.dart';
import './widgets/medical_section_widget.dart';
import './widgets/section_navigation_widget.dart';

class ImageryResultDetail extends StatefulWidget {
  const ImageryResultDetail({super.key});

  @override
  State<ImageryResultDetail> createState() => _ImageryResultDetailState();
}

class _ImageryResultDetailState extends State<ImageryResultDetail>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late ScrollController _sectionScrollController;
  late TabController _tabController;

  int _currentImageIndex = 0;
  int _currentSection = 0;

  final List<String> _sections = [
    'Indication',
    'Technique',
    'Résultats',
    'Conclusion'
  ];
  final List<GlobalKey> _sectionKeys = List.generate(4, (index) => GlobalKey());

  // Mock data for imagery result
  final Map<String, dynamic> imageryResult = {
    "id": "IMG_2024_001",
    "patientName": "Marie Dubois",
    "examinationType": "IRM Cérébrale",
    "completionDate": "28/08/2024",
    "orderNumber": "ORD-IMG-2024-0892",
    "requestingPhysician": "Dr. Laurent Moreau",
    "radiologist": "Dr. Sophie Bernard",
    "images": [
      "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "https://images.unsplash.com/photo-1612277795421-9bc7706a4a34?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3"
    ],
    "indication": {
      "content":
          """Céphalées chroniques persistantes depuis 3 mois, associées à des troubles visuels intermittents. 
      Le patient présente également des épisodes de vertiges et une sensation de pression intracrânienne. 
      Examen clinique neurologique normal. Recherche d'une étiologie structurelle.""",
      "technicalDetails":
          """Indication médicale précise : R51 - Céphalée. Antécédents : Hypertension artérielle contrôlée. 
      Traitement actuel : Amlodipine 5mg/jour. Allergies : Aucune connue.""",
      "keyFindings": [
        "Céphalées chroniques > 3 mois",
        "Troubles visuels intermittents",
        "Vertiges associés",
        "Examen neurologique normal"
      ]
    },
    "technique": {
      "content":
          """IRM cérébrale réalisée sur appareil 3 Tesla avec injection de produit de contraste gadoliné. 
      Séquences T1, T2, FLAIR, diffusion et T1 après injection dans les trois plans de l'espace. 
      Épaisseur de coupe : 5mm. Temps d'acquisition total : 45 minutes.""",
      "technicalDetails": """Paramètres techniques détaillés :
      - Appareil : Siemens Magnetom Vida 3T
      - Antenne : Head/Neck 64 canaux
      - Séquences : T1 SE, T2 TSE, FLAIR, DWI, T1 Gd+
      - Résolution : 0.5 x 0.5 x 5mm
      - Produit de contraste : Dotarem 0.2ml/kg IV"""
    },
    "results": {
      "content":
          """L'examen révèle une morphologie cérébrale normale pour l'âge. 
      Les structures de la ligne médiane sont en place. Le système ventriculaire présente une taille normale. 
      Absence de lésion expansive intracrânienne. Le parenchyme cérébral ne présente pas d'anomalie de signal. 
      Les espaces sous-arachnoïdiens sont de taille normale. Absence de collection extra-axiale.""",
      "keyFindings": [
        "Morphologie cérébrale normale",
        "Système ventriculaire normal",
        "Absence de lésion expansive",
        "Parenchyme cérébral sans anomalie",
        "Espaces sous-arachnoïdiens normaux"
      ]
    },
    "conclusion": {
      "content":
          """IRM cérébrale normale. Aucune anomalie structurelle décelée pouvant expliquer la symptomatologie clinique. 
      Les céphalées semblent d'origine fonctionnelle. Recommandation de suivi clinique et éventuellement 
      consultation spécialisée en neurologie pour prise en charge symptomatique.""",
      "keyFindings": [
        "IRM cérébrale strictement normale",
        "Absence d'étiologie structurelle",
        "Céphalées probablement fonctionnelles",
        "Suivi clinique recommandé"
      ]
    }
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _sectionScrollController = ScrollController();
    _tabController = TabController(length: _sections.length, vsync: this);

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _sectionScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    for (int i = 0; i < _sectionKeys.length; i++) {
      final RenderBox? renderBox =
          _sectionKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        if (position.dy <= 200 && position.dy >= -200) {
          if (_currentSection != i) {
            setState(() {
              _currentSection = i;
            });
            _tabController.animateTo(i);
            break;
          }
        }
      }
    }
  }

  void _scrollToSection(int index) {
    final RenderBox? renderBox =
        _sectionKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      _scrollController.animateTo(
        _scrollController.offset + position.dy - 150,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onImageSelected(int index) {
    setState(() {
      _currentImageIndex = index;
    });
  }

  void _showFullScreenImage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          imageUrls: (imageryResult["images"] as List).cast<String>(),
          initialIndex: _currentImageIndex,
        ),
      ),
    );
  }

  void _handleShareImages() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Images partagées avec succès'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleDownloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapport téléchargé avec succès'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handlePrintResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impression en cours...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleAddToHealthRecords() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ajouté au dossier médical avec succès'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = (imageryResult["images"] as List).cast<String>();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 2.0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              imageryResult["examinationType"] as String,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Complété le ${imageryResult["completionDate"]}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _handleDownloadReport,
            icon: CustomIconWidget(
              iconName: 'download',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(6.h),
          child: SectionNavigationWidget(
            sections: _sections,
            currentSection: _currentSection,
            onSectionTap: _scrollToSection,
            scrollController: _sectionScrollController,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Information Header
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'person',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              imageryResult["patientName"] as String,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Text(
                              'N° Ordre: ',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              imageryResult["orderNumber"] as String,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Text(
                              'Radiologue: ',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              imageryResult["radiologist"] as String,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Medical Image Viewer
                  MedicalImageViewerWidget(
                    imageUrl: imageUrls[_currentImageIndex],
                    imageTitle:
                        'Image ${_currentImageIndex + 1}/${imageUrls.length}',
                    onFullScreenTap: _showFullScreenImage,
                  ),

                  SizedBox(height: 2.h),

                  // Image Gallery
                  ImageGalleryWidget(
                    imageUrls: imageUrls,
                    initialIndex: _currentImageIndex,
                    onImageSelected: _onImageSelected,
                  ),

                  SizedBox(height: 3.h),

                  // Medical Sections
                  Container(
                    key: _sectionKeys[0],
                    child: MedicalSectionWidget(
                      title: 'Indication',
                      content: (imageryResult["indication"]
                          as Map<String, dynamic>)["content"] as String,
                      technicalDetails: (imageryResult["indication"]
                              as Map<String, dynamic>)["technicalDetails"]
                          as String?,
                      isExpandable: true,
                      keyFindings: ((imageryResult["indication"]
                              as Map<String, dynamic>)["keyFindings"] as List?)
                          ?.cast<String>(),
                    ),
                  ),

                  Container(
                    key: _sectionKeys[1],
                    child: MedicalSectionWidget(
                      title: 'Technique',
                      content: (imageryResult["technique"]
                          as Map<String, dynamic>)["content"] as String,
                      technicalDetails: (imageryResult["technique"]
                              as Map<String, dynamic>)["technicalDetails"]
                          as String?,
                      isExpandable: true,
                    ),
                  ),

                  Container(
                    key: _sectionKeys[2],
                    child: MedicalSectionWidget(
                      title: 'Résultats',
                      content: (imageryResult["results"]
                          as Map<String, dynamic>)["content"] as String,
                      keyFindings: ((imageryResult["results"]
                              as Map<String, dynamic>)["keyFindings"] as List?)
                          ?.cast<String>(),
                    ),
                  ),

                  Container(
                    key: _sectionKeys[3],
                    child: MedicalSectionWidget(
                      title: 'Conclusion',
                      content: (imageryResult["conclusion"]
                          as Map<String, dynamic>)["content"] as String,
                      keyFindings: ((imageryResult["conclusion"]
                              as Map<String, dynamic>)["keyFindings"] as List?)
                          ?.cast<String>(),
                    ),
                  ),

                  SizedBox(height: 10.h), // Space for bottom actions
                ],
              ),
            ),
          ),

          // Action Buttons
          ActionButtonsWidget(
            onShareImages: _handleShareImages,
            onDownloadReport: _handleDownloadReport,
            onPrintResults: _handlePrintResults,
            onAddToHealthRecords: _handleAddToHealthRecords,
          ),
        ],
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'close',
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          'Image ${_currentIndex + 1}/${widget.imageUrls.length}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image sauvegardée'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: CustomIconWidget(
              iconName: 'download',
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            child: Center(
              child: CustomImageWidget(
                imageUrl: widget.imageUrls[index],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
