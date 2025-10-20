import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../widgets/new_request_dialog.dart';

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback? onRequestUpdated;

  const RequestCard({super.key, required this.request, this.onRequestUpdated});

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

  String _getRequestType() {
    if (request['revendication_examen'] == true) return 'Réclamation Examen';
    if (request['patient_request_prix_examen'] == true) return 'Prix Examen';
    if (request['connection'] == true) return 'Connexion';
    if (request['patient_request_examen_out'] == true) return 'Examen Externe';
    if (request['administration'] == true) return 'Administration';
    if (request['commission'] == true) return 'Commission';
    if (request['suggestion'] == true) return 'Suggestion';
    if (request['error'] == true) return 'Erreur';
    if (request['etat_patient'] == true) return 'État Patient';
    return 'Autre';
  }

  Color _getTypeColor() {
    final type = _getRequestType();
    switch (type) {
      case 'Réclamation Examen':
        return Colors.orange;
      case 'Prix Examen':
        return Color(0xFF3B82F6);
      case 'Connexion':
        return Colors.green;
      case 'Examen Externe':
        return Colors.purple;
      case 'Administration':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewRequestDialog(
        onRequestSubmitted: onRequestUpdated ?? () {},
        existingRequest: request,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValid = request['valide'] == true;
    
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: _getTypeColor(),
                    size: 4.w,
                  ),
                ),
                SizedBox(width: 2.5.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRequestType(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        request['message'] ?? 'Aucun message',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: isValid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isValid ? 'Validé' : 'En Attente',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isValid ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Créée: ${_formatDate(request['CreatedAt'])}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditDialog(context),
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        child: Icon(Icons.edit_outlined, color: Color(0xFF3B82F6), size: 4.5.w),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        child: Icon(Icons.delete_outline, color: Colors.red, size: 4.5.w),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}