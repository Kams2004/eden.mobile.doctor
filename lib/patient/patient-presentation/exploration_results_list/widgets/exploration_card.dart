import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ExplorationCard extends StatefulWidget {
  final Map<String, dynamic> exploration;

  const ExplorationCard({
    Key? key,
    required this.exploration,
  }) : super(key: key);

  @override
  State<ExplorationCard> createState() => _ExplorationCardState();
}

class _ExplorationCardState extends State<ExplorationCard> {
  bool _isExpanded = false;

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? state) {
    switch (state?.toLowerCase()) {
      case 'validated':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTestIcon(String? testName) {
    if (testName == null) return Icons.medical_services;
    final test = testName.toLowerCase();
    if (test.contains('ecg') || test.contains('electrocardiogramme')) {
      return Icons.monitor_heart;
    } else if (test.contains('spirom') || test.contains('effort')) {
      return Icons.air;
    } else {
      return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final testName = widget.exploration['test'] ?? 'Test inconnu';
    final patientName = widget.exploration['patient'] ?? 'Patient inconnu';
    final requestor = widget.exploration['requestor'] ?? 'N/A';
    final dateRequested = widget.exploration['date_requested'];
    final dateAnalysis = widget.exploration['date_analysis'];
    final state = widget.exploration['state'] ?? 'unknown';
    final diagnosis = widget.exploration['diagnosis'];
    final resultat = widget.exploration['resultat'];
    final realisateur = widget.exploration['realisateur'];
    final indication = widget.exploration['indication'];

    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTestIcon(testName),
                    color: Colors.white,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        patientName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                  decoration: BoxDecoration(
                    color: _getStatusColor(state),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dates and Doctor Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demandé le',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDate(dateRequested),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analysé le',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDate(dateAnalysis),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 3.w),
                
                // Requestor and Realisateur
                if (requestor != 'N/A') ...[
                  Row(
                    children: [
                      Icon(Icons.person, size: 4.w, color: Colors.grey[600]),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Demandeur: $requestor',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                ],
                
                if (realisateur != null) ...[
                  Row(
                    children: [
                      Icon(Icons.medical_services, size: 4.w, color: Colors.grey[600]),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Réalisateur: $realisateur',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                ],
                
                // View More/Less Button
                if ((indication != null && indication.isNotEmpty) || 
                    (resultat != null && resultat.isNotEmpty) || 
                    (diagnosis != null && diagnosis.isNotEmpty)) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isExpanded ? 'Voir moins' : 'Voir plus',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Color(0xFF3B82F6),
                            size: 6.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                // Expandable Content
                if (_isExpanded) ...[
                  // Indication
                  if (indication != null && indication.isNotEmpty) ...[
                    Text(
                      'Indication:',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      indication,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                  
                  // Results
                  if (resultat != null && resultat.isNotEmpty) ...[
                    Text(
                      'Résultats:',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        resultat,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                  
                  // Diagnosis
                  if (diagnosis != null && diagnosis.isNotEmpty) ...[
                    Text(
                      'Diagnostic:',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: Text(
                        diagnosis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF065F46),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}