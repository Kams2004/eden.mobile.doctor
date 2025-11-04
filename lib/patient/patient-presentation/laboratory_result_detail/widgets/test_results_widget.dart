import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../services/theme_service.dart';

class TestResultsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> testDetails;

  const TestResultsWidget({
    super.key,
    required this.testDetails,
  });

  @override
  State<TestResultsWidget> createState() => _TestResultsWidgetState();
}

class _TestResultsWidgetState extends State<TestResultsWidget> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _themeService.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (_themeService.isDarkMode ? Color(0xFF374151) : Color(0xFF3B82F6)).withOpacity(0.1),
                      (_themeService.isDarkMode ? Color(0xFF374151) : Color(0xFF3B82F6)).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
                  size: 5.w,
                ),

              ),
              SizedBox(width: 2.w),
              Text(
                'Résultats des Tests',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          if (widget.testDetails.isEmpty)
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 8.w,
                      color: _themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[400],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Aucun détail disponible',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Les détails des tests apparaîtront ici une fois disponibles.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.testDetails.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final test = widget.testDetails[index];
                return _buildTestItem(test);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTestItem(Map<String, dynamic> test) {
    return Builder(
      builder: (context) {
        final hasResult = test['result'] != null || test['result_text'] != null;
        final hasRange = test['normal_range'] != null && test['normal_range'].toString().isNotEmpty;
        final isWarning = test['warning'] == true;
        
        return Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isWarning ? Colors.orange.withOpacity(0.05) : (_themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[50]),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isWarning ? Colors.orange.withOpacity(0.2) : (_themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[200]!),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  test['name'] ?? 'Test',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (isWarning)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange[700],
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Attention',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (hasResult) ...[
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Résultat: ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      test['result']?.toString() ?? test['result_text']?.toString() ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  if (test['units'] != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        test['units'].toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (hasRange) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[600],
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Valeurs normales: ',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      test['normal_range'].toString(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (test['remarks'] != null && test['remarks'].toString().isNotEmpty) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remarques:',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          test['remarks'].toString(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
            ],
          ),
        );
      },
    );
  }
}