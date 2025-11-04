import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import '../imagery_results_list/widgets/imagery_skeleton_loader.dart';
import '../laboratory_result_detail/laboratory_result_detail.dart';
import '../../patient-widgets/widgets/professional_app_bar.dart';

class LaboratoryResultsList extends StatefulWidget {
  const LaboratoryResultsList({super.key});

  @override
  State<LaboratoryResultsList> createState() => _LaboratoryResultsListState();
}

class _LaboratoryResultsListState extends State<LaboratoryResultsList> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _laboratoryResults = [];
  List<Map<String, dynamic>> _filteredResults = [];
  String? _error;
  String _selectedFilter = 'Tous';
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    _loadLaboratoryResults();
  }

  Future<void> _loadLaboratoryResults() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Token d\'accès manquant');
      }
      
      final results = await authService.getLaboratoryResults(accessToken);
      print('=== LABORATORY RESULTS DEBUG ===');
      print('Results count: ${results.length}');
      if (results.isNotEmpty) {
        print('First result: ${results[0]}');
        print('Date field: ${results[0]['date_analysis']}');
      }
      print('=== END DEBUG ===');
      
      setState(() {
        _laboratoryResults = results;
        _filteredResults = results;
        _isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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

  String _calculateDuration(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Non disponible';
    try {
      DateTime date;
      
      if (dateString.contains('GMT') || dateString.contains('UTC')) {
        // Handle RFC 2822 format
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
      } else {
        date = DateTime.parse(dateString);
      }
      
      // Return the actual time from the date, not duration
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Non disponible';
    }
  }

  void _showShareDialog(Map<String, dynamic> result) {
    final TextEditingController matriculeController = TextEditingController();
    bool isSearching = false;
    Map<String, dynamic>? doctorInfo;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 90.w,
                constraints: BoxConstraints(maxHeight: 70.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, color: Colors.white, size: 6.w),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              'Partager le résultat',
                              style: TextStyle(
                                fontSize: 16.sp,
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
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Résultat à partager:', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.blue[700])),
                                  SizedBox(height: 0.5.h),
                                  Text('Type: Laboratoire', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                  Text('Code: ${result['name'] ?? 'N/A'}', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text('Matricule du médecin:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                            SizedBox(height: 1.h),
                            TextField(
                              controller: matriculeController,
                              decoration: InputDecoration(
                                hintText: 'Entrez le matricule (ex: XXXALL587EWK)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                suffixIcon: IconButton(
                                  icon: isSearching 
                                      ? SizedBox(width: 4.w, height: 4.w, child: CircularProgressIndicator(strokeWidth: 2)) 
                                      : Icon(Icons.search),
                                  onPressed: () async {
                                    if (matriculeController.text.isNotEmpty) {
                                      setDialogState(() { isSearching = true; doctorInfo = null; });
                                      try {
                                        final authService = AuthService();
                                        final accessToken = StorageService.accessToken;
                                        if (accessToken != null) {
                                          final doctor = await authService.getDoctorByMatricule(matriculeController.text.trim(), accessToken);
                                          setDialogState(() { 
                                            isSearching = false;
                                            doctorInfo = doctor;
                                          });
                                        } else {
                                          throw Exception('Token d\'accès manquant');
                                        }
                                      } catch (e) {
                                        print('Doctor lookup error: $e');
                                        setDialogState(() { isSearching = false; });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Médecin non trouvé ou erreur de recherche'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            if (doctorInfo != null) ...[
                              SizedBox(height: 2.h),
                              Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 5.w),
                                        SizedBox(width: 2.w),
                                        Text('Médecin trouvé', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    SizedBox(height: 1.h),
                                    Text('Nom: ${doctorInfo!['DoctorName']} ${doctorInfo!['DoctorLastname']}', style: TextStyle(fontSize: 12.sp)),
                                    Text('Spécialité: ${doctorInfo!['Speciality']}', style: TextStyle(fontSize: 12.sp)),
                                    Text('Email: ${doctorInfo!['DoctorEmail']}', style: TextStyle(fontSize: 12.sp)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Confirmez-vous l\'envoi de ce résultat au Dr. ${doctorInfo!['DoctorName']} ${doctorInfo!['DoctorLastname']} ?',
                                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                              ),
                            ],
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: doctorInfo != null ? () async {
                                      Navigator.pop(context);
                                      await _shareResult(result, doctorInfo!);
                                    } : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF3B82F6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text('Envoyer', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _shareResult(Map<String, dynamic> result, Map<String, dynamic> doctorInfo) async {
    try {
      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Token d\'accès manquant');
      }
      
      final response = await authService.sendResultToDoctor(
        doctorId: doctorInfo['id'],
        examType: 'Laboratoire',
        examCode: result['name'] ?? '',
        accessToken: accessToken,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Résultat envoyé avec succès au Dr. ${doctorInfo['DoctorName']} ${doctorInfo['DoctorLastname']}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  bool _isExpired(Map<String, dynamic> result) {
    final statutExpiration = result['statut_expiration'];
    final expirationDate = result['expiration_date'];
    
    if (statutExpiration == true || (expirationDate != null && DateTime.now().isAfter(_parseDate(expirationDate)))) {
      return true;
    }
    return false;
  }
  
  int _getDaysUntilExpiration(Map<String, dynamic> result) {
    final expirationDate = result['expiration_date'];
    if (expirationDate == null) {
      final dateAnalysis = result['date_analysis'];
      if (dateAnalysis != null) {
        final analysisDate = _parseDate(dateAnalysis);
        final expiration = analysisDate.add(Duration(days: 7));
        return expiration.difference(DateTime.now()).inDays;
      }
      return 7;
    }
    return _parseDate(expirationDate).difference(DateTime.now()).inDays;
  }
  
  DateTime _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return DateTime.now();
    try {
      if (dateString.contains('GMT')) {
        final parts = dateString.split(' ');
        if (parts.length >= 5) {
          final day = int.parse(parts[1]);
          final month = _getMonthNumber(parts[2]);
          final year = int.parse(parts[3]);
          final timeParts = parts[4].split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          return DateTime(year, month, day, hour, minute);
        }
      }
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }
  
  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  void _applyFilter() {
    setState(() {
      switch (_selectedFilter) {
        case 'Tous':
          _filteredResults = _laboratoryResults;
          break;
        case 'Terminé':
          _filteredResults = _laboratoryResults.where((result) => result['state'] == 'validated').toList();
          break;
        case 'En cours':
          _filteredResults = _laboratoryResults.where((result) => result['state'] != 'validated').toList();
          break;
        case 'Expiré':
          _filteredResults = _laboratoryResults.where((result) => _isExpired(result)).toList();
          break;
        case 'Non expiré':
          _filteredResults = _laboratoryResults.where((result) => !_isExpired(result)).toList();
          break;
      }
    });
  }

  Widget _buildFilterChips() {
    final filters = ['Tous', 'Terminé', 'En cours', 'Expiré', 'Non expiré'];
    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
                _applyFilter();
              },
              backgroundColor: Colors.white,
              selectedColor: Color(0xFF3B82F6),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? Color(0xFF3B82F6) : Color(0xFF3B82F6).withOpacity(0.3),
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final isExpired = _isExpired(result);
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: isExpired 
            ? (_themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[100])
            : (_themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isExpired ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LaboratoryResultDetail(),
                settings: RouteSettings(arguments: result),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF3B82F6).withOpacity(0.1),
                            Color(0xFF3B82F6).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.science_outlined,
                        color: Color(0xFF3B82F6),
                        size: 5.w,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result['test'] ?? result['name'] ?? 'Analyse de laboratoire',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      'Code: ${result['name'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: isExpired ? null : () => _showShareDialog(result),
                                    icon: Icon(
                                      Icons.share_outlined,
                                      color: isExpired ? Colors.grey : Color(0xFF3B82F6),
                                      size: 5.w,
                                    ),
                                  ),
                                  // GestureDetector(
                                  //   onTap: isExpired ? null : () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => LaboratoryResultDetail(),
                                  //         settings: RouteSettings(arguments: result),
                                  //       ),
                                  //     );
                                  //   },
                                  //   child: Row(
                                  //     children: [
                                  //       Icon(
                                  //         Icons.arrow_forward_ios,
                                  //         color: Color(0xFF3B82F6),
                                  //         size: 4.w,
                                  //       ),
                                  //       SizedBox(width: 1.w),
                                  //       Text(
                                  //         'Détails',
                                  //         style: TextStyle(
                                  //           fontSize: 12.sp,
                                  //           fontWeight: FontWeight.w600,
                                  //           color: Color(0xFF3B82F6),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            color: result['state'] == 'validated' 
                                ? Colors.green.withOpacity(0.1) 
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            result['state'] == 'validated' ? 'Terminé' : 'En cours',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: result['state'] == 'validated' 
                                  ? Colors.green[700] 
                                  : Colors.orange[700],
                            ),
                          ),
                        ),
                        if (isExpired) ...[
                          SizedBox(height: 0.5.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Expiré',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildInfoColumn('Patient', result['patient'] ?? 'N/A'),
                          _buildInfoColumn('Date D\'analyse', _formatDate(result['date_analysis'])),
                        ],
                      ),
                      SizedBox(height: 1.5.h),
                      Row(
                        children: [
                          _buildInfoColumn('Médecin Prescripteur', result['requestor'] ?? 'N/A'),
                          //  _buildInfoColumn('Heure', _calculateDuration(result['date_analysis'])),
                          _buildInfoColumn('Validé par', result['validated_by'] ?? 'N/A'),

                        ],
                      ),
                      // SizedBox(height: 1.5.h),
                      // Row(
                      //   children: [
                      //     _buildInfoColumn('Validé par', result['validated_by'] ?? 'N/A'),
                      //     Container(),
                      //   ],
                      // ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpirationWarning() {
    if (_laboratoryResults.isEmpty) return SizedBox.shrink();
    
    int minDaysLeft = 8;
    for (var result in _laboratoryResults) {
      if (!_isExpired(result)) {
        final daysLeft = _getDaysUntilExpiration(result);
        if (daysLeft < minDaysLeft) minDaysLeft = daysLeft;
      }
    }
    
    if (minDaysLeft > 7) return SizedBox.shrink();
    
    String message;
    if (minDaysLeft <= 0) {
      message = 'Certains résultats ont expiré et ne sont plus accessibles.';
    } else if (minDaysLeft == 1) {
      message = 'Certains résultats expirent dans 1 jour.';
    } else {
      message = 'Certains résultats expirent dans $minDaysLeft jours.';
    }
    
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: _themeService.isDarkMode ? Color(0xFF9CA3AF) : Colors.grey[700],
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Information importante',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _themeService.isDarkMode ? Colors.white : Colors.grey[800],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    StorageService.clearData();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-screen',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/laboratory-results-list',
          onLogout: _handleLogout,
        ),
      ),
      appBar: ProfessionalAppBar(
        title: 'Résultats de Laboratoire',
        subtitle: 'Analyses biologiques',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 5.w),
            onPressed: _loadLaboratoryResults,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
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
          // Container(
          //   color: Colors.white.withOpacity(0.85),
          // ),
          _isLoading
              ? ImagerySkeletonLoader(itemCount: 6)
              : _error != null
                  ? Center(
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
                            onPressed: _loadLaboratoryResults,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Réessayer'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLaboratoryResults,
                      child: _laboratoryResults.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: 30.h),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.science_outlined,
                                        size: 15.w,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Aucun résultat disponible',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        'Vos résultats de laboratoire apparaîtront ici.',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[500],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildExpirationWarning(),
                                _buildFilterChips(),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.all(4.w),
                                    itemCount: _filteredResults.length,
                                    itemBuilder: (context, index) {
                                      return _buildResultCard(_filteredResults[index]);
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
        ],
      ),
    );
  }
}