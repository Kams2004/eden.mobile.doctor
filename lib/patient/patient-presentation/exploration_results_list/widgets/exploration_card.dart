import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/theme_service.dart';

class ExplorationCard extends StatefulWidget {
  final Map<String, dynamic> exploration;
  final bool isExpired;

  const ExplorationCard({
    Key? key,
    required this.exploration,
    this.isExpired = false,
  }) : super(key: key);

  @override
  State<ExplorationCard> createState() => _ExplorationCardState();
}

class _ExplorationCardState extends State<ExplorationCard> {
  bool _isExpanded = false;
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
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

  bool _isExpired() {
    final statutExpiration = widget.exploration['statut_expiration'];
    final expirationDate = widget.exploration['expiration_date'];
    
    if (statutExpiration == true || (expirationDate != null && DateTime.now().isAfter(_parseDate(expirationDate)))) {
      return true;
    }
    return false;
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

  void _handleViewMore() {
    final errorMessage = widget.exploration['error'];
    if (errorMessage != null && errorMessage.toString().contains('Factures Impayées')) {
      _showUnpaidBillsDialog(errorMessage.toString());
      return;
    }
    
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showExplorationShareDialog() {
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
                                  Text('Type: Exploration', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                  Text('Code: ${widget.exploration['number'] ?? widget.exploration['id'] ?? 'N/A'}', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
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
                                      await _shareExplorationResult(doctorInfo!);
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

  Future<void> _shareExplorationResult(Map<String, dynamic> doctorInfo) async {
    try {
      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Token d\'accès manquant');
      }
      
      await authService.sendResultToDoctor(
        doctorId: doctorInfo['id'],
        examType: 'Exploration',
        examCode: widget.exploration['number'] ?? widget.exploration['id']?.toString() ?? '',
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



  void _showUnpaidBillsDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
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
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Retour',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/patient-invoices');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
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
          ],
        );
      },
    );
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

    return Opacity(
      opacity: widget.isExpired ? 0.6 : 1.0,
      child: Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: widget.isExpired 
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: _themeService.isDarkMode 
                  ? Color(0xFF374151) 
                  : Color(0xFF3B82F6).withOpacity(0.1),
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
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                   
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: widget.isExpired ? null : () => _showExplorationShareDialog(),
                          icon: Icon(
                            Icons.share_outlined,
                            color: widget.isExpired ? Colors.grey : Color(0xFF3B82F6),
                            size: 5.w,
                          ),
                          padding: EdgeInsets.all(1.w),
                          constraints: BoxConstraints(),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                          decoration: BoxDecoration(
                            color: _getStatusColor(state),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            state == 'validated' ? 'TERMINÉ' : state.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.isExpired) ...[
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'EXPIRÉ',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    if (widget.exploration['error'] != null && widget.exploration['error'].toString().contains('Factures Impayées')) ...[
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                        decoration: BoxDecoration(
                          color: Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'FACTURE IMPAYÉE',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
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
                              fontSize: 12.sp,
                              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDate(dateRequested),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
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
                              fontSize: 12.sp,
                              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDate(dateAnalysis),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
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
                          'Médecin prescripteur: $requestor',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
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
                            fontSize: 13.sp,
                            color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
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
                    (diagnosis != null && diagnosis.isNotEmpty) ||
                    (widget.exploration['done_by'] != null) ||
                    (widget.exploration['validated_by'] != null) ||
                    (widget.exploration['technique'] != null)) ...[
                  GestureDetector(
                    onTap: widget.isExpired ? null : _handleViewMore,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isExpanded ? 'Voir moins' : 'Voir plus',
                            style: TextStyle(
                              fontSize: 14.sp,
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
                        color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      indication,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
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
                        color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[200]!),
                      ),
                      child: Text(
                        resultat,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _themeService.isDarkMode ? Colors.white : Colors.grey[800],
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
                        color: _themeService.isDarkMode ? Colors.white : Colors.black87,
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
                    SizedBox(height: 2.h),
                  ],
                  
                  // Additional Details
                  if (widget.exploration['done_by'] != null) ...[
                    Row(
                      children: [
                        Icon(Icons.person, size: 4.w, color: Colors.grey[600]),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Réalisé par: ${widget.exploration['done_by']}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                  ],
                  
                  if (widget.exploration['validated_by'] != null) ...[
                    Row(
                      children: [
                        Icon(Icons.verified, size: 4.w, color: Colors.green),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Validé par: ${widget.exploration['validated_by']}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                  ],
                  
                  if (widget.exploration['validation_date'] != null) ...[
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 4.w, color: Colors.grey[600]),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Date de validation: ${_formatDate(widget.exploration['validation_date'])}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    )
    );
  }
  }
