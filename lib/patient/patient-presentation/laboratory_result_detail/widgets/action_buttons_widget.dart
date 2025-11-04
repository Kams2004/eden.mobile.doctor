import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/theme_service.dart';

class ActionButtonsWidget extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ActionButtonsWidget({
    super.key,
    required this.resultData,
  });

  void _showShareDialog(BuildContext context) {
    final TextEditingController matriculeController = TextEditingController();
    bool isSearching = false;
    String? doctorName;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.share_outlined, color: Color(0xFF3B82F6), size: 6.w),
                  SizedBox(width: 2.w),
                  Text('Partager le résultat', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Matricule du médecin:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: matriculeController,
                    decoration: InputDecoration(
                      hintText: 'Entrez le matricule',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: IconButton(
                        icon: isSearching ? SizedBox(width: 4.w, height: 4.w, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.search),
                        onPressed: () async {
                          if (matriculeController.text.isNotEmpty) {
                            setState(() { isSearching = true; });
                            await Future.delayed(Duration(milliseconds: 500));
                            setState(() { 
                              isSearching = false;
                              doctorName = 'Dr. ${matriculeController.text.toUpperCase()}';
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  if (doctorName != null) ...[

                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 5.w),
                          SizedBox(width: 2.w),
                          Text('Médecin trouvé: $doctorName', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: doctorName != null ? () async {
                    Navigator.pop(context);
                    await _shareResult(context);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Partager', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _shareResult(BuildContext context) async {
    try {
      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      final doctorId = StorageService.doctorId;
      
      if (accessToken == null || doctorId == null) {
        throw Exception('Données d\'authentification manquantes');
      }
      
      await authService.shareResult(
        doctorId: doctorId,
        examType: 'Laboratoire',
        examCode: resultData['name'] ?? '',
        accessToken: accessToken,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Résultat partagé avec succès'),
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

  void _printResult(BuildContext context) {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fonctionnalité d\'impression en cours de développement'),
        backgroundColor: Color(0xFF3B82F6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showShareDialog(context),
                  icon: Icon(
                    Icons.share_outlined,
                    size: 4.w,
                  ),
                  label: Text(
                    'Partager',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _printResult(context),
                  icon: Icon(
                    Icons.print_outlined,
                    size: 4.w,
                  ),
                  label: Text(
                    'Imprimer',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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