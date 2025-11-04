import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../services/theme_service.dart';

class SharedResultCard extends StatefulWidget {
  final Map<String, dynamic> result;
  final Function(Map<String, dynamic>) onDelete;
  
  const SharedResultCard({
    super.key,
    required this.result,
    required this.onDelete,
  });

  @override
  State<SharedResultCard> createState() => _SharedResultCardState();
}

class _SharedResultCardState extends State<SharedResultCard> {
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Non disponible';
    
    try {
      DateTime date;
      
      if (dateString.contains('GMT') || dateString.contains('UTC')) {
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
      
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Non disponible';
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 6.w),
              SizedBox(width: 2.w),
              Text(
                'Supprimer le partage',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cette action est irréversible',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 20, 20, 20),
                ),
              ),
              SizedBox(height: 2.h),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: 'Êtes-vous sûr de vouloir supprimer le partage de '),
                    TextSpan(
                      text: widget.result['exam_code'] ?? 'N/A',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' avec '),
                    TextSpan(
                      text: _getDoctorName(),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' ?'),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  'Le médecin n\'aura plus accès à ce résultat.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete(widget.result);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Supprimer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
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
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.share_outlined,
                    color: Color(0xFF3B82F6),
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.result['exam_code'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getTypeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.result['exam_type'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: _getTypeColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteDialog(context),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 5.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Partagé avec ${_getDoctorName()}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _themeService.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 1.h),
            if (widget.result['doctor_info'] != null) ...[
              Row(
                children: [
                  Icon(Icons.person_outline, color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[500], size: 4.w),
                  SizedBox(width: 1.w),
                  Text(
                    'Spécialité: ${widget.result['doctor_info']['Speciality'] ?? 'Non spécifiée'}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon(Icons.flag_outlined, color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[500], size: 4.w),
                  SizedBox(width: 1.w),
                  Text(
                    'Pays: ${widget.result['doctor_info']['DoctorNat'] ?? 'Non spécifié'}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon(Icons.email_outlined, color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[500], size: 4.w),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      'Email: ${widget.result['doctor_info']['DoctorEmail'] ?? 'Non disponible'}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
            ],
            Row(
              children: [
                Icon(Icons.access_time, color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[500], size: 4.w),
                SizedBox(width: 1.w),
                Text(
                  'Envoyé le: ${_formatDate(widget.result['sended_at'])}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(
                  widget.result['envoi_email'] == true ? Icons.email : Icons.email_outlined,
                  color: widget.result['envoi_email'] == true ? Colors.green : (_themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[500]),
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  widget.result['envoi_email'] == true ? 'Email envoyé' : 'Email non envoyé',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: widget.result['envoi_email'] == true ? Colors.green[700] : (_themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600]),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'ID: ${widget.result['patient_federation_id'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (widget.result['exam_type']) {
      case 'Laboratoire':
        return Color(0xFF3B82F6);
      case 'Imagerie':
        return Color(0xFF10B981);
      case 'Exploration':
        return Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  String _getDoctorName() {
    if (widget.result['doctor_info'] != null) {
      final firstName = widget.result['doctor_info']['DoctorName'] ?? '';
      final lastName = widget.result['doctor_info']['DoctorLastname'] ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
    }
    return 'Dr. MÉDECIN';
  }
}