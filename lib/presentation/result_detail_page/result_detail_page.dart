import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/theme_service.dart';
import '../../model/result_model.dart';
import '../widgets/doctor_professional_app_bar.dart';

class ResultDetailPage extends StatefulWidget {
  final String code;
  final String type;
  final String matricule;

  const ResultDetailPage({
    Key? key,
    required this.code,
    required this.type,
    required this.matricule,
  }) : super(key: key);

  @override
  State<ResultDetailPage> createState() => _ResultDetailPageState();
}

class _ResultDetailPageState extends State<ResultDetailPage> {
  bool isLoading = true;
  ResultDetail? resultDetail;
  String? errorMessage;
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
    _loadResultDetail();
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

  Future<void> _loadResultDetail() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final accessToken = StorageService.accessToken;
      
      if (accessToken != null) {
        final authService = AuthService();
        final detail = await authService.getResultDetail(
          widget.type,
          widget.code,
          widget.matricule,
          accessToken,
        );
        
        setState(() {
          resultDetail = detail;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading result detail: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.white,
      appBar: DoctorProfessionalAppBar(
        title: widget.code,
        subtitle: 'Laboratoire',
        icon: Icons.assignment_outlined,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF3B82F6)),
                  SizedBox(height: 3.w),
                  Text(
                    'Chargement des détails...',
                    style: TextStyle(
                      color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF64748B),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Color(0xFFEF4444),
                      ),
                      SizedBox(height: 2.w),
                      Text(
                        'Erreur de chargement',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: _themeService.isDarkMode ? Colors.white : Color(0xFF475569),
                        ),
                      ),
                      SizedBox(height: 1.w),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.w),
                      ElevatedButton(
                        onPressed: _loadResultDetail,
                        child: Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPatientInfoCard(),
                      SizedBox(height: 2.w),
                      _buildExamInfoCard(),
                      SizedBox(height: 2.w),
                      _buildTestInfoCard(),
                      SizedBox(height: 2.w),
                      _buildResultsCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPatientInfoCard() {
    if (resultDetail == null) return SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Color(0xFFF8F9FA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: _themeService.isDarkMode ? Colors.white : Color(0xFF495057),
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text(
                'Informations Patient',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _themeService.isDarkMode ? Colors.white : Color(0xFF495057),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.w),
          _buildInfoRow('Nom complet', resultDetail!.patient.isNotEmpty ? resultDetail!.patient : 'Non renseigné'),
          _buildInfoRow('Date de naissance', 'Invalid Date (NaN ans)'),
        ],
      ),
    );
  }

  Widget _buildExamInfoCard() {
    if (resultDetail == null) return SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Color(0xFFFAFAFA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Informations Examen',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _themeService.isDarkMode ? Colors.white : Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.w),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date réception:',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF64748B),
                ),
              ),
              Text(
                _formatDate(resultDetail!.dateRequested),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _themeService.isDarkMode ? Colors.white : Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.w),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: Color(0xFFEF4444).withOpacity(0.1),
                                     borderRadius: BorderRadius.circular(10),

                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Email non envoyé',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: Color(0xFFF59E0B).withOpacity(0.1),
                                     borderRadius: BorderRadius.circular(13),

                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'En attente',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
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

  Widget _buildTestInfoCard() {
    if (resultDetail == null) return SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Color(0xFFEFF6FF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

children: [
  Row(
    children: [
      Icon(
        Icons.assignment,
        color: Color(0xFF3B82F6),
        size: 20,
      ),
      SizedBox(width: 2.w),
      Text(
        'Informations du Test',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: _themeService.isDarkMode ? Colors.white : Color(0xFF1E40AF),
        ),
      ),
    ],
  ),
  SizedBox(height: 2.w),
  _buildInfoRow('Test', resultDetail!.test),
  _buildInfoRow('Nom', resultDetail!.name),
  _buildInfoRow('Médecin prescripteur', resultDetail!.requestor),
],
      ),
    );
  }

  Widget _buildResultsCard() {
    if (resultDetail == null) return SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Color(0xFFF8F9FA),
        border: Border.all(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Color(0xFFF8F9FA).withOpacity(0.3)),
      ),


child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row( // Add this Row wrapper
      children: [
        Icon(
          Icons.person,
          color: _themeService.isDarkMode ? Colors.white : Color(0xFF495057),
          size: 18,
        ),
        SizedBox(width: 2.w),
        Text(
          'Résultats',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _themeService.isDarkMode ? Colors.white : Color(0xFF495057),
          ),
        ),
      ],
    ),
    SizedBox(height: 2.w),
    Container(
      width: double.infinity,
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.white,
        border: Border.all(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Color(0xFFE2E8F0)),
      ),
      child: _buildAnalytesTable(),
    ),
  ],
),
    );
  }

  Widget _buildAnalytesTable() {
    if (resultDetail == null || resultDetail!.analytesSummary.isEmpty) {
      return Text(
        'Aucun résultat disponible',
        style: TextStyle(
          fontSize: 12.sp,
          color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF6B7280),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final lines = resultDetail!.analytesSummary.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return SizedBox(height: 1.w);
        
        final parts = line.split('  ');
        if (parts.length >= 2) {
          return Padding(
            padding: EdgeInsets.only(bottom: 1.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    parts[0].trim(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _themeService.isDarkMode ? Colors.white : Color(0xFF374151),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    parts.sublist(1).join('  ').trim(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Padding(
          padding: EdgeInsets.only(bottom: 1.w),
          child: Text(
            line.trim(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: line.contains(':') ? FontWeight.w600 : FontWeight.normal,
              color: line.contains(':') 
                  ? (_themeService.isDarkMode ? Colors.white : Color(0xFF374151))
                  : (_themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF6B7280)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Non renseigné',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: _themeService.isDarkMode ? Colors.white : Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return '07 oct, 2025';
      final date = DateTime.parse(dateStr);
      final months = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun', 
                     'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}';
    } catch (e) {
      return '07 oct, 2025';
    }
  }
}