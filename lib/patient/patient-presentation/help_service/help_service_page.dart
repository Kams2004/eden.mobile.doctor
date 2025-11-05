import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:lottie/lottie.dart';
import '../../../services/theme_service.dart';
import '../../patient-widgets/widgets/professional_app_bar.dart';

class HelpServicePage extends StatefulWidget {
  const HelpServicePage({super.key});

  @override
  State<HelpServicePage> createState() => _HelpServicePageState();
}

class _HelpServicePageState extends State<HelpServicePage> {
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

  final List<Map<String, dynamic>> _helpItems = [
    {
      'title': 'Scanner une prescription',
      'subtitle': 'Comment utiliser le scanner de prescription',
      'icon': Icons.document_scanner_outlined,
      'color': Color(0xFF3B82F6),
      'steps': [
        'Appuyez sur "Prescription" dans la navigation',
        'Positionnez votre prescription dans le cadre',
        'Assurez-vous que l\'éclairage est suffisant',
        'Appuyez sur le bouton de capture',
        'Vérifiez le résultat et confirmez'
      ]
    },
    {
      'title': 'Guide d\'utilisation',
      'subtitle': 'Guide complet de l\'application',
      'icon': Icons.help_outline,
      'color': Color(0xFF10B981),
      'features': [
        'Consulter vos résultats médicaux',
        'Scanner vos prescriptions',
        'Voir la disponibilité des examens',
        'Prendre des rendez-vous',
        'Suivre le statut de validation'
      ],
      'note': 'Pour plus d\'informations, contactez le support.'
    },
    {
      'title': 'Support technique',
      'subtitle': 'Contacter le support',
      'icon': Icons.support_agent_outlined,
      'color': Color(0xFF8B5CF6),
      'contacts': {
        'Relations publiques': {
          'phone': '+237 696134160',
          'whatsapp': 'WhatsApp'
        },
        'Service technique': {
          'phone': '+237 695995842',
          'whatsapp': 'WhatsApp'
        }
      }
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      appBar: ProfessionalAppBar(
        title: 'Service d\'aide',
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.white,
              image: !_themeService.isDarkMode ? DecorationImage(
                image: AssetImage("assets/images/overlay2.jpeg"),
                fit: BoxFit.cover,
              ) : null,
            ),
          ),
          if (_themeService.isDarkMode)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                  ],
                ),
              ),
            ),
          SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 3.h),
                _buildHelpItems(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _themeService.isDarkMode ? Color(0xFF334155) : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_themeService.isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 35.w,
            height: 35.w,
            child: Lottie.asset(
              'assets/lotties/aide service.json',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Comment pouvons-nous vous aider ?',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Trouvez des réponses à vos questions ou contactez notre équipe de support',
            style: TextStyle(
              fontSize: 14.sp,
              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItems() {
    return Column(
      children: _helpItems.map((item) => _buildHelpCard(item)).toList(),
    );
  }

  Widget _buildHelpCard(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _themeService.isDarkMode ? Color(0xFF334155) : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_themeService.isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showHelpDetails(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'],
                    color: item['color'],
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        item['subtitle'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 4.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 90.w,
            constraints: BoxConstraints(maxHeight: 80.h),
            decoration: BoxDecoration(
              color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogHeader(item),
                Flexible(
                  child: _buildDialogContent(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: item['color'],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(
            item['icon'],
            color: Colors.white,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              item['title'],
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogContent(Map<String, dynamic> item) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item['steps'] != null) _buildStepsContent(item),
          if (item['features'] != null) _buildFeaturesContent(item),
          if (item['contacts'] != null) _buildContactsContent(item),
        ],
      ),
    );
  }

  Widget _buildStepsContent(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Étapes à suivre :',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: _themeService.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        ...List.generate(
          item['steps'].length,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: item['color'],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    item['steps'][index],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesContent(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EDEN vous permet de:',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: _themeService.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        ...List.generate(
          item['features'].length,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 1.5.h),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: item['color'],
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    item['features'][index],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (item['note'] != null) ...[
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: item['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item['color'].withOpacity(0.3)),
            ),
            child: Text(
              item['note'],
              style: TextStyle(
                fontSize: 14.sp,
                color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContactsContent(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service d\'aide',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: _themeService.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        ...item['contacts'].entries.map((entry) => _buildContactCard(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildContactCard(String title, Map<String, String> contact) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF334155) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeService.isDarkMode ? Color(0xFF475569) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: Color(0xFF3B82F6), size: 4.w),
                      SizedBox(width: 2.w),
                      Text(
                        contact['phone']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat, color: Color(0xFF10B981), size: 4.w),
                      SizedBox(width: 2.w),
                      Text(
                        contact['whatsapp']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}