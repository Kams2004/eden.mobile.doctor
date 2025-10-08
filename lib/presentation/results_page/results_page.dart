import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../model/result_model.dart';
import '../result_detail_page/result_detail_page.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with TickerProviderStateMixin {
  bool isLoading = true;
  List<ExamResult> allResults = [];
  List<ExamResult> filteredResults = [];
  String selectedFilter = 'Tous';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadResults();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    try {
      setState(() {
        isLoading = true;
      });

      final doctorId = StorageService.doctorId;
      final accessToken = StorageService.accessToken;
      
      print('Loading results for doctorId: $doctorId');
      
      if (doctorId != null && accessToken != null) {
        final authService = AuthService();
        final results = await authService.getResults(doctorId, accessToken);
        
        setState(() {
          allResults = results;
          filteredResults = results;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading results: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterResults() {
    setState(() {
      switch (selectedFilter) {
        case 'Envoyés':
          filteredResults = allResults.where((result) => result.isEmailSent).toList();
          break;
        case 'Non envoyés':
          filteredResults = allResults.where((result) => !result.isEmailSent).toList();
          break;
        default:
          filteredResults = allResults;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentCount = allResults.where((r) => r.isEmailSent).length;
    final notSentCount = allResults.where((r) => !r.isEmailSent).length;
    
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF334155),
              size: 20,
            ),
          ),
        ),
        title: Flexible(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                   borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résultats d\'Examens',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${allResults.length} résultats',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _loadResults,
            child: Text(
              'Actualiser',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Filter Section
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  _buildFilterChip('Tous', allResults.length),
                  SizedBox(width: 2.w),
                  _buildFilterChip('Envoyés', sentCount),
                  SizedBox(width: 2.w),
                  _buildFilterChip('Non envoyés', notSentCount),
                ],
              ),
            ),

            // Results List
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF3B82F6)),
                          SizedBox(height: 3.w),
                          Text(
                            'Chargement des résultats...',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : filteredResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.assignment_outlined,
                                  size: 48,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              SizedBox(height: 4.w),
                              Text(
                                'Aucun résultat trouvé',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              SizedBox(height: 2.w),
                              Text(
                                'Les résultats d\'examens apparaîtront ici',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(4.w),
                          itemCount: filteredResults.length,
                          itemBuilder: (context, index) {
                            return _buildResultCard(filteredResults[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = label;
          });
          _filterResults();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 3.w),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF3B82F6) : Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Color(0xFF3B82F6) : Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (label == 'Non envoyés')
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              if (label == 'Non envoyés') SizedBox(width: 1.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 1.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.w),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(ExamResult result) {
    final statusColor = result.isEmailSent ? Color(0xFF10B981) : Color(0xFFEF4444);
    final statusText = result.isEmailSent ? 'Email non envoyé' : 'En attente';
    final statusIcon = result.isEmailSent ? Icons.check_circle : Icons.schedule;
    
    return GestureDetector(
      onTap: () => _navigateToResultDetail(result),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6).withOpacity(0.1),
                                         borderRadius: BorderRadius.circular(10),

                    ),
                    child: Icon(
                      Icons.science_outlined,
                      color: Color(0xFF3B82F6),
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Laboratoire',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                result.code.isNotEmpty ? result.code : 'TEST2489',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            result.patientName.isNotEmpty ? result.patientName : '2',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Reçu le ${_formatDate(result.receivedDate)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.chevron_right,
                    color: Color(0xFF94A3B8),
                    size: 16,
                  ),
                ],
              ),
            ),
            
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.5.w),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    statusIcon,
                    size: 14,
                    color: statusColor,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToResultDetail(ExamResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultDetailPage(
          code: result.code.isNotEmpty ? result.code : 'TEST2489',
          type: 'Laboratoire',
          matricule: result.patientMatricule.isNotEmpty ? result.patientMatricule : 'XXXMIY380BZM',
        ),
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