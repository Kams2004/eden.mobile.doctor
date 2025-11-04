import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';

class ImageryResultDetail extends StatefulWidget {
  const ImageryResultDetail({super.key});

  @override
  State<ImageryResultDetail> createState() => _ImageryResultDetailState();
}

class _ImageryResultDetailState extends State<ImageryResultDetail> {
  Map<String, dynamic>? _resultData;
  bool _isLoading = false;
  String? _error;
  final ThemeService _themeService = ThemeService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _resultData == null) {
      _resultData = args;
      _loadImageryDetails();
    }
  }

  Future<void> _loadImageryDetails() async {
    // Skip API call for now since endpoint returns 404
    // Just simulate loading and show the data we already have
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    await Future.delayed(Duration(milliseconds: 500));
    
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildErrorWidget() {
    // Check if error contains unpaid bills message
    bool isUnpaidBillsError = _error!.contains('factures impayées') || 
                              _error!.contains('Vous avez des factures impayées');
    
    if (isUnpaidBillsError) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(6.w),
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 12.w,
                  color: Color(0xFFF59E0B),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Factures Impayées',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _themeService.isDarkMode ? Colors.white : Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Vous avez des factures impayées. Veuillez les régler pour accéder à vos résultats.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF3B82F6)),
                        padding: EdgeInsets.symmetric(vertical: 3.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Retour',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/patient-invoices');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 3.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Voir Factures',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    
    // Default error widget
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 15.w,
            color: Colors.red,
          ),
          SizedBox(height: 2.h),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: _loadImageryDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_resultData == null) {
      return Scaffold(
        backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
        appBar: AppBar(
          backgroundColor: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
          elevation: 0,
          surfaceTintColor: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
          title: Text(
            'Détail du Résultat',
            style: TextStyle(color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6)),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            'Aucune donnée disponible',
            style: TextStyle(color: _themeService.isDarkMode ? Colors.white : Colors.black87),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        surfaceTintColor: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Détail de l\'Imagerie',
          style: TextStyle(
            color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/overlay2.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _themeService.isDarkMode ? Color(0xFF0F172A).withOpacity(0.85) : Colors.white.withOpacity(0.85),
            ),
          ),
        
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3B82F6),
                  ),
                )
              : _error != null
                  ? _buildErrorWidget()
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildResultHeader(),
                          SizedBox(height: 3.h),
                          _buildResultDetails(),
                          SizedBox(height: 3.h),
                          _buildMedicalDisclaimer(),
                          SizedBox(height: 3.h),
                          // _buildActionButtons(),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981),
            Color(0xFF059669),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medical_information_outlined,
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Examen d\'Imagerie',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _resultData!['requested_test'] ?? _resultData!['test'] ?? 'Examen d\'imagerie',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _resultData!['state'] == 'validated' ? 'Validé' : 'En cours',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
         
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 4.w,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildResultDetails() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de l\'Examen',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),
          if (_resultData!['requestor'] != null) ...[
            _buildDetailRow('Médecin prescripteur', _resultData!['requestor']),
            SizedBox(height: 1.h),
          ],
          if (_resultData!['request_date'] != null) ...[
            _buildDetailRow('Date demandée', _formatDate(_resultData!['request_date'])),
            SizedBox(height: 1.h),
          ],
          if (_resultData!['done_date'] != null) ...[
            _buildDetailRow('Date réalisation', _formatDate(_resultData!['done_date'])),
            SizedBox(height: 1.h),
          ],
          if (_resultData!['validation_date'] != null) ...[
            _buildDetailRow('Date validation', _formatDate(_resultData!['validation_date'])),
            SizedBox(height: 1.h),
          ],
          if (_resultData!['realisateur'] != null) ...[
            _buildDetailRow('Réalisateur', _resultData!['realisateur']),
            SizedBox(height: 1.h),
          ],
          if (_resultData!['done_by'] != null) ...[
            _buildDetailRow('Fait par', _resultData!['done_by']),
            SizedBox(height: 1.h),
          ],
          if (_resultData!['order'] != null) ...[
            _buildDetailRow('Commande', _resultData!['order']),
            SizedBox(height: 1.h),
          ],
          if (_resultData!['service_cot'] != null) ...[
            _buildDetailRow('Service', _resultData!['service_cot']),
            SizedBox(height: 1.h),
          ],
          if (_resultData!['conclusion'] != null && _resultData!['conclusion'].toString().trim().isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              'Conclusion',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _themeService.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.blue.withOpacity(0.2)),
              ),
              child: Text(
                _resultData!['conclusion'].toString().trim(),
                style: TextStyle(
                  fontSize: 15.sp,
                  color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (_resultData!['resultat'] != null && _resultData!['resultat'].toString().trim().isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              'Résultats détaillés',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _themeService.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.green.withOpacity(0.2)),
              ),
              child: Text(
                _resultData!['resultat'].toString().trim(),
                style: TextStyle(
                  fontSize: 15.sp,
                  color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalDisclaimer() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Avis médical important',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Ces résultats doivent être interprétés par un professionnel de santé qualifié. En cas de question ou de préoccupation concernant ces résultats, veuillez consulter votre médecin traitant.',
            style: TextStyle(
              fontSize: 13.sp,
              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildActionButtons() {
  //   return Container(
  //     padding: EdgeInsets.all(4.w),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey[200]!, width: 1),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Actions',
  //           style: TextStyle(
  //             fontSize: 16.sp,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.black87,
  //           ),
  //         ),
  //         SizedBox(height: 2.h),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: ElevatedButton.icon(
  //                 onPressed: () => _showShareDialog(),
  //                 icon: Icon(
  //                   Icons.share_outlined,
  //                   size: 4.w,
  //                 ),
  //                 label: Text(
  //                   'Partager',
  //                   style: TextStyle(
  //                     fontSize: 14.sp,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Color(0xFF10B981),
  //                   foregroundColor: Colors.white,
  //                   padding: EdgeInsets.symmetric(vertical: 2.h),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: 3.w),
  //             Expanded(
  //               child: ElevatedButton.icon(
  //                 onPressed: _handleDownloadReport,
  //                 icon: Icon(
  //                   Icons.download_outlined,
  //                   size: 4.w,
  //                 ),
  //                 label: Text(
  //                   'Télécharger',
  //                   style: TextStyle(
  //                     fontSize: 14.sp,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Color(0xFF3B82F6),
  //                   foregroundColor: Colors.white,
  //                   padding: EdgeInsets.symmetric(vertical: 2.h),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Non disponible';
    
    try {
      DateTime date;
      
      if (dateString.contains('GMT') || dateString.contains('UTC')) {
        // Handle RFC 2822 format: "Wed, 19 Mar 2025 08:12:01 GMT"
        final cleanDate = dateString.replaceAll(RegExp(r'^\w+,\s*'), '').replaceAll(' GMT', '').replaceAll(' UTC', '');
        final parts = cleanDate.split(' ');
        if (parts.length >= 4) {
          final day = int.parse(parts[0]);
          final monthStr = parts[1];
          final year = int.parse(parts[2]);
          final timePart = parts[3];
          
          final months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
                         'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12};
          final month = months[monthStr] ?? 1;
          
          final timeComponents = timePart.split(':');
          final hour = int.parse(timeComponents[0]);
          final minute = int.parse(timeComponents[1]);
          
          date = DateTime(year, month, day, hour, minute);
        } else {
          return 'Non disponible';
        }
      } else if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        } else {
          return 'Non disponible';
        }
      } else {
        date = DateTime.parse(dateString);
      }
      
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Non disponible';
    }
  }

  // void _showShareDialog() {
  //   final TextEditingController matriculeController = TextEditingController();
  //   bool isSearching = false;
  //   String? doctorName;
    
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //             title: Row(
  //               children: [
  //                 Icon(Icons.share_outlined, color: Color(0xFF3B82F6), size: 6.w),
  //                 SizedBox(width: 2.w),
  //                 Text('Partager le résultat', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
  //               ],
  //             ),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Container(
  //                   padding: EdgeInsets.all(3.w),
  //                   decoration: BoxDecoration(
  //                     color: Colors.blue.withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(8),
  //                     border: Border.all(color: Colors.blue.withOpacity(0.3)),
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text('Examen à partager:', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.blue[700])),
  //                       SizedBox(height: 0.5.h),
  //                       Text('Type: Imagerie', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
  //                       Text('Code: ${_resultData!['number'] ?? _resultData!['id'] ?? 'N/A'}', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
  //                     ],
  //                   ),
  //                 ),
  //                 SizedBox(height: 2.h),
  //                 Text('Matricule du médecin:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
  //                 SizedBox(height: 1.h),
  //                 TextField(
  //                   controller: matriculeController,
  //                   onChanged: (value) {
  //                     setState(() {
  //                       if (value.isNotEmpty && doctorName == null) {
  //                         Future.delayed(Duration(milliseconds: 300), () {
  //                           if (matriculeController.text.isNotEmpty) {
  //                             setState(() {
  //                               doctorName = 'Dr. ${matriculeController.text.toUpperCase()}';
  //                             });
  //                           }
  //                         });
  //                       } else if (value.isEmpty) {
  //                         doctorName = null;
  //                       }
  //                     });
  //                   },
  //                   decoration: InputDecoration(
  //                     hintText: 'Entrez le matricule',
  //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //                     suffixIcon: IconButton(
  //                       icon: isSearching ? SizedBox(width: 4.w, height: 4.w, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.search),
  //                       onPressed: () async {
  //                         if (matriculeController.text.isNotEmpty) {
  //                           setState(() { isSearching = true; });
  //                           await Future.delayed(Duration(milliseconds: 500));
  //                           setState(() { 
  //                             isSearching = false;
  //                             doctorName = 'Dr. ${matriculeController.text.toUpperCase()}';
  //                           });
  //                         }
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //                 if (doctorName != null) ...[
  //                   SizedBox(height: 2.h),
  //                   Container(
  //                     padding: EdgeInsets.all(3.w),
  //                     decoration: BoxDecoration(
  //                       color: Colors.green.withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(8),
  //                       border: Border.all(color: Colors.green.withOpacity(0.3)),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Icon(Icons.check_circle, color: Colors.green, size: 5.w),
  //                         SizedBox(width: 2.w),
  //                         Text('Médecin trouvé: $doctorName', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500)),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
  //               ),
  //               ElevatedButton(
  //                 onPressed: (doctorName != null && matriculeController.text.isNotEmpty) ? () async {
  //                   Navigator.pop(context);
  //                   await _shareResult();
  //                 } : null,
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Color(0xFF3B82F6),
  //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //                 ),
  //                 child: Text('Partager', style: TextStyle(color: Colors.white)),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Future<void> _shareResult() async {
    try {
      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      final doctorId = StorageService.doctorId;
      
      if (accessToken == null || doctorId == null) {
        throw Exception('Données d\'authentification manquantes');
      }
      
      print('=== SHARE RESULT DEBUG ===');
      print('Doctor ID: $doctorId');
      print('Exam Type: Imagerie');
      print('Exam Code: ${_resultData!['number'] ?? _resultData!['id']?.toString() ?? ''}');
      print('Access Token: ${accessToken?.substring(0, 10)}...');
      
      await authService.shareResult(
        doctorId: doctorId,
        examType: 'Imagerie',
        examCode: _resultData!['number'] ?? _resultData!['id']?.toString() ?? '',
        accessToken: accessToken,
      );
      
      print('Share result completed successfully');
      print('=== END SHARE DEBUG ===');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Résultat d\'imagerie partagé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du partage: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleDownloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement du rapport en cours...'),
        backgroundColor: Color(0xFF3B82F6),
      ),
    );
  }
}